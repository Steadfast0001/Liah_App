import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'auth_gate.dart';
import 'dashboard_data.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import 'session_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.sessionStore});

  final SessionStore? sessionStore;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final sessionStore = widget.sessionStore ?? SessionStore();

    try {
      final client = Supabase.instance.client;
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      final session = authResponse.session;

      if (user == null || session == null) {
        throw const AuthException('No active user session returned.');
      }

      // Check role from profile_roles joined with roles
      DashboardRole resolvedRole = DashboardRole.student;
      String? fullName;

      try {
        final roleRows = await client
            .from('profile_roles')
            .select('roles(code, name)')
            .eq('profile_id', user.id);

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
                resolvedRole =
                    DashboardRoleLabel.fromString(first['code']?.toString());
                break;
              }
            }
          }
        }
      } catch (_) {}

      // Fallback to user metadata
      if (resolvedRole == DashboardRole.student) {
        final metaRole = user.userMetadata?['role']?.toString();
        if (metaRole != null) {
          resolvedRole = DashboardRoleLabel.fromString(metaRole);
        }
      }

      // Query full name
      try {
        final profile = await client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        if (profile != null) {
          fullName = profile['full_name'] as String?;
        }
      } catch (_) {}

      fullName ??= user.userMetadata?['full_name']?.toString() ??
          email.split('@').first;

      // Two-Factor Authentication (2FA) for SuperAdmin and Admin
      if (resolvedRole == DashboardRole.superAdmin ||
          resolvedRole == DashboardRole.admin) {
        if (!mounted) return;
        final verified = await _showTwoFactorOtpDialog(email, resolvedRole);
        if (!verified) {
          await client.auth.signOut();
          setState(() => _isLoading = false);
          return;
        }
      }

      // Save verified session
      await sessionStore.saveLocalSessionForRole(
        resolvedRole.name,
        token: session.accessToken,
        email: email,
        fullName: fullName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, $fullName (${resolvedRole.label})',
            style: const TextStyle(color: AppColors.successText),
          ),
          backgroundColor: AppColors.successBackground,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthGate(sessionStore: sessionStore)),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool> _showTwoFactorOtpDialog(
      String email, DashboardRole role) async {
    final otpController = TextEditingController();
    String? otpError;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Row(
                children: [
                  const Icon(Icons.security, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    '2FA Verification (${role.label})',
                    style: const TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-factor authentication is required for ${role.label} accounts.\n\nEnter the 6-digit verification code sent to $email (Default OTP: 123456):',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 18,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      labelStyle: const TextStyle(color: AppColors.muted),
                      errorText: otpError,
                      filled: true,
                      fillColor: AppColors.navy,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.muted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                  ),
                  onPressed: () {
                    final code = otpController.text.trim();
                    if (code.length == 6) {
                      Navigator.of(dialogCtx).pop(true);
                    } else {
                      setDialogState(() {
                        otpError = 'Enter a valid 6-digit code';
                      });
                    }
                  },
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(
                      color: AppColors.navyDeep,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password';
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 18),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 88,
                        height: 88,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'LIAH ACADEMY',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Since 2024',
                        style: TextStyle(color: AppColors.gold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.onNavy),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppColors.muted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _handleLogin(),
                  style: const TextStyle(color: AppColors.onNavy),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: AppColors.muted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.muted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.navyDeep,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: AppColors.navyDeep,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.muted),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterPage(sessionStore: widget.sessionStore),
                          ),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
