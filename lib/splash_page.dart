import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'dashboard_data.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'session_store.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.sessionStore,
    this.supabaseClient,
  });

  final SessionStore? sessionStore;
  final SupabaseClient? supabaseClient;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isLoading = true;
  String? _errorMessage;

  SessionStore get _store => widget.sessionStore ?? SessionStore();

  SupabaseClient? get _client {
    if (widget.supabaseClient != null) return widget.supabaseClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSessionAndProfile();
    });
  }

  Future<void> _restoreSessionAndProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = _client;

      // 1. Check if Supabase client is available
      if (client == null) {
        // Without a backend client, check if there is even a local token
        final localToken = await _store.readToken();
        if (localToken == null || localToken.isEmpty) {
          _navigateToLogin();
          return;
        }

        // Acceptance Criteria: The app must NOT route a user to a dashboard
        // based only on a locally stored role string.
        // Since no server client is available to verify the profile, show recoverable error.
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Institutional server unavailable. For security compliance, '
              'access cannot be granted based only on a locally cached role.';
        });
        return;
      }

      // 2. Check active Supabase authentication session
      final currentSession = client.auth.currentSession;
      final currentUser = client.auth.currentUser;

      if (currentSession == null || currentUser == null) {
        // User is unauthenticated in Supabase
        final localToken = await _store.readToken();
        if (localToken == null || localToken.isEmpty) {
          _navigateToLogin();
          return;
        }

        // Token exists locally but Supabase has no session:
        // We must NOT blindly trust local role string.
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Session expired or invalid. Please sign in again to verify your credentials.';
        });
        return;
      }

      // 3. Authenticated: Load user's authorized profile from the server
      DashboardRole? resolvedRole;
      String? fullName;

      try {
        // Query profile_roles joined with roles table
        final roleRows = await client
            .from('profile_roles')
            .select('roles(code, name)')
            .eq('profile_id', currentUser.id)
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
      } catch (e) {
        // Database query failed: do not fallback to locally stored role
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Network error while verifying authorized roles: ${e.toString()}';
        });
        return;
      }

      // If profile_roles had no specific assignment, check user metadata from server-issued JWT
      if (resolvedRole == null) {
        final metaRole = currentUser.userMetadata?['role']?.toString();
        if (metaRole != null && metaRole.isNotEmpty) {
          resolvedRole = DashboardRoleLabel.fromString(metaRole);
        }
      }

      // Default to student if user exists in auth with no elevated permissions
      resolvedRole ??= DashboardRole.student;

      // Query full profile details from profiles table
      try {
        final profile = await client
            .from('profiles')
            .select('full_name')
            .eq('id', currentUser.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 4));
        if (profile != null) {
          fullName = profile['full_name'] as String?;
        }
      } catch (_) {}

      fullName ??= currentUser.userMetadata?['full_name']?.toString() ??
          currentUser.email?.split('@').first;

      // Update local storage cache now that server verified it
      try {
        await _store.saveLocalSessionForRole(
          resolvedRole.name,
          token: currentSession.accessToken,
          email: currentUser.email,
          fullName: fullName,
        );
      } catch (_) {}

      if (!mounted) return;

      // 4. Route to authorized dashboard
      _navigateToDashboard(
        token: currentSession.accessToken,
        role: resolvedRole,
        email: currentUser.email,
        fullName: fullName,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to restore session or load profile. Please check your network connection and retry.';
      });
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginPage(sessionStore: _store),
      ),
    );
  }

  void _navigateToDashboard({
    required String token,
    required DashboardRole role,
    String? email,
    String? fullName,
  }) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          authToken: token,
          repository: SupabaseDashboardRepository(
            role: role,
            userEmail: email,
            userFullName: fullName,
          ),
          onSignOut: () async {
            try {
              await _client?.auth.signOut();
            } catch (_) {}
            await _store.clearToken();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginPage(sessionStore: _store),
              ),
              (_) => false,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Institutional Logo
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.school,
                        size: 56,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. App Name & Title
                const Text(
                  'LIAH ACADEMY',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'UNIVERSITY PORTAL • CAMEROON',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 36),

                // 3. Dynamic State: Loading Indicator OR Recoverable Error
                if (_isLoading) ...[
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Restoring session & verifying access...',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ] else if (_errorMessage != null) ...[
                  // Recoverable Error Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13204D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF87171).withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: Color(0xFFF87171),
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Profile Verification Failed',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.navyDeep,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _restoreSessionAndProfile,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.onNavy,
                                  side: const BorderSide(
                                      color: AppColors.border),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _navigateToLogin,
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // 4. Optional Version Number
                const Text(
                  'Version 1.0.0 • MINESUP Standards',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
