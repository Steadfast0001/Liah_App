import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../providers/administration_providers.dart';

class PasswordResetDialog extends ConsumerStatefulWidget {
  const PasswordResetDialog({
    super.key,
    required this.actorRole,
    required this.targetUserId,
    required this.targetEmail,
    required this.targetRole,
  });

  final AppRole actorRole;
  final String targetUserId;
  final String targetEmail;
  final AppRole targetRole;

  @override
  ConsumerState<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends ConsumerState<PasswordResetDialog> {
  final _passwordController = TextEditingController(text: 'Liah2026!Reset');
  var _loading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final newPass = _passwordController.text.trim();
    if (newPass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      await ref.read(administrationRepositoryProvider).resetAccountPassword(
            targetUserId: widget.targetUserId,
            targetEmail: widget.targetEmail,
            targetRole: widget.targetRole,
            actorRole: widget.actorRole,
            newPassword: newPass,
          );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _success = 'Password successfully reset for ${widget.targetEmail}';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop(true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canReset = widget.actorRole == AppRole.superAdmin ||
        (widget.actorRole == AppRole.admin &&
            widget.targetRole != AppRole.superAdmin &&
            widget.targetRole != AppRole.admin);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Reset Account Password'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Account: ${widget.targetEmail}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${widget.targetRole.label}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!canReset) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Authority Restriction: Only SuperAdmin accounts have authority to reset ${widget.targetRole.label} accounts.',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              AppTextField(
                controller: _passwordController,
                label: 'New Temporary Password',
                prefixIcon: Icons.vpn_key_outlined,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: 8),
                Text(
                  _success!,
                  style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        if (canReset)
          AppButton(
            label: 'Confirm Reset',
            loading: _loading,
            onPressed: _handleReset,
          ),
      ],
    );
  }
}
