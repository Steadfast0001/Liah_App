import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/forgot_password_page.dart';
import 'package:liah_app/sign_in_page.dart';

void main() {
  group('AUTH-03 — Forgot Password Page Tests', () {
    testWidgets('UI content renders Email input, Send Reset Link button, and Back to Sign In link',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordPage(),
        ),
      );

      // 1. Branding & Header
      expect(find.text('LIAH ACADEMY'), findsOneWidget);
      expect(find.text('UNIVERSITY PORTAL • CAMEROON'), findsOneWidget);
      expect(find.text('Reset Your Password'), findsOneWidget);

      // 2. Email input
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);

      // 3. Send Reset Link button
      expect(find.text('Send Reset Link'), findsOneWidget);

      // 4. Back to Sign In link
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('Validates email format on submission', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordPage(),
        ),
      );

      // 1. Test empty email
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your email address'), findsOneWidget);

      // 2. Test invalid email format
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'invalid-email-format',
      );
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets(
        'ACCEPTANCE CRITERIA: Submission displays neutral confirmation message without revealing account existence',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordPage(),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'student.nonexistent@liah.com',
      );

      // Submit reset request
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Neutral confirmation message is displayed
      expect(find.text('Request Submitted'), findsOneWidget);
      expect(
        find.text(
          'If this email is associated with a Liah Academy account, password reset instructions have been sent to your inbox.',
        ),
        findsOneWidget,
      );

      // Strict acceptance criteria: Must NEVER reveal account presence or lack thereof
      expect(find.textContaining('User not found'), findsNothing);
      expect(find.textContaining('Account does not exist'), findsNothing);
      expect(find.textContaining('Registered'), findsNothing);
    });

    testWidgets('Back to Sign In navigates cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SignInPage(),
          routes: {
            '/forgot': (_) => const ForgotPasswordPage(),
          },
        ),
      );

      // Tap Forgot Password on SignInPage
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);

      // Tap Back to Sign In
      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
    });
  });
}
