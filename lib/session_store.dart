import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_name';
  static const _rememberMeKey = 'remember_me';
  static const _storage = FlutterSecureStorage();

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocalSession([String? customToken]) {
    final token = customToken ??
        List.generate(
          32,
          (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
        ).join();
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<String> readRole() async {
    try {
      return await _storage.read(key: _roleKey) ?? 'student';
    } catch (_) {
      return 'student';
    }
  }

  Future<String?> readEmail() async {
    try {
      return await _storage.read(key: _emailKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> readFullName() async {
    try {
      return await _storage.read(key: _nameKey);
    } catch (_) {
      return null;
    }
  }

  Future<bool> readRememberMe() async {
    try {
      final val = await _storage.read(key: _rememberMeKey);
      return val != 'false';
    } catch (_) {
      return true;
    }
  }

  Future<void> saveRememberMe(bool remember) async {
    try {
      await _storage.write(key: _rememberMeKey, value: remember.toString());
    } catch (_) {}
  }

  Future<void> saveLocalSessionForRole(
    String role, {
    String? token,
    String? email,
    String? fullName,
  }) async {
    await saveLocalSession(token);
    await _storage.write(key: _roleKey, value: role);
    if (email != null) await _storage.write(key: _emailKey, value: email);
    if (fullName != null) await _storage.write(key: _nameKey, value: fullName);
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _roleKey);
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _nameKey);
    } catch (_) {}
  }
}
