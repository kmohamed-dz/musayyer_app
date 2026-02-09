import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<User?> getSignedInUser() async {
    return _local.getCachedUser();
  }

  @override
  Future<String?> getToken() {
    return _local.getToken();
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final result = await _remote.login(email: email, password: password);
    final user = result.$1;
    final token = result.$2;
    await _local.cacheUser(user);
    await _local.cacheToken(token);
    return user;
  }

  @override
  Future<void> logout() async {
    await _local.clear();
  }
}
