import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:liah_app/features/authentication/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Login screen builds', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    expect(find.text('Liah Academy SMS'), findsOneWidget);
  });
}
