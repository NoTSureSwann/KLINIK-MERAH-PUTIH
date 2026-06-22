import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_model.dart';
import '../../core/network/api_config.dart';

class AuthRepository implements IAuthRepository {
  final SharedPreferences _prefs;
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';

  AuthRepository(this._prefs);

  @override
  Future<User?> login(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/login');
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userJson = data['user'];
        
        final userModel = UserModel(
          id: userJson['id'].toString(),
          name: userJson['name'],
          email: userJson['email'],
          phone: userJson['phone'],
          role: userJson['role'],
        );

        await _prefs.setString(_tokenKey, token);
        await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
        
        return userModel;
      } else if (response.statusCode == 401 || response.statusCode == 422) {
        throw Exception('Email atau password salah');
      } else if (response.statusCode == 500) {
        throw Exception('Terjadi kesalahan server, coba lagi nanti');
      } else {
        throw Exception('Gagal login: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Tidak ada koneksi internet');
      }
      rethrow;
    }
  }

  @override
  Future<User> register(String name, String email, String password, String phone, String role) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/register');
      final response = await http.post(
        url,
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userJson = data['user'];
        
        return UserModel(
          id: userJson['id'].toString(),
          name: userJson['name'],
          email: userJson['email'],
          phone: userJson['phone'],
          role: userJson['role'],
        );
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first[0];
        throw Exception(firstError);
      } else if (response.statusCode == 500) {
        throw Exception('Terjadi kesalahan server, coba lagi nanti');
      } else {
        throw Exception('Gagal mendaftar: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Tidak ada koneksi internet');
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/logout');
      await http.post(
        url,
        headers: await ApiConfig.getHeaders(),
      );
    } catch (_) {
      // Abaikan error jika API gagal dijangkau saat logout
    } finally {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final userJsonString = _prefs.getString(_userKey);
    if (userJsonString != null) {
      final json = jsonDecode(userJsonString);
      return UserModel.fromJson(json);
    }
    return null;
  }
}
