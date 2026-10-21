import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard_data.dart';

class AuthResult {
  const AuthResult({
    required this.token,
    required this.role,
    required this.email,
    required this.fullName,
    this.matricule,
  });

  final String token;
  final DashboardRole role;
  final String email;
  final String fullName;
  final String? matricule;
}

class AuthFailureException implements Exception {
  const AuthFailureException([
    this.message =
        'Invalid credentials. Please verify your matricule or email and password.',
  ]);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<AuthResult> signIn({
    required String identifier,
    required String password,
  });
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client}) : _providedClient = client;

  final SupabaseClient? _providedClient;

  SupabaseClient? get _client {
    if (_providedClient != null) return _providedClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Resolves an identifier which may be an email or a Cameroonian university matricule.
  /// Examples of matricules: LIAH-2024-SW0482, LIAH/24/SWE/0891, LA-2024-SWE-1001, FE21A001.
  Future<String> resolveIdentifierToEmail(
    String identifier, {
    SupabaseClient? client,
  }) async {
    final trimmed = identifier.trim();
    if (trimmed.contains('@')) {
      return trimmed;
    }

    final targetClient = client ?? _client;
    if (targetClient != null) {
      // 1. Check students table joined with profiles table
      try {
        final studentRow = await targetClient
            .from('students')
            .select('matricule, profiles(email, full_name)')
            .ilike('matricule', trimmed)
            .maybeSingle()
            .timeout(const Duration(seconds: 3));

        if (studentRow != null && studentRow['profiles'] != null) {
          final profileData = studentRow['profiles'];
          if (profileData is Map<String, dynamic>) {
            final email = profileData['email']?.toString();
            if (email != null && email.isNotEmpty) {
              return email;
            }
          }
        }
      } catch (_) {}

      // 2. Check profiles table directly in case identifier matches email prefix
      try {
        final profileRow = await targetClient
            .from('profiles')
            .select('email')
            .ilike('email', '$trimmed%')
            .maybeSingle()
            .timeout(const Duration(seconds: 3));

        if (profileRow != null && profileRow['email'] != null) {
          final email = profileRow['email']?.toString();
          if (email != null && email.isNotEmpty) {
            return email;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback for demo student accounts or standard institutional domain mapping
    final lower = trimmed.toLowerCase();
    if (lower == 'student' ||
        lower.contains('sw0482') ||
        lower.contains('0891') ||
        lower.contains('0482') ||
        lower.contains('demo') ||
        lower.contains('student')) {
      return 'student@liah.com';
    }

    final sanitized = lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '$sanitized@liah.com';
  }

  @override
  Future<AuthResult> signIn({
    required String identifier,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthFailureException(
        'Authentication service unavailable. Please check your network connection.',
      );
    }

    final trimmedIdentifier = identifier.trim();
    if (trimmedIdentifier.isEmpty || password.isEmpty) {
      throw const AuthFailureException('Please enter both identifier and password.');
    }

    // Resolve identifier (matricule or email)
    final email = await resolveIdentifierToEmail(trimmedIdentifier, client: client);

    AuthResponse authResponse;
    try {
      // Security rule: Never log or print password!
      authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (_) {
      // Security rule: Display a generic invalid-credentials message. Never expose password.
      throw const AuthFailureException(
        'Invalid credentials. Please verify your email or matricule and password.',
      );
    } catch (_) {
      throw const AuthFailureException(
        'Invalid credentials. Please verify your email or matricule and password.',
      );
    }

    final user = authResponse.user;
    final session = authResponse.session;

    if (user == null || session == null) {
      throw const AuthFailureException(
        'Authentication failed. No active session established.',
      );
    }

    // Load the user's profile and authorized role assignments
    DashboardRole resolvedRole = DashboardRole.student;
    String? fullName;
    String? matricule;

    // A. Query profile_roles joined with roles
    try {
      final roleRows = await client
          .from('profile_roles')
          .select('roles(code, name)')
          .eq('profile_id', user.id)
          .timeout(const Duration(seconds: 4));

      for (final row in (roleRows as List<dynamic>)) {
        if (row is Map<String, dynamic>) {
          final roleData = row['roles'];
          if (roleData is Map<String, dynamic>) {
            final code = roleData['code']?.toString();
            if (code != null && code.isNotEmpty) {
              resolvedRole = DashboardRoleLabel.fromString(code);
              break;
            }
          } else if (roleData is List && roleData.isNotEmpty) {
            final first = roleData.first;
            if (first is Map<String, dynamic>) {
              final code = first['code']?.toString();
              if (code != null && code.isNotEmpty) {
                resolvedRole = DashboardRoleLabel.fromString(code);
                break;
              }
            }
          }
        }
      }
    } catch (_) {}

    // B. Check user metadata if profile_roles had no match
    if (resolvedRole == DashboardRole.student) {
      final metaRole = user.userMetadata?['role']?.toString();
      if (metaRole != null && metaRole.isNotEmpty) {
        resolvedRole = DashboardRoleLabel.fromString(metaRole);
      }
    }

    // C. Query full profile details
    try {
      final profile = await client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 4));

      if (profile != null) {
        fullName = profile['full_name'] as String?;
      }
    } catch (_) {}

    fullName ??= user.userMetadata?['full_name']?.toString() ??
        email.split('@').first;

    // D. If student, query official matricule
    if (resolvedRole == DashboardRole.student) {
      try {
        final studentRow = await client
            .from('students')
            .select('matricule')
            .eq('profile_id', user.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 4));

        if (studentRow != null) {
          matricule = studentRow['matricule']?.toString();
        }
      } catch (_) {}

      matricule ??= user.userMetadata?['matricule']?.toString() ??
          (trimmedIdentifier.contains('@') ? null : trimmedIdentifier);
    }

    return AuthResult(
      token: session.accessToken,
      role: resolvedRole,
      email: email,
      fullName: fullName,
      matricule: matricule,
    );
  }
}
