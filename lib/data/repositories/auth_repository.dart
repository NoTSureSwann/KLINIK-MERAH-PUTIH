import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/dummy_data.dart';

class AuthRepository implements IAuthRepository {
  final SharedPreferences _prefs;
  final _supabase = supabase.Supabase.instance.client;
  static const String _userKey = 'cached_user';

  AuthRepository(this._prefs);

  @override
  Future<User?> login(String email, String password) async {
    try {
      final supabase.AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (res.user != null) {
        // Fetch role and name from public.users table
        final userData = await _supabase.from('users').select().eq('id', res.user!.id).single();
        
        final userModel = UserModel(
          id: res.user!.id,
          name: userData['name'] ?? 'User',
          email: res.user!.email ?? email,
          role: userData['role'] ?? 'Patient',
        );
        
        await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
        return userModel;
      }
    } catch (e) {
      // Fallback to dummy data if API is unreachable or fails
      try {
        // Check dynamically registered dummy users first
        final localUsersString = _prefs.getString('local_dummy_users') ?? '[]';
        final List<dynamic> localUsers = jsonDecode(localUsersString);
        
        final localMatch = localUsers.cast<Map<String, dynamic>>().where(
          (user) => user['email'] == email && user['password'] == password,
        ).toList();

        if (localMatch.isNotEmpty) {
          final userModel = UserModel(
            id: localMatch.first['id'],
            name: localMatch.first['name'],
            email: localMatch.first['email'],
            role: localMatch.first['role'],
          );
          await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
          return userModel;
        }

        // Then check hardcoded dummy users
        final userJson = dummyUsers.firstWhere(
          (user) => user['email'] == email,
        );

        final userModel = UserModel.fromJson(userJson);
        await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
        return userModel;
      } catch (innerE) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<User> register(String name, String email, String password, String phone, String role) async {
    try {
      final supabase.AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
          'phone': phone,
        }
      );
      
      if (res.user != null) {
        // Trigger automatically handles inserting into public.users
        final newUser = UserModel(
          id: res.user!.id,
          name: name,
          email: email,
          role: role,
        );
        await _prefs.setString(_userKey, jsonEncode(newUser.toJson()));
        return newUser;
      }
    } catch (e) {
      // Print error or handle if needed
    }

    // Fallback to dummy local registration
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
    );
    
    // Save to local dummy list so login can find it later
    final localUsersString = _prefs.getString('local_dummy_users') ?? '[]';
    final List<dynamic> localUsers = jsonDecode(localUsersString);
    localUsers.add({
      'id': newUser.id,
      'name': newUser.name,
      'email': newUser.email,
      'password': password,
      'role': newUser.role,
    });
    await _prefs.setString('local_dummy_users', jsonEncode(localUsers));

    await _prefs.setString(_userKey, jsonEncode(newUser.toJson()));
    return newUser;
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    await _prefs.remove(_userKey);
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
