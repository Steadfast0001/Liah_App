import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'edge_function_client.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final edgeFunctionClientProvider = Provider<EdgeFunctionClient>((ref) {
  return EdgeFunctionClient(ref.watch(supabaseClientProvider));
});
