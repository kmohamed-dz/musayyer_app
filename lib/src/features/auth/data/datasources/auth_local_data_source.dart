import '../../../../core/storage/local_storage.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final LocalStorage _storage;

  Future<void> cacheUser(UserModel user) async {
    await _storage.saveUser(user.toJson());
  }

  UserModel? getCachedUser() {
    final json = _storage.readUser();
    if (json == null) {
      return null;
    }
    return UserModel.fromJson(json);
  }

  Future<void> cacheToken(String token) async {
    await _storage.saveAuthToken(token);
  }

  Future<String?> getToken() {
    return _storage.readAuthToken();
  }

  Future<void> clear() async {
    await _storage.clearAuthToken();
    await _storage.clearUser();
  }
}
