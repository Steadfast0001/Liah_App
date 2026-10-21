import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/login_page.dart';
import 'package:liah_app/session_store.dart';
import 'package:liah_app/splash_page.dart';

void main() {
  group('AUTH-01 — SplashPage Tests', () {
    testWidgets('UI content contains logo, app name, loading indicator, and version number',
        (tester) async {
      final mockStore = MockSessionStore(token: null);

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionStore: mockStore),
        ),
      );

      // Verify immediate UI components before post-frame callback navigation
      expect(find.text('LIAH ACADEMY'), findsOneWidget);
      expect(find.text('UNIVERSITY PORTAL • CAMEROON'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Restoring session & verifying access...'), findsOneWidget);
      expect(find.text('Version 1.0.0 • MINESUP Standards'), findsOneWidget);
    });

    testWidgets('Unauthenticated session routes to LoginPage', (tester) async {
      final mockStore = MockSessionStore(token: null);

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionStore: mockStore),
        ),
      );

      // Let post-frame callback run and navigation resolve
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('LIAH ACADEMY'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets(
        'ACCEPTANCE CRITERIA: App must NOT route to dashboard based only on a locally stored role string',
        (tester) async {
      // Setup a store that has a local token and local role string ('super_admin'),
      // but backend client is unavailable/unconfigured in test environment.
      final mockStore = MockSessionStore(
        token: 'cached_jwt_token_without_server_confirmation',
        role: 'super_admin',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionStore: mockStore),
        ),
      );

      // Let post-frame callback run
      await tester.pumpAndSettle();

      // Must NOT navigate to dashboard or login; must display recoverable error
      expect(find.text('Profile Verification Failed'), findsOneWidget);
      expect(
        find.textContaining('For security compliance, access cannot be granted based only on a locally cached role.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('Recoverable error container lets user navigate to Sign In',
        (tester) async {
      final mockStore = MockSessionStore(
        token: 'cached_jwt_token',
        role: 'admin',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionStore: mockStore),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Sign In button
      expect(find.text('Sign In'), findsOneWidget);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Confirms navigation to LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
    });
  });
}

class MockSessionStore extends SessionStore {
  MockSessionStore({String? token, String role = 'student'})
      : _token = token,
        _role = role;

  String? _token;
  String _role;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<String> readRole() async => _role;

  @override
  Future<void> saveLocalSessionForRole(
    String role, {
    String? token,
    String? email,
    String? fullName,
  }) async {
    _token = token ?? _token;
    _role = role;
  }

  @override
  Future<void> clearToken() async {
    _token = null;
    _role = 'student';
  }
}
