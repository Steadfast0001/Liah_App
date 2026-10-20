import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'dashboard_data.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'session_store.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.sessionStore});

  final SessionStore sessionStore;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<_StoredSession?> _session = _readSession();

  Future<_StoredSession?> _readSession() async {
    final client = Supabase.instance.client;
    final currentSession = client.auth.currentSession;
    final currentUser = client.auth.currentUser;

    if (currentSession == null || currentUser == null) {
      final token = await widget.sessionStore.readToken();
      if ((token ?? '').isEmpty) return null;
      final roleStr = await widget.sessionStore.readRole();
      return _StoredSession(
        token: token!,
        role: DashboardRoleLabel.fromString(roleStr),
        email: await widget.sessionStore.readEmail(),
        fullName: await widget.sessionStore.readFullName(),
      );
    }

    // Resolve real role from database
    DashboardRole resolvedRole = DashboardRole.student;
    String? fullName;

    try {
      final roleRows = await client
          .from('profile_roles')
          .select('roles(code, name)')
          .eq('profile_id', currentUser.id);

      for (final row in (roleRows as List<dynamic>)) {
        if (row is Map<String, dynamic>) {
          final roleData = row['roles'];
          if (roleData is Map<String, dynamic>) {
            final code = roleData['code']?.toString();
            resolvedRole = DashboardRoleLabel.fromString(code);
            break;
          } else if (roleData is List && roleData.isNotEmpty) {
            final first = roleData.first;
            if (first is Map<String, dynamic>) {
              resolvedRole = DashboardRoleLabel.fromString(first['code']?.toString());
              break;
            }
          }
        }
      }
    } catch (_) {}

    // Fallback to user metadata role
    if (resolvedRole == DashboardRole.student) {
      final metaRole = currentUser.userMetadata?['role']?.toString();
      if (metaRole != null) {
        resolvedRole = DashboardRoleLabel.fromString(metaRole);
      }
    }

    try {
      final profile = await client
          .from('profiles')
          .select('full_name')
          .eq('id', currentUser.id)
          .maybeSingle();
      if (profile != null) {
        fullName = profile['full_name'] as String?;
      }
    } catch (_) {}

    fullName ??= currentUser.userMetadata?['full_name']?.toString() ??
        currentUser.email?.split('@').first;

    await widget.sessionStore.saveLocalSessionForRole(
      resolvedRole.name,
      token: currentSession.accessToken,
      email: currentUser.email,
      fullName: fullName,
    );

    return _StoredSession(
      token: currentSession.accessToken,
      role: resolvedRole,
      email: currentUser.email,
      fullName: fullName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StoredSession?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SessionLoadingScreen();
        }
        final session = snapshot.data;
        if (session == null) {
          return LoginPage(sessionStore: widget.sessionStore);
        }
        return HomePage(
          authToken: session.token,
          repository: SupabaseDashboardRepository(
            role: session.role,
            userEmail: session.email,
            userFullName: session.fullName,
          ),
          onSignOut: () async {
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (_) {}
            await widget.sessionStore.clearToken();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginPage(sessionStore: widget.sessionStore),
              ),
              (_) => false,
            );
          },
        );
      },
    );
  }
}

class _StoredSession {
  const _StoredSession({
    required this.token,
    required this.role,
    this.email,
    this.fullName,
  });

  final String token;
  final DashboardRole role;
  final String? email;
  final String? fullName;
}

class _SessionLoadingScreen extends StatelessWidget {
  const _SessionLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 112,
              errorBuilder: _fallbackLogo,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  static Widget _fallbackLogo(BuildContext ctx, Object err, StackTrace? stack) {
    return const Icon(Icons.school, size: 80, color: AppColors.gold);
  }
}
