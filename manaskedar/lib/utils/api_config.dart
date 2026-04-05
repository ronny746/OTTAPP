import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = "http://187.127.143.43:5001/api";
  // static const String baseUrl = "http://192.168.31.44:5001/api";
  

  static const String auth = "$baseUrl/auth";
  static const String user = "$baseUrl/user";
  
  static const String home = "$user/home";
  static const String banners = "$user/banners";
  static const String categories = "$user/categories";
  
  static const String movies = "$user/movies";
  static const String shorts = "$user/shorts";
  static const String audios = "$user/audios";
  static const String shows = "$user/shows";
  static const String activity = "$user/activity";
  static const String history = "$activity/history";
  static const String favorites = "$activity/favorites";

  // 🛡️ ADVANCED DATA OBFUSCATOR (For Privacy)
  static const String _SALT = "MK_SEC_2024_";

  static String encode(dynamic data) {
    final String salted = _SALT + json.encode(data);
    final String base64Str = base64.encode(utf8.encode(salted));
    final String reversed = base64Str.split('').reversed.join('');
    return json.encode({ "_q": reversed });
  }

  static dynamic decode(String body) {
    try {
      final jsonResponse = json.decode(body);
      if (jsonResponse is Map && jsonResponse.containsKey('_s')) {
        final reversed = jsonResponse['_s'].toString().split('').reversed.join('');
        final decodedString = utf8.decode(base64.decode(reversed));
        if (decodedString.startsWith(_SALT)) {
          return json.decode(decodedString.substring(_SALT.length));
        }
      }
      return jsonResponse;
    } catch (e) {
      return json.decode(body);
    }
  }

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
