import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ??
      dotenv.env['NEXT_PUBLIC_SUPABASE_URL'] ??
      'https://nqdlptrodovwbtqabxyu.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      dotenv.env['NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY'] ??
      'sb_publishable_IJRS0bZvdyJ0aaPSYhK8Fg_QTnV3hjr';
}
