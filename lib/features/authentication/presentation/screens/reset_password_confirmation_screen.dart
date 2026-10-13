import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'login_screen.dart';

class ResetPasswordConfirmationScreen extends StatelessWidget {
  const ResetPasswordConfirmationScreen({
    super.key,
    this.email,
  });

  static const routePath = '/reset-password-confirmation';

  final String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Your Email')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: AppColors.navy,
                ),
                const SizedBox(height: 16),
                Text(
                  'Recovery Link Sent',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  email != null && email!.isNotEmpty
                      ? 'If an account exists for $email, a password reset link has been sent.'
                      : 'If an account exists for that email address, a password reset link has been sent.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Back to Sign In',
                  fullWidth: true,
                  onPressed: () => context.go(LoginScreen.routePath),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
