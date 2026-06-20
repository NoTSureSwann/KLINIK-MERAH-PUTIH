import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> login(String email, String password);
  Future<User> register(String name, String email, String password, String phone, String role);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
