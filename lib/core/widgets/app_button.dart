import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;

    final child = loading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyDeep,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.secondary => FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceRaised,
            foregroundColor: AppColors.onNavy,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.danger => FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        ),
    };

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, height: 48, child: button);
  }
}
