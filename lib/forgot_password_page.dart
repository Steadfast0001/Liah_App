import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'sign_in_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    this.supabaseClient,
  });

  final SupabaseClient? supabaseClient;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _submitted = false;
  String? _errorMessage;

  SupabaseClient? get _client {
    if (widget.supabaseClient != null) return widget.supabaseClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _handleSendResetLink() async {
    _clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();

    try {
      final client = _client;
      if (client != null) {
        await client.auth.resetPasswordForEmail(email);
      }
    } catch (_) {
      // ACCEPTANCE CRITERIA: Do not reveal whether an email belongs to a registered account.
      // Regardless of whether the user exists or not, or if Supabase returns a user-not-found error,
      // we gracefully suppress enumeration details and display the neutral confirmation message.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _submitted = true;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Enter your email address';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _navigateToSignIn() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Forgot Password',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Institutional Header
                    Center(
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
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Reset Your Password',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your institutional email address and we will send you instructions to reset your password.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Confirmation Card (when submitted)
                    if (_submitted) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13204D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.mark_email_read_outlined,
                              color: AppColors.gold,
                              size: 38,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Request Submitted',
                              style: TextStyle(
                                color: AppColors.onNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'If this email is associated with a Liah Academy account, password reset instructions have been sent to your inbox.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _submitted = false;
                                });
                              },
                              icon: const Icon(
                                Icons.refresh,
                                size: 16,
                                color: AppColors.gold,
                              ),
                              label: const Text(
                                'Send another request',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Email Input Field
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: AppColors.onNavy),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _clearError(),
                      validator: _validateEmail,
                      onFieldSubmitted: (_) => _handleSendResetLink(),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'e.g. yourname@liah.com',
                        hintStyle: TextStyle(
                          color: AppColors.muted.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        labelStyle: const TextStyle(color: AppColors.muted),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
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
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Send Reset Link Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        disabledBackgroundColor:
                            AppColors.gold.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      onPressed: _isLoading ? null : _handleSendResetLink,
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
                              'Send Reset Link',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
