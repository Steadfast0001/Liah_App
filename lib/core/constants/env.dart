import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  static String get appEnv => dotenv.env['APP_ENV']?.trim() ?? 'development';

  static String get supabaseUrl {
    final raw = (dotenv.env['SUPABASE_URL'] ??
            dotenv.env['NEXT_PUBLIC_SUPABASE_URL'] ??
            '')
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (raw.isEmpty || raw.contains('127.0.0.1:54321') || raw.contains('localhost:54321')) {
      return 'https://nqdlptrodovwbtqabxyu.supabase.co';
    }
    return raw;
  }

  static String get supabaseAnonKey {
    final raw = (dotenv.env['SUPABASE_ANON_KEY'] ??
            dotenv.env['NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY'] ??
            '')
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (raw.isEmpty || raw == 'your-anon-key' || raw.contains('your-anon-key')) {
      return 'sb_publishable_IJRS0bZvdyJ0aaPSYhK8Fg_QTnV3hjr';
    }
    return raw;
  }
}
