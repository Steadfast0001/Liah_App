import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/session_timeout_listener.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class LiahAcademyApp extends ConsumerWidget {
  const LiahAcademyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Liah Academy',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SessionTimeoutListener(
          timeoutDuration: const Duration(minutes: 15),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
