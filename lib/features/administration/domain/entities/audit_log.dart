import 'package:equatable/equatable.dart';

class AuditLogEntry extends Equatable {
  const AuditLogEntry({
    required this.id,
    required this.actorEmail,
    required this.actorRole,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.details,
    required this.createdAt,
    this.ipAddress,
  });

  final String id;
  final String actorEmail;
  final String actorRole;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final String? ipAddress;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id']?.toString() ?? '',
      actorEmail: json['actor_email']?.toString() ??
          json['actor_profile_id']?.toString() ??
          'system@liah.com',
      actorRole: json['actor_role']?.toString() ?? 'super_admin',
      action: json['action']?.toString() ?? 'SYSTEM_EVENT',
      entityType: json['entity_type']?.toString() ?? 'system',
      entityId: json['entity_id']?.toString(),
      details: (json['details'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      ipAddress: json['ip_address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'actor_email': actorEmail,
        'actor_role': actorRole,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
        'created_at': createdAt.toIso8601String(),
        'ip_address': ipAddress,
      };

  @override
  List<Object?> get props => [
        id,
        actorEmail,
        actorRole,
        action,
        entityType,
        entityId,
        details,
        createdAt,
        ipAddress,
      ];
}
