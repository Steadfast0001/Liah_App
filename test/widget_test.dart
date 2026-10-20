import 'package:flutter_test/flutter_test.dart';

import 'package:liah_app/login_page.dart';
import 'package:liah_app/main.dart';
import 'package:liah_app/session_store.dart';

void main() {
  testWidgets('MyApp builds and shows login page when unauthenticated',
      (tester) async {
    final mockStore = MockSessionStore();
    await tester.pumpWidget(MyApp(sessionStore: mockStore));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('LIAH ACADEMY'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}

class MockSessionStore extends SessionStore {
  String? _token;
  String _role = 'student';

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
    _token = token ?? 'mock_token';
    _role = role;
  }

  @override
  Future<void> clearToken() async {
    _token = null;
    _role = 'student';
  }
}
