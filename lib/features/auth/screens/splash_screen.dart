import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import 'login_screen.dart';
import '../../dashboard/screens/role_dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const routePath = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final session = await ref.read(authRepositoryProvider).currentSession();
    if (!mounted) return;
    if (session != null) {
      context.go(RoleDashboardScreen.routePath);
    } else {
      context.go(LoginScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authSessionProvider);
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64),
            SizedBox(height: 16),
            Text('Liah Academy'),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
