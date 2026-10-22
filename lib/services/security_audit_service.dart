import 'package:flutter/foundation.dart';

/// Centralized security and audit logger that enforces redaction of credentials,
/// passwords, tokens, and payment card details before output or persistence.
class SecurityAuditService {
  static const Set<String> sensitiveKeys = {
    'password',
    'newpassword',
    'oldpassword',
    'confirmPassword',
    'token',
    'accesstoken',
    'refreshtoken',
    'secret',
    'pin',
    'cvv',
    'cardnumber',
    'pan',
    'apikey',
    'authorization',
  };

  /// Redacts sensitive keys from maps and dictionaries
  static Map<String, dynamic> scrubPayload(Map<String, dynamic> data) {
    final scrubbed = <String, dynamic>{};

    for (final entry in data.entries) {
      final keyClean = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

      if (sensitiveKeys.contains(keyClean)) {
        scrubbed[entry.key] = '[REDACTED]';
      } else if (entry.value is Map<String, dynamic>) {
        scrubbed[entry.key] = scrubPayload(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        scrubbed[entry.key] = (entry.value as List).map((item) {
          if (item is Map<String, dynamic>) {
            return scrubPayload(item);
          }
          return item;
        }).toList();
      } else {
        scrubbed[entry.key] = entry.value;
      }
    }

    return scrubbed;
  }

  /// Logs sensitive actions safely without credential exposure
  static void logAction({
    required String action,
    required String actorId,
    required String entityType,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) {
    final sanitized = scrubPayload(metadata);

    if (kDebugMode) {
      debugPrint(
        '[AUDIT] Action: $action | Actor: $actorId | Target: $entityType${entityId != null ? "($entityId)" : ""} | Data: $sanitized',
      );
    }
  }

  /// Verifies if a user session satisfies Multi-Factor Authentication (MFA / AAL2)
  static bool isPrivilegedSessionAal2(Map<String, dynamic>? jwtClaims) {
    if (jwtClaims == null) return false;
    final aal = jwtClaims['aal']?.toString().toLowerCase();
    return aal == 'aal2';
  }

  /// Idempotency tracker: returns whether an event hash has already been processed
  static bool isEventProcessed(Set<String> processedHashes, String eventId, String provider) {
    final key = '$provider:$eventId';
    return processedHashes.contains(key);
  }
}
