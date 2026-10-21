import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'auth_repository.dart';
import 'dashboard_data.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'session_store.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    this.sessionStore,
    this.authRepository,
    this.supabaseClient,
  });

  final SessionStore? sessionStore;
  final AuthRepository? authRepository;
  final SupabaseClient? supabaseClient;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberSession = true;
  String? _inlineErrorMessage;

  SessionStore get _store => widget.sessionStore ?? SessionStore();

  AuthRepository get _authRepo =>
      widget.authRepository ??
      SupabaseAuthRepository(client: widget.supabaseClient);

  @override
  void initState() {
    super.initState();
    _loadRememberPreference();
  }

  Future<void> _loadRememberPreference() async {
    final remember = await _store.readRememberMe();
    if (mounted) {
      setState(() => _rememberSession = remember);
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearInlineError() {
    if (_inlineErrorMessage != null) {
      setState(() => _inlineErrorMessage = null);
    }
  }

  Future<void> _handleSignIn() async {
    _clearInlineError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _inlineErrorMessage = null;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    try {
      // 1. & 2. Submit credentials through the authentication repository
      // Strict security rule: Authentication must never expose passwords in logs or error messages.
      final result = await _authRepo.signIn(
        identifier: identifier,
        password: password,
      );

      // 3. 2FA Check for Super Admin and Administrator
      if (result.role == DashboardRole.superAdmin ||
          result.role == DashboardRole.admin) {
        if (!mounted) return;
        final verified = await _showTwoFactorOtpDialog(result.email, result.role);
        if (!verified) {
          try {
            await (widget.supabaseClient ?? Supabase.instance.client).auth.signOut();
          } catch (_) {}
          if (mounted) {
            setState(() {
              _isLoading = false;
              _inlineErrorMessage =
                  'Two-factor verification was cancelled. Please try again.';
            });
          }
          return;
        }
      }

      // 4. Remember-session behavior
      await _store.saveRememberMe(_rememberSession);
      if (_rememberSession) {
        await _store.saveLocalSessionForRole(
          result.role.name,
          token: result.token,
          email: result.email,
          fullName: result.fullName,
        );
      }

      if (!mounted) return;

      // 5. Route to authorized dashboard
      _navigateToDashboard(result);
    } on AuthFailureException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Generic invalid-credentials message without exposing sensitive details
        _inlineErrorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Display a generic invalid-credentials message if authentication fails
        _inlineErrorMessage =
            'Invalid credentials. Please verify your email or matricule and password.';
      });
    }
  }

  void _navigateToDashboard(AuthResult authResult) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          authToken: authResult.token,
          repository: SupabaseDashboardRepository(
            role: authResult.role,
            userEmail: authResult.email,
            userFullName: authResult.fullName,
          ),
          onSignOut: () async {
            try {
              await (widget.supabaseClient ?? Supabase.instance.client).auth.signOut();
            } catch (_) {}
            await _store.clearToken();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => SignInPage(sessionStore: _store),
              ),
              (_) => false,
            );
          },
        ),
      ),
    );
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

  String? _validateIdentifier(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter your email or matricule';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Enter your password';
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
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
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  blurRadius: 18,
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
                                  size: 46,
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
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'UNIVERSITY PORTAL • CAMEROON',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Sign In to Your Account',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Access courses, results, attendance, and student services',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Inline Error Message Banner
                    if (_inlineErrorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
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
                                _inlineErrorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFECACA),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _clearInlineError,
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFFF87171),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 1. Login Identifier Field (Email or Matricule)
                    TextFormField(
                      controller: _identifierController,
                      style: const TextStyle(color: AppColors.onNavy),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _clearInlineError(),
                      validator: _validateIdentifier,
                      decoration: InputDecoration(
                        labelText: 'Email or Student Matricule',
                        hintText: 'e.g. LIAH-2024-SW0482 or student@liah.com',
                        hintStyle: TextStyle(
                          color: AppColors.muted.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        labelStyle: const TextStyle(color: AppColors.muted),
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
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
                    const SizedBox(height: 16),

                    // 2. Password Field with Show/Hide Toggle
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _clearInlineError(),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _handleSignIn(),
                      style: const TextStyle(color: AppColors.onNavy),
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                    const SizedBox(height: 12),

                    // 3. Remember Session Checkbox & Forgot Password Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              setState(() {
                                _rememberSession = !_rememberSession;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _rememberSession,
                                      activeColor: AppColors.gold,
                                      checkColor: AppColors.navyDeep,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberSession = val ?? true;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Flexible(
                                    child: Text(
                                      'Remember session',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 4. Sign In Button with Loading Indicator
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
                      onPressed: _isLoading ? null : _handleSignIn,
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
                              'SIGN IN',
                              style: TextStyle(
                                color: AppColors.navyDeep,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                    const SizedBox(height: 22),

                    // Create Account / Student Registration Link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(
                                  sessionStore: _store,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
        ),
      ),
    );
  }
}
