import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getSignedInUser();
  Future<String?> getToken();
  Future<User> login({required String email, required String password});
  Future<void> logout();
}
