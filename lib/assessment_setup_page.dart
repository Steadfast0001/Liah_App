import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';

class AssessmentComponent {
  String name;
  String type; // 'CA Assignment' | 'CA Mid-Term' | 'CA Practical' | 'Final Exam'
  double maxMark;
  double weightPercentage;
  String dueDate;

  AssessmentComponent({
    required this.name,
    required this.type,
    required this.maxMark,
    required this.weightPercentage,
    required this.dueDate,
  });
}

/// Assessment Setup Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Assessment components, maximum marks, dates and configured CA/exam weights.
/// Required interactions: Create/edit only when authorized; validate input.
class AssessmentSetupPage extends StatefulWidget {
  final String courseCode;
  final bool isAuthorized;

  const AssessmentSetupPage({
    super.key,
    this.courseCode = 'SWE201',
    this.isAuthorized = true,
  });

  @override
  State<AssessmentSetupPage> createState() => _AssessmentSetupPageState();
}

class _AssessmentSetupPageState extends State<AssessmentSetupPage> {
  late List<AssessmentComponent> _components;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _components = [
      AssessmentComponent(
        name: 'Continuous Assessment Assignment 1 (Data Structures)',
        type: 'CA Assignment',
        maxMark: 10,
        weightPercentage: 10,
        dueDate: '2026-10-30',
      ),
      AssessmentComponent(
        name: 'Mid-Semester Written Test',
        type: 'CA Mid-Term',
        maxMark: 20,
        weightPercentage: 20,
        dueDate: '2026-11-15',
      ),
      AssessmentComponent(
        name: 'Final Written Examination',
        type: 'Final Exam',
        maxMark: 70,
        weightPercentage: 70,
        dueDate: '2027-01-10',
      ),
    ];
  }

  double get _totalCaWeight {
    return _components
        .where((c) => c.type.startsWith('CA'))
        .fold(0.0, (sum, c) => sum + c.weightPercentage);
  }

  double get _examWeight {
    return _components
        .where((c) => c.type == 'Final Exam')
        .fold(0.0, (sum, c) => sum + c.weightPercentage);
  }

  double get _totalWeight => _totalCaWeight + _examWeight;

  bool get _isWeightDistributionValid {
    return (_totalCaWeight - 30.0).abs() < 0.01 &&
        (_examWeight - 70.0).abs() < 0.01 &&
        (_totalWeight - 100.0).abs() < 0.01;
  }

  void _showAddEditComponentModal([AssessmentComponent? existing, int? index]) {
    if (!widget.isAuthorized) return;

    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final maxMarkCtrl = TextEditingController(text: existing?.maxMark.toStringAsFixed(0) ?? '10');
    final weightCtrl = TextEditingController(text: existing?.weightPercentage.toStringAsFixed(0) ?? '10');
    final dateCtrl = TextEditingController(text: existing?.dueDate ?? '2026-11-20');
    String selectedType = existing?.type ?? 'CA Assignment';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                existing == null ? 'Add Assessment Component' : 'Edit Assessment Component',
                style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Component Title', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.navy,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Category Type', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButton<String>(
                        value: selectedType,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                        items: const [
                          DropdownMenuItem(value: 'CA Assignment', child: Text('CA Assignment (Max 10-15)')),
                          DropdownMenuItem(value: 'CA Mid-Term', child: Text('CA Mid-Term Test (Max 15-20)')),
                          DropdownMenuItem(value: 'CA Practical', child: Text('CA Practical / Lab (Max 10-20)')),
                          DropdownMenuItem(value: 'Final Exam', child: Text('Final Exam (Strictly 70%)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedType = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Max Raw Mark', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: maxMarkCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.navy,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Weight %', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: weightCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.navy,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Scheduled Date / Deadline', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: dateCtrl,
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.navy,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navyDeep),
                  onPressed: () {
                    final rawName = nameCtrl.text.trim();
                    final maxMark = double.tryParse(maxMarkCtrl.text) ?? 10.0;
                    final weight = double.tryParse(weightCtrl.text) ?? 10.0;
                    final date = dateCtrl.text.trim();

                    if (rawName.isEmpty) return;

                    setState(() {
                      if (existing == null) {
                        _components.add(
                          AssessmentComponent(
                            name: rawName,
                            type: selectedType,
                            maxMark: maxMark,
                            weightPercentage: weight,
                            dueDate: date,
                          ),
                        );
                      } else if (index != null) {
                        _components[index] = AssessmentComponent(
                          name: rawName,
                          type: selectedType,
                          maxMark: maxMark,
                          weightPercentage: weight,
                          dueDate: date,
                        );
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Component', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveAssessmentSetup() async {
    if (!_isWeightDistributionValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF5E1717),
          content: Text(
            'Cannot save: CA components must total 30% and Final Exam must be 70% (Total 100%).',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F5132),
        content: Text(
          'Assessment configuration for ${widget.courseCode} validated and saved successfully.',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: Text(
          '${widget.courseCode} Assessment Setup',
          style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.gold),
              tooltip: 'Add Assessment Component',
              onPressed: () => _showAddEditComponentModal(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Policy Guideline Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.rule, color: AppColors.gold, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MINESUP & Liah Academy Assessment Weights',
                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'All undergraduate degree courses require Continuous Assessment (CA) to constitute exactly 30% and Final Exam to constitute 70% of total grade.',
                          style: TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Weight Distribution Summary Bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isWeightDistributionValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CONFIGURED WEIGHT TOTALS',
                        style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isWeightDistributionValid
                              ? const Color(0xFF0F5132)
                              : const Color(0xFF5E1717),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _isWeightDistributionValid ? 'Valid Distribution (100%)' : 'Invalid Weight Distribution',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CA Total: ${_totalCaWeight.toStringAsFixed(0)}% / 30%',
                          style: TextStyle(
                            color: (_totalCaWeight - 30.0).abs() < 0.01 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Final Exam: ${_examWeight.toStringAsFixed(0)}% / 70%',
                          style: TextStyle(
                            color: (_examWeight - 70.0).abs() < 0.01 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Text(
                        'Total: ${_totalWeight.toStringAsFixed(0)}%',
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Components List
            const Text(
              'ASSESSMENT COMPONENTS',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            ..._components.asMap().entries.map((entry) {
              final idx = entry.key;
              final comp = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: comp.type.startsWith('CA')
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                            : const Color(0xFF10B981).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        comp.type.startsWith('CA') ? Icons.assignment : Icons.school,
                        color: comp.type.startsWith('CA') ? const Color(0xFF60A5FA) : const Color(0xFF34D399),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comp.name, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('${comp.type} • Due: ${comp.dueDate}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('Max Raw Score: ${comp.maxMark.toStringAsFixed(0)} marks', style: const TextStyle(color: AppColors.gold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldTint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${comp.weightPercentage.toStringAsFixed(0)}% Weight',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        if (widget.isAuthorized) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.muted, size: 16),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () => _showAddEditComponentModal(comp, idx),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFF87171), size: 16),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() => _components.removeAt(idx));
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // Save Setup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDeep))
                    : const Icon(Icons.check, size: 18),
                label: Text(
                  _isSaving ? 'Validating & Saving...' : 'Save Assessment Configuration',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSaving ? null : _saveAssessmentSetup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
