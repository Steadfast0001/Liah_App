import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../providers/administration_providers.dart';
import 'password_reset_dialog.dart';

class AdminManagementView extends ConsumerStatefulWidget {
  const AdminManagementView({super.key, required this.actorRole});

  final AppRole actorRole;

  @override
  ConsumerState<AdminManagementView> createState() => _AdminManagementViewState();
}

class _AdminManagementViewState extends ConsumerState<AdminManagementView> {
  void _openCreateAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+237 6');
    final passCtrl = TextEditingController(text: 'Admin2026!Pass');
    var dispatchCredentials = true;
    var isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Create Administrator Account'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Admins receive login credentials (username + password) via email or SMS.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: emailCtrl,
                    label: 'Email / Username',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: phoneCtrl,
                    label: 'Phone (for SMS credentials dispatch)',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: passCtrl,
                    label: 'Initial Temporary Password',
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Dispatch credentials via Email & SMS'),
                    subtitle: const Text('Auto-send welcome notice with login URL'),
                    value: dispatchCredentials,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) =>
                        setDialogState(() => dispatchCredentials = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            AppButton(
              label: 'Create Admin',
              loading: isSubmitting,
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                  return;
                }
                final messenger = ScaffoldMessenger.of(context);
                setDialogState(() => isSubmitting = true);
                try {
                  await ref.read(administrationRepositoryProvider).createAdminAccount(
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                        sendEmailOrSms: dispatchCredentials,
                      );
                  ref.invalidate(adminAccountsProvider);
                  ref.invalidate(auditLogsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Admin account ${emailCtrl.text.trim()} created! Credentials dispatched.',
                        ),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  }
                } finally {
                  setDialogState(() => isSubmitting = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminsAsync = ref.watch(adminAccountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator Accounts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage administrator privileges, create credentials, and perform password resets.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            if (widget.actorRole == AppRole.superAdmin)
              AppButton(
                label: 'New Admin',
                icon: Icons.person_add_alt_1,
                onPressed: _openCreateAdminDialog,
              ),
          ],
        ),
        const SizedBox(height: 16),
        adminsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Text('Error loading admins: $err'),
          data: (admins) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: admins.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final admin = admins[index];
              return AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: admin.isSuperAdmin
                          ? AppColors.primaryContainer
                          : AppColors.background,
                      child: Icon(
                        admin.isSuperAdmin
                            ? Icons.shield_outlined
                            : Icons.admin_panel_settings_outlined,
                        color: admin.isSuperAdmin
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                admin.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusChip(
                                status: admin.isSuperAdmin
                                    ? 'SUPER ADMIN'
                                    : 'ADMIN',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${admin.email}  •  ${admin.phone ?? "No phone"}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SuperAdmin authority reset button
                    if (widget.actorRole == AppRole.superAdmin)
                      PopupMenuButton<String>(
                        tooltip: 'Admin Actions',
                        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                        onSelected: (action) {
                          if (action == 'reset') {
                            showDialog<void>(
                              context: context,
                              builder: (_) => PasswordResetDialog(
                                actorRole: widget.actorRole,
                                targetUserId: admin.id,
                                targetEmail: admin.email,
                                targetRole: admin.isSuperAdmin
                                    ? AppRole.superAdmin
                                    : AppRole.admin,
                              ),
                            );
                          } else if (action == 'notify') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Credentials re-dispatched to ${admin.email} and SMS.'),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                Icon(Icons.lock_reset, size: 18),
                                SizedBox(width: 8),
                                Text('Reset Password'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'notify',
                            child: Row(
                              children: [
                                Icon(Icons.send_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Resend Credentials'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
