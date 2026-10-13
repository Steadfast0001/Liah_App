import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'permission_denied.dart';

enum AsyncUiStatus { loading, empty, error, success, permissionDenied }

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.status,
    this.message,
    this.onRetry,
    required this.success,
  });

  final AsyncUiStatus status;
  final String? message;
  final VoidCallback? onRetry;
  final Widget success;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      AsyncUiStatus.loading => const Center(child: CircularProgressIndicator()),
      AsyncUiStatus.empty => EmptyState(
          title: message ?? 'Nothing here yet',
        ),
      AsyncUiStatus.error => ErrorState(
          message: message ?? 'Something went wrong',
          onRetry: onRetry,
        ),
      AsyncUiStatus.permissionDenied => PermissionDenied(
          message: message ?? 'You do not have access',
        ),
      AsyncUiStatus.success => success,
    };
  }
}
