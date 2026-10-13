import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/edge_functions.dart';
import '../errors/app_exception.dart';

/// Invokes privileged backend actions. Never embed secrets in the client.
class EdgeFunctionClient {
  EdgeFunctionClient(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> invoke(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body ?? {},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (response.status >= 400 || data.containsKey('error')) {
          throw NetworkException(
            data['error']?.toString() ?? 'Request failed (${response.status})',
          );
        }
        return data;
      }
      if (data == null) return {};
      return {'data': data};
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['error'] != null) {
        throw NetworkException(details['error'].toString());
      }
      throw NetworkException(
        e.details?.toString() ?? e.reasonPhrase ?? 'Function invocation failed',
      );
    }
  }
}

/// Re-export names for convenience in features.
typedef EdgeFn = EdgeFunctions;
