import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/administration_providers.dart';

class FeeConfigView extends ConsumerStatefulWidget {
  const FeeConfigView({super.key});

  @override
  ConsumerState<FeeConfigView> createState() => _FeeConfigViewState();
}

class _FeeConfigViewState extends ConsumerState<FeeConfigView> {
  final _tuitionCtrl = TextEditingController();
  final _regFeeCtrl = TextEditingController();
  final _minCreditsCtrl = TextEditingController();
  final _maxCreditsCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController();
  var _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _tuitionCtrl.dispose();
    _regFeeCtrl.dispose();
    _minCreditsCtrl.dispose();
    _maxCreditsCtrl.dispose();
    _penaltyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(feeConfigurationProvider);

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error loading configuration: $err'),
      data: (config) {
        if (!_initialized) {
          _tuitionCtrl.text = config.annualTuitionXaf.toString();
          _regFeeCtrl.text = config.registrationFeeXaf.toString();
          _minCreditsCtrl.text = config.minCreditUnits.toString();
          _maxCreditsCtrl.text = config.maxCreditUnits.toString();
          _penaltyCtrl.text = config.latePenaltyPercentage.toString();
          _initialized = true;
        }

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
                      'Tuition & Credit Boundaries',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SuperAdmin authority: Configure annual tuition, semester credit limits, and late penalties.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                AppButton(
                  label: 'Save Configuration',
                  icon: Icons.save_outlined,
                  loading: _isSaving,
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    try {
                      final updated = config.copyWith(
                        annualTuitionXaf: int.tryParse(_tuitionCtrl.text.trim()) ?? config.annualTuitionXaf,
                        registrationFeeXaf: int.tryParse(_regFeeCtrl.text.trim()) ?? config.registrationFeeXaf,
                        minCreditUnits: int.tryParse(_minCreditsCtrl.text.trim()) ?? config.minCreditUnits,
                        maxCreditUnits: int.tryParse(_maxCreditsCtrl.text.trim()) ?? config.maxCreditUnits,
                        latePenaltyPercentage: double.tryParse(_penaltyCtrl.text.trim()) ?? config.latePenaltyPercentage,
                      );
                      await ref.read(administrationRepositoryProvider).updateFeeConfiguration(updated);
                      ref.invalidate(feeConfigurationProvider);
                      ref.invalidate(auditLogsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tuition & Credit configuration saved! Logged in audit trail.'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSaving = false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 320,
                  child: AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.payments_outlined, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Fee Amounts (XAF)',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _tuitionCtrl,
                          label: 'Annual Tuition (XAF)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _regFeeCtrl,
                          label: 'Semester Registration Fee (XAF)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _penaltyCtrl,
                          label: 'Late Payment Penalty (%)',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.rule_outlined, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Semester Credit Bounds',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _minCreditsCtrl,
                          label: 'Minimum Credit Units (Default: 15)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _maxCreditsCtrl,
                          label: 'Maximum Credit Units (Default: 24)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Students must register within [Min, Max] credits. Course offerings validation strictly obeys these bounds.',
                            style: TextStyle(color: AppColors.primary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
