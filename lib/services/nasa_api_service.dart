import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/apod_model.dart';

class NasaApiService {
  // Demo key works for testing; replace with your own at api.nasa.gov
  static const String _apiKey = 'DEMO_KEY';
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  /// Fetch today's Astronomy Picture of the Day
  Future<ApodModel> fetchTodayApod() async {
    final uri = Uri.parse('$_baseUrl?api_key=$_apiKey');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApodModel.fromJson(json);
    } else {
      throw Exception('Failed to load APOD: ${response.statusCode}');
    }
  }

  /// Fetch APOD for a specific date (yyyy-MM-dd)
  Future<ApodModel> fetchApodByDate(String date) async {
    final uri = Uri.parse('$_baseUrl?api_key=$_apiKey&date=$date');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApodModel.fromJson(json);
    } else {
      throw Exception('Failed to load APOD for $date: ${response.statusCode}');
    }
  }

  /// Fetch a list of APODs (last N days)
  Future<List<ApodModel>> fetchRecentApods({int count = 10}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: count - 1));

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
        '$_baseUrl?api_key=$_apiKey&start_date=${fmt(startDate)}&end_date=${fmt(endDate)}');

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((e) => ApodModel.fromJson(e as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } else {
      throw Exception('Failed to load recent APODs: ${response.statusCode}');
    }
  }

  /// Search APODs between two dates
  Future<List<ApodModel>> fetchApodsBetween(DateTime start, DateTime end) async {
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
        '$_baseUrl?api_key=$_apiKey&start_date=${fmt(start)}&end_date=${fmt(end)}');

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((e) => ApodModel.fromJson(e as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } else {
      throw Exception('Failed to load APODs: ${response.statusCode}');
    }
  }
}
