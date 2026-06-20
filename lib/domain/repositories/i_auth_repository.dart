import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> login(String email, String password);
  Future<User> registerDummyUser(String name, String email, String role);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
