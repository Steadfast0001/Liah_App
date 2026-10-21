import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'forgot_password_page.dart';
import 'sign_in_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    this.supabaseClient,
    this.initialSessionValid,
  });

  final SupabaseClient? supabaseClient;

  /// Optional override for testing invalid/expired link states
  final bool? initialSessionValid;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSessionValid = true;
  String? _errorMessage;
  bool _passwordResetSuccess = false;

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
    _checkPasswordResetSession();
  }

  void _checkPasswordResetSession() {
    if (widget.initialSessionValid != null) {
      _isSessionValid = widget.initialSessionValid!;
      return;
    }

    final client = _client;
    if (client == null) {
      // In environment without client, default to requiring request
      _isSessionValid = false;
      return;
    }

    // Verify active recovery session
    final session = client.auth.currentSession;
    if (session == null) {
      _isSessionValid = false;
    } else {
      _isSessionValid = true;
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _handleSavePassword() async {
    _clearError();
    if (!_isSessionValid) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final newPassword = _newPasswordController.text;

    try {
      final client = _client;
      if (client == null || client.auth.currentSession == null) {
        throw const AuthException('Invalid or expired password reset session.');
      }

      // Security rule: Never print or log the password!
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _passwordResetSuccess = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      final msg = e.message.toLowerCase();
      final isExpired = msg.contains('expired') ||
          msg.contains('invalid') ||
          msg.contains('session') ||
          msg.contains('token');

      setState(() {
        _isLoading = false;
        if (isExpired) {
          _isSessionValid = false;
        } else {
          _errorMessage =
              'Failed to update password. Please ensure it satisfies security policy.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'An unexpected error occurred while updating password. Please try again.';
      });
    }
  }

  String? _validateNewPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Enter your new password';
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (_) => false,
    );
  }

  void _navigateToRequestNewLink() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onNavy),
          onPressed: _navigateToSignIn,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _passwordResetSuccess
                  ? _buildSuccessCard()
                  : (!_isSessionValid
                      ? _buildInvalidOrExpiredCard()
                      : _buildResetForm()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInstitutionalHeader(),
          const SizedBox(height: 28),

          const Text(
            'Create New Password',
            style: TextStyle(
              color: AppColors.onNavy,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your new password must be at least 6 characters long and match confirmation.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Inline Error Message (if any)
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1515),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF87171).withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFF87171),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFFECACA),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 1. New Password Field with Visibility Toggle
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _clearError(),
            validator: _validateNewPassword,
            style: const TextStyle(color: AppColors.onNavy),
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'At least 6 characters',
              hintStyle: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              labelStyle: const TextStyle(color: AppColors.muted),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.gold,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.gold,
                  width: 1.5,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.muted,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Confirm Password Field with Visibility Toggle
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _clearError(),
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) => _handleSavePassword(),
            style: const TextStyle(color: AppColors.onNavy),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your new password',
              hintStyle: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              labelStyle: const TextStyle(color: AppColors.muted),
              prefixIcon: const Icon(
                Icons.lock_reset_rounded,
                color: AppColors.gold,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.gold,
                  width: 1.5,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.muted,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Save Password Button with Loading Indicator
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
              disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 1,
            ),
            onPressed: _isLoading ? null : _handleSavePassword,
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
                    'Save Password',
                    style: TextStyle(
                      color: AppColors.navyDeep,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Back to Sign In Link
          Center(
            child: TextButton.icon(
              onPressed: _navigateToSignIn,
              icon: const Icon(
                Icons.arrow_back,
                size: 16,
                color: AppColors.gold,
              ),
              label: const Text(
                'Back to Sign In',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Acceptance Criteria: Invalid or expired reset links must produce a useful error
  /// and a route to request another link.
  Widget _buildInvalidOrExpiredCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInstitutionalHeader(),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
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
                Icons.link_off_rounded,
                color: Color(0xFFF87171),
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Invalid or Expired Reset Link',
                style: TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This password reset link is invalid or has expired for security reasons. Password reset links are single-use and time-sensitive.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _navigateToRequestNewLink,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text(
                  'Request Another Link',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onNavy,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _navigateToSignIn,
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInstitutionalHeader(),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.gold,
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'Password Updated Successfully',
                style: TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your password has been changed. You can now use your new credentials to sign in to your Liah Academy account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _navigateToSignIn,
                child: const Text(
                  'Sign In Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstitutionalHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(
                  Icons.school,
                  size: 44,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'LIAH ACADEMY',
            style: TextStyle(
              color: AppColors.onNavy,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
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
        ],
      ),
    );
  }
}
