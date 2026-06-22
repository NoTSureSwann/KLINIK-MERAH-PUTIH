import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Ganti dengan URL Ngrok Anda atau http://mbut-backend.test jika di emulator lokal
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
