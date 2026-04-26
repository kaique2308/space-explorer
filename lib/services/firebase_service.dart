import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/apod_model.dart';
import '../models/favorite_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Collection reference
  CollectionReference get _favoritesRef =>
      _firestore.collection('favorites');

  // ──────────────────────────────────────────────
  // Analytics
  // ──────────────────────────────────────────────

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logApodViewed(String title, String date) async {
    await _analytics.logEvent(
      name: 'apod_viewed',
      parameters: {'title': title, 'date': date},
    );
  }

  Future<void> logFavoriteAdded(String title) async {
    await _analytics.logEvent(
      name: 'favorite_added',
      parameters: {'title': title},
    );
  }

  Future<void> logFavoriteRemoved(String title) async {
    await _analytics.logEvent(
      name: 'favorite_removed',
      parameters: {'title': title},
    );
  }

  // ──────────────────────────────────────────────
  // Favorites CRUD
  // ──────────────────────────────────────────────

  /// Save an APOD as favorite; returns the generated document ID
  Future<String> addFavorite(ApodModel apod) async {
    final docRef = await _favoritesRef.add({
      'title': apod.title,
      'imageUrl': apod.url,
      'date': apod.date,
      'explanation': apod.explanation,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    });
    await logFavoriteAdded(apod.title);
    return docRef.id;
  }

  /// Remove a favorite by document ID
  Future<void> removeFavorite(String docId) async {
    await _favoritesRef.doc(docId).delete();
  }

  /// Stream of all favorites, ordered by savedAt desc
  Stream<List<FavoriteModel>> favoritesStream() {
    return _favoritesRef
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteModel.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Check whether a specific APOD date is already saved
  Future<bool> isFavorite(String date) async {
    final query =
        await _favoritesRef.where('date', isEqualTo: date).limit(1).get();
    return query.docs.isNotEmpty;
  }

  /// Get the document ID for a favorite by date (null if not saved)
  Future<String?> getFavoriteId(String date) async {
    final query =
        await _favoritesRef.where('date', isEqualTo: date).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }
}
