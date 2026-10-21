import 'package:flutter/material.dart';

import 'session_store.dart';
import 'splash_page.dart';

/// Entry point gatekeeper that delegates to [SplashPage]
/// to enforce server-side profile resolution and ensure no client
/// routes to a dashboard based only on a locally stored role string.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.sessionStore});

  final SessionStore sessionStore;

  @override
  Widget build(BuildContext context) {
    return SplashPage(sessionStore: sessionStore);
  }
}
