import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../dashboard/presentation/screens/role_dashboard_screen.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/auth_providers.dart';
import 'forgot_password_screen.dart';
import 'two_factor_auth_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final rawInput = _emailController.text.trim();
    final normalizedEmail = rawInput.contains('@') ? rawInput : '$rawInput@liah.com';

    try {
      await ref.read(authRepositoryProvider).signInWithPassword(
            email: normalizedEmail,
            password: _passwordController.text,
          );
      ref.invalidate(currentUserProfileProvider);
      final profile = await ref.read(authRepositoryProvider).fetchCurrentUserProfile();
      if (!mounted) return;

      final role = profile?.primaryRole ?? AppRole.student;
      // 2FA Security Enhancement: Required for SuperAdmin and Admin
      if (role == AppRole.superAdmin || role == AppRole.admin) {
        context.go('${TwoFactorAuthScreen.routePath}?email=$normalizedEmail&role=${role.code}');
      } else {
        context.go(RoleDashboardScreen.routePath);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Sign in failed. Check your credentials.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fillDemo(String email) {
    _emailController.text = email;
    _passwordController.text = 'password123';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Liah Academy SMS',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unified Portal for Students, Lecturers, Admins & SuperAdmin',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email or Username ID',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email, AutofillHints.username],
                      validator: (v) => v != null && v.trim().isNotEmpty
                          ? null
                          : 'Enter your email or username',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : 'Minimum 6 characters',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.push(ForgotPasswordScreen.routePath),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Sign in',
                      loading: _loading,
                      fullWidth: true,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),
                    const Text(
                      'Quick Demo Login Accounts (Password: password123):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                          label: const Text('SuperAdmin'),
                          onPressed: () => _fillDemo('superadmin@liah.com'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.admin_panel_settings_outlined, size: 16, color: AppColors.primary),
                          label: const Text('Admin'),
                          onPressed: () => _fillDemo('admin@liah.com'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.co_present_outlined, size: 16, color: AppColors.primary),
                          label: const Text('Lecturer'),
                          onPressed: () => _fillDemo('lecturer@liah.com'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.school_outlined, size: 16, color: AppColors.primary),
                          label: const Text('Student'),
                          onPressed: () => _fillDemo('student@liah.com'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
