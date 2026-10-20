import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'auth_gate.dart';
import 'register_page.dart';
import 'session_store.dart';

const String _defaultSupabaseUrl = 'https://nqdlptrodovwbtqabxyu.supabase.co';
const String _defaultSupabaseAnonKey =
    'sb_publishable_IJRS0bZvdyJ0aaPSYhK8Fg_QTnV3hjr';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = _defaultSupabaseUrl;
  String supabaseAnonKey = _defaultSupabaseAnonKey;

  try {
    await dotenv.load(fileName: '.env');
    final envUrl = dotenv.env['SUPABASE_URL'] ??
        dotenv.env['NEXT_PUBLIC_SUPABASE_URL'];
    if (envUrl != null &&
        envUrl.trim().isNotEmpty &&
        !envUrl.contains('localhost') &&
        !envUrl.contains('127.0.0.1')) {
      supabaseUrl = envUrl.trim().replaceAll('"', '').replaceAll("'", '');
    }

    final envKey = dotenv.env['SUPABASE_ANON_KEY'] ??
        dotenv.env['NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY'];
    if (envKey != null &&
        envKey.trim().isNotEmpty &&
        !envKey.contains('your-anon-key')) {
      supabaseAnonKey = envKey.trim().replaceAll('"', '').replaceAll("'", '');
    }
  } catch (_) {}

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.sessionStore});

  final SessionStore? sessionStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liah Academy',
      routes: {'/register': (context) => const RegisterPage()},
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.gold,
          surface: AppColors.surface,
          onPrimary: AppColors.navyDeep,
          onSecondary: AppColors.navyDeep,
          onSurface: AppColors.onNavy,
          error: AppColors.gold,
          onError: AppColors.navyDeep,
        ),
        scaffoldBackgroundColor: AppColors.navy,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.onNavy,
          elevation: 0,
        ),
        dividerColor: AppColors.border,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: AppColors.muted),
          hintStyle: TextStyle(color: AppColors.muted),
        ),
      ),
      home: AuthGate(sessionStore: sessionStore ?? SessionStore()),
    );
  }
}
