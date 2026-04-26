import 'package:flutter/material.dart';
import '../models/apod_model.dart';
import '../services/nasa_api_service.dart';
import '../services/firebase_service.dart';

enum ApodStatus { initial, loading, success, error }

class ApodProvider extends ChangeNotifier {
  final NasaApiService _nasaService = NasaApiService();
  final FirebaseService _firebaseService = FirebaseService();

  ApodModel? _todayApod;
  List<ApodModel> _recentApods = [];
  ApodStatus _status = ApodStatus.initial;
  String _errorMessage = '';

  // Favorites
  Map<String, bool> _favoriteCache = {};
  Map<String, String> _favoriteIdCache = {};

  // Getters
  ApodModel? get todayApod => _todayApod;
  List<ApodModel> get recentApods => _recentApods;
  ApodStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == ApodStatus.loading;

  // ──────────────────────────────────────────────
  // Fetch data
  // ──────────────────────────────────────────────

  Future<void> loadTodayApod() async {
    _status = ApodStatus.loading;
    notifyListeners();
    try {
      _todayApod = await _nasaService.fetchTodayApod();
      _status = ApodStatus.success;
      await _firebaseService.logApodViewed(
          _todayApod!.title, _todayApod!.date);
    } catch (e) {
      _status = ApodStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadRecentApods({int count = 12}) async {
    if (_recentApods.isNotEmpty) return; // already loaded
    _status = ApodStatus.loading;
    notifyListeners();
    try {
      _recentApods = await _nasaService.fetchRecentApods(count: count);
      _status = ApodStatus.success;
    } catch (e) {
      _status = ApodStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> refreshRecentApods({int count = 12}) async {
    _recentApods = [];
    await loadRecentApods(count: count);
  }

  // ──────────────────────────────────────────────
  // Favorites
  // ──────────────────────────────────────────────

  Future<bool> isFavorite(String date) async {
    if (_favoriteCache.containsKey(date)) return _favoriteCache[date]!;
    final result = await _firebaseService.isFavorite(date);
    _favoriteCache[date] = result;
    if (result) {
      final id = await _firebaseService.getFavoriteId(date);
      if (id != null) _favoriteIdCache[date] = id;
    }
    return result;
  }

  Future<void> toggleFavorite(ApodModel apod) async {
    final fav = await isFavorite(apod.date);
    if (fav) {
      final id = _favoriteIdCache[apod.date];
      if (id != null) {
        await _firebaseService.removeFavorite(id);
        await _firebaseService.logFavoriteRemoved(apod.title);
        _favoriteCache[apod.date] = false;
        _favoriteIdCache.remove(apod.date);
      }
    } else {
      final id = await _firebaseService.addFavorite(apod);
      _favoriteCache[apod.date] = true;
      _favoriteIdCache[apod.date] = id;
    }
    notifyListeners();
  }

  void invalidateFavoriteCache(String date) {
    _favoriteCache.remove(date);
    _favoriteIdCache.remove(date);
    notifyListeners();
  }

  FirebaseService get firebaseService => _firebaseService;
}
