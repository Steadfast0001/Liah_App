import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/forgot_password_page.dart';
import 'package:liah_app/reset_password_page.dart';
import 'package:liah_app/sign_in_page.dart';

void main() {
  group('AUTH-04 — Reset Password Page Tests', () {
    testWidgets('UI content renders New password, Confirm password, toggles, and Save Password button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordPage(
            initialSessionValid: true,
          ),
        ),
      );

      // 1. Branding & Header
      expect(find.text('LIAH ACADEMY'), findsOneWidget);
      expect(find.text('UNIVERSITY PORTAL • CAMEROON'), findsOneWidget);
      expect(find.text('Create New Password'), findsOneWidget);

      // 2. New password field
      expect(find.text('New Password'), findsOneWidget);

      // 3. Confirm password field
      expect(find.text('Confirm Password'), findsOneWidget);

      // 4. Password visibility controls (two visibility_off icons initially)
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));

      // 5. Save Password button
      expect(find.text('Save Password'), findsOneWidget);
    });

    testWidgets('Password visibility controls independently toggle visibility',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordPage(
            initialSessionValid: true,
          ),
        ),
      );

      // Find all visibility toggles
      final visibilityIcons = find.byIcon(Icons.visibility_off);
      expect(visibilityIcons, findsNWidgets(2));

      // Tap first toggle (New password)
      await tester.tap(visibilityIcons.first);
      await tester.pumpAndSettle();

      // One icon is now visibility, the other remains visibility_off
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Validates password policy and matching confirmation fields',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordPage(
            initialSessionValid: true,
          ),
        ),
      );

      // 1. Empty submission
      await tester.tap(find.text('Save Password'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your new password'), findsOneWidget);

      // 2. Length policy (< 6 characters)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        '123',
      );
      await tester.tap(find.text('Save Password'));
      await tester.pumpAndSettle();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);

      // 3. Non-matching confirmation
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        'SecurePassword2026!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'DifferentPassword123',
      );
      await tester.tap(find.text('Save Password'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets(
        'ACCEPTANCE CRITERIA: Invalid or expired reset links produce a useful error and a route to request another link',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ResetPasswordPage(
            initialSessionValid: false,
          ),
          routes: {
            '/forgot-password': (_) => const ForgotPasswordPage(),
          },
        ),
      );

      // 1. Verifies useful error container is rendered
      expect(find.text('Invalid or Expired Reset Link'), findsOneWidget);
      expect(
        find.textContaining('This password reset link is invalid or has expired for security reasons.'),
        findsOneWidget,
      );

      // 2. Verifies action buttons
      expect(find.text('Request Another Link'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);

      // 3. Verifies route to request another link (ForgotPasswordPage)
      await tester.tap(find.text('Request Another Link'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('Back to Sign In button routes to SignInPage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordPage(
            initialSessionValid: false,
          ),
        ),
      );

      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
    });
  });
}
