import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';
import '../models/auth_session.dart';
import '../models/user_profile.dart';
import './auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final supabase.SupabaseClient _client;

  AuthSession? _mapSession(supabase.Session? session) {
    final user = session?.user;
    if (user == null) return null;
    return AuthSession(userId: user.id, email: user.email ?? '');
  }

  @override
  Stream<AuthSession?> watchSession() {
    return _client.auth.onAuthStateChange.map(
      (event) => _mapSession(event.session),
    );
  }

  @override
  Future<AuthSession?> currentSession() async {
    return _mapSession(_client.auth.currentSession);
  }

  @override
  Future<UserProfile?> fetchCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final profileRow = await _client
          .from('profiles')
          .select('id, email, full_name, phone, avatar_url, is_active')
          .eq('id', user.id)
          .maybeSingle();

      final roleRows = await _client
          .from('profile_roles')
          .select('roles(code, name)')
          .eq('profile_id', user.id);

      final parsedRoles = <AppRole>[];
      for (final row in (roleRows as List<dynamic>)) {
        if (row is Map<String, dynamic>) {
          final roleData = row['roles'];
          if (roleData is Map<String, dynamic>) {
            final appRole = AppRole.fromCode(roleData['code'] as String?);
            if (appRole != null && !parsedRoles.contains(appRole)) {
              parsedRoles.add(appRole);
            }
          } else if (roleData is List && roleData.isNotEmpty) {
            for (final item in roleData) {
              if (item is Map<String, dynamic>) {
                final appRole = AppRole.fromCode(item['code'] as String?);
                if (appRole != null && !parsedRoles.contains(appRole)) {
                  parsedRoles.add(appRole);
                }
              }
            }
          }
        }
      }

      // Check user metadata role (stored during signup/seed in auth.users)
      if (parsedRoles.isEmpty) {
        final metaRole = AppRole.fromCode(
          user.userMetadata?['role']?.toString(),
        );
        if (metaRole != null) {
          parsedRoles.add(metaRole);
        }
      }

      // Check app metadata role
      if (parsedRoles.isEmpty) {
        final appMetaRole = AppRole.fromCode(
          user.appMetadata['role']?.toString(),
        );
        if (appMetaRole != null) {
          parsedRoles.add(appMetaRole);
        }
      }

      if (profileRow == null) {
        final fallbackName =
            user.userMetadata?['full_name']?.toString().trim() ??
                (user.email?.split('@').first ?? 'User');
        return UserProfile(
          id: user.id,
          email: user.email ?? '',
          fullName: fallbackName,
          phone: user.userMetadata?['phone']?.toString(),
          roles: parsedRoles,
        );
      }

      return UserProfile(
        id: profileRow['id'] as String,
        email: (profileRow['email'] as String?) ?? user.email ?? '',
        fullName: (profileRow['full_name'] as String?) ?? 'User',
        phone: profileRow['phone'] as String?,
        avatarUrl: profileRow['avatar_url'] as String?,
        isActive: (profileRow['is_active'] as bool?) ?? true,
        roles: parsedRoles,
      );
    } on supabase.PostgrestException catch (e) {
      throw NetworkException(e.message);
    }
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
