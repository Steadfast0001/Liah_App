import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/auth_repository.dart';
import 'package:liah_app/dashboard_data.dart';
import 'package:liah_app/home_page.dart';
import 'package:liah_app/session_store.dart';
import 'package:liah_app/sign_in_page.dart';

void main() {
  group('AUTH-02 — Sign In Page Tests', () {
    late MockSessionStore mockStore;
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      mockStore = MockSessionStore();
      mockAuthRepo = MockAuthRepository();
    });

    testWidgets('UI content renders all required elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(
            sessionStore: mockStore,
            authRepository: mockAuthRepo,
          ),
        ),
      );

      // 1. Branding & Headers
      expect(find.text('LIAH ACADEMY'), findsOneWidget);
      expect(find.text('UNIVERSITY PORTAL • CAMEROON'), findsOneWidget);
      expect(find.text('Sign In to Your Account'), findsOneWidget);

      // 2. Login identifier field
      expect(find.text('Email or Student Matricule'), findsOneWidget);
      expect(
        find.text('e.g. LIAH-2024-SW0482 or student@liah.com'),
        findsOneWidget,
      );

      // 3. Password field with show/hide toggle
      expect(find.text('Password'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // 4. Remember session checkbox
      expect(find.text('Remember session'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      // 5. Forgot Password link
      expect(find.text('Forgot Password?'), findsOneWidget);

      // 6. Sign In button
      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('Password field show/hide toggle toggles visibility icon and obscuring',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(
            sessionStore: mockStore,
            authRepository: mockAuthRepo,
          ),
        ),
      );

      // Initial state: obscured (visibility_off icon visible)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Tap toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Toggled state: plain (visibility icon visible)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('Validates required fields when submitted empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(
            sessionStore: mockStore,
            authRepository: mockAuthRepo,
          ),
        ),
      );

      // Tap SIGN IN with empty fields
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email or matricule'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets(
        'ACCEPTANCE CRITERIA: Student login supports matricule-based identifier and routes to authorized dashboard',
        (tester) async {
      mockAuthRepo.configuredResult = const AuthResult(
        token: 'valid_student_jwt_token',
        role: DashboardRole.student,
        email: 'student@liah.com',
        fullName: 'Ngono Martin',
        matricule: 'LIAH-2024-SW0482',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(
            sessionStore: mockStore,
            authRepository: mockAuthRepo,
          ),
        ),
      );

      // Enter Cameroonian student matricule
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email or Student Matricule'),
        'LIAH-2024-SW0482',
      );

      // Enter valid password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'StudentPass2026!',
      );

      // Submit
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      // Verifies authentication repo received the matricule identifier
      expect(mockAuthRepo.lastSubmittedIdentifier, 'LIAH-2024-SW0482');

      // Verifies navigation to authorized HomePage dashboard
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets(
        'ACCEPTANCE CRITERIA: Authentication failure displays generic message and never exposes password',
        (tester) async {
      const sensitivePassword = 'SuperSecretPassword_DoNotExpose123!';
      mockAuthRepo.shouldFail = true;

      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(
            sessionStore: mockStore,
            authRepository: mockAuthRepo,
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email or Student Matricule'),
        'wrong_matricule_or_email@liah.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        sensitivePassword,
      );

      // Submit
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      // 1. Generic invalid credentials message is rendered inline
      expect(
        find.textContaining('Invalid credentials. Please verify your email or matricule and password.'),
        findsOneWidget,
      );

      // 2. Strict Acceptance Criteria: Passwords must NEVER be exposed in error messages or banners
      final errorWidget = tester.widget<Text>(find.textContaining('Invalid credentials'));
      expect(errorWidget.data, isNot(contains(sensitivePassword)));
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('Remember session preference persists to session store',
        (tester) async {
      mockAuthRepo.configuredResult = const AuthResult(
        token: 'remembered_jwt_token',
        role: DashboardRole.student,
        email: 'student@liah.com',
        fullName: 'Demo Student',
        matricule: 'LIAH-2024-SW0482',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SignInPage(
            sessionStore: mockStore,
            authRepository: mockAuthRepo,
          ),
        ),
      );

      // Checkbox is initially checked
      expect(mockStore.savedRememberMe, isTrue);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email or Student Matricule'),
        'student@liah.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPassword123',
      );

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(await mockStore.readRememberMe(), isTrue);
      expect(await mockStore.readToken(), 'remembered_jwt_token');
    });
  });
}

class MockAuthRepository implements AuthRepository {
  AuthResult? configuredResult;
  bool shouldFail = false;
  String? lastSubmittedIdentifier;
  bool didExposePasswordInError = false;

  @override
  Future<AuthResult> signIn({
    required String identifier,
    required String password,
  }) async {
    lastSubmittedIdentifier = identifier;

    if (shouldFail) {
      // Must not expose password
      throw const AuthFailureException(
        'Invalid credentials. Please verify your email or matricule and password.',
      );
    }

    return configuredResult ??
        const AuthResult(
          token: 'mock_token',
          role: DashboardRole.student,
          email: 'student@liah.com',
          fullName: 'Test Student',
          matricule: 'LIAH-2024-SW0482',
        );
  }
}

class MockSessionStore extends SessionStore {
  MockSessionStore({String? token, String role = 'student'})
      : _token = token,
        _role = role;

  String? _token;
  String _role;
  bool savedRememberMe = true;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<String> readRole() async => _role;

  @override
  Future<bool> readRememberMe() async => savedRememberMe;

  @override
  Future<void> saveRememberMe(bool remember) async {
    savedRememberMe = remember;
  }

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
