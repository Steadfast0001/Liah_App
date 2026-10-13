import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class PermissionDenied extends StatelessWidget {
  const PermissionDenied({
    super.key,
    this.message = 'You do not have permission to view or perform this action.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 52,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            Text(
              'Access Restricted',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.border, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
