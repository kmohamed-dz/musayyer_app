import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._prefs, this._secureStorage);

  static const _onboardingKey = 'onboarding_complete';
  static const _userKey = 'auth_user';
  static const _tokenKey = 'auth_token';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    return LocalStorage(prefs, secureStorage);
  }

  bool getOnboardingComplete() =>
      _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> readAuthToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _prefs.setString(_userKey, jsonEncode(userJson));
  }

  Map<String, dynamic>? readUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) {
      return null;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }
}

final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError('LocalStorage must be initialized in main.');
});
