import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = "http://localhost:5001/api";
  
  static const String auth = "$baseUrl/auth";
  static const String user = "$baseUrl/user";
  
  static const String banners = "$user/banners";
  static const String categories = "$user/categories";
  
  static const String movies = "$user/movies";
  static const String shorts = "$user/shorts";
  static const String audios = "$user/audios";
  static const String shows = "$user/shows";
  static const String activity = "$user/activity";
  static const String history = "$activity/history";
  static const String favorites = "$activity/favorites";

  // Helper method for authorized requests
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
