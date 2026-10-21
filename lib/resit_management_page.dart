import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';

class ResitCandidate {
  final String matricule;
  final String name;
  final double caScore; // Stored from continuous assessment
  final double normalExamScore; // Original failed attempt
  final String normalGrade;
  double? resitExamScore; // Separate resit attempt
  String? validationError;

  ResitCandidate({
    required this.matricule,
    required this.name,
    required this.caScore,
    required this.normalExamScore,
    required this.normalGrade,
    this.resitExamScore,
    this.validationError,
  });

  double get normalTotal => caScore + normalExamScore;

  double? get resitTotal {
    if (resitExamScore == null) return null;
    return caScore + resitExamScore!;
  }

  String get resitGrade {
    final t = resitTotal;
    if (t == null) return '—';
    if (t >= 80.0) return 'A';
    if (t >= 70.0) return 'B+';
    if (t >= 60.0) return 'B';
    if (t >= 55.0) return 'C+';
    if (t >= 50.0) return 'C';
    if (t >= 45.0) return 'D';
    return 'F';
  }
}

/// Resit Management Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Assigned failed courses, student list, attempt history and resit status.
/// Required interactions: Enter a separate resit attempt and submit it.
class ResitManagementPage extends StatefulWidget {
  final String initialCourseCode;

  const ResitManagementPage({
    super.key,
    this.initialCourseCode = 'SWE201',
  });

  @override
  State<ResitManagementPage> createState() => _ResitManagementPageState();
}

class _ResitManagementPageState extends State<ResitManagementPage> {
  late String _selectedCourseCode;
  bool _isSubmitting = false;

  final List<String> _assignedCoursesWithResits = const ['SWE201', 'CEF205'];

  late List<ResitCandidate> _resitCandidates;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _selectedCourseCode = widget.initialCourseCode;
    _initializeCandidates();
  }

  void _initializeCandidates() {
    _resitCandidates = [
      ResitCandidate(
        matricule: 'LIAH-2024-SW0491',
        name: 'Jean-Paul Abega',
        caScore: 18.0,
        normalExamScore: 24.0, // Normal total 42 (Grade F)
        normalGrade: 'F (Normal Session)',
        resitExamScore: 38.0, // Resit total 56 (Grade C+)
      ),
      ResitCandidate(
        matricule: 'LIAH-2024-SW0502',
        name: 'Fongang Kelly',
        caScore: 14.0,
        normalExamScore: 22.0, // Normal total 36 (Grade F)
        normalGrade: 'F (Normal Session)',
        resitExamScore: null,
      ),
      ResitCandidate(
        matricule: 'LIAH-2024-SW0522',
        name: 'Patrick Ndi',
        caScore: 16.0,
        normalExamScore: 28.0, // Normal total 44 (Grade D)
        normalGrade: 'D (Normal Session)',
        resitExamScore: 40.0,
      ),
    ];

    for (var c in _resitCandidates) {
      _controllers[c.matricule] = TextEditingController(
        text: c.resitExamScore != null ? c.resitExamScore.toString() : '',
      );
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _validateResitScore(ResitCandidate candidate, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        candidate.resitExamScore = null;
        candidate.validationError = null;
        return;
      }
      final parsed = double.tryParse(value.trim());
      if (parsed == null) {
        candidate.validationError = 'Invalid score format';
        candidate.resitExamScore = null;
      } else if (parsed < 0.0 || parsed > 70.0) {
        candidate.validationError = 'Score must be between 0 and 70';
        candidate.resitExamScore = parsed;
      } else {
        candidate.validationError = null;
        candidate.resitExamScore = parsed;
      }
    });
  }

  Future<void> _submitResitSheet() async {
    final hasErrors = _resitCandidates.any((c) => c.validationError != null);
    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF5E1717),
          content: Text('Cannot submit: Correct invalid resit marks before proceeding.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Resit (Rattrapage) Submission', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold)),
        content: Text(
          'Submit ${_resitCandidates.length} separate resit examination scores for $_selectedCourseCode to the Academic Senate? Original failed attempts remain preserved.',
          style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navyDeep),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Submission', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F5132),
        content: Text('Resit score sheet for $_selectedCourseCode submitted successfully to Senate.'),
      ),
    );
  }

  void _downloadResitRosterPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Resit (Rattrapage) roster for $_selectedCourseCode downloaded as PDF.',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
              ),
            ),
          ],
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resit (Rattrapage) Management',
              style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Separate Attempt Roster • Senate Academic Rules',
              style: TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.gold),
            tooltip: 'Download Resit Roster PDF',
            onPressed: _downloadResitRosterPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Course Selector & Policy Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('FAILED COURSE OFFERING', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldTint,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_resitCandidates.length} Resit Candidates',
                        style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCourseCode,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                    items: _assignedCoursesWithResits.map((c) {
                      return DropdownMenuItem(value: c, child: Text('$c: Data Structures & Algorithms'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCourseCode = val);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.gold, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Liah Academic Regulation: Resit scores do NOT erase previous failed attempts. Both the original session and resit attempt are archived in student transcripts.',
                          style: TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Candidate Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _resitCandidates.length,
              itemBuilder: (context, i) {
                final candidate = _resitCandidates[i];
                return _buildCandidateCard(candidate);
              },
            ),
          ),

          // 3. Submit Resit Sheet Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.navyDeep,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDeep))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isSubmitting ? 'Submitting Resit Records...' : 'Submit Resit Grade Sheet to Senate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyDeep,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isSubmitting ? null : _submitResitSheet,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(ResitCandidate candidate) {
    final ctrl = _controllers[candidate.matricule];
    final resitTotal = candidate.resitTotal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: candidate.validationError != null ? const Color(0xFFEF4444) : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(candidate.name, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Text(candidate.matricule, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E1717).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFF87171), width: 0.8),
                ),
                child: Text(
                  'Original: ${candidate.normalGrade}',
                  style: const TextStyle(color: Color(0xFFF87171), fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 16),

          // Scores comparison: Historical Attempt vs New Resit
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HISTORICAL ATTEMPT', style: TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(
                      'CA: ${candidate.caScore.toStringAsFixed(1)} / 30',
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 11.5),
                    ),
                    Text(
                      'Exam: ${candidate.normalExamScore.toStringAsFixed(1)} / 70',
                      style: const TextStyle(color: Color(0xFFF87171), fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total: ${candidate.normalTotal.toStringAsFixed(1)} / 100',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 60, color: AppColors.border),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SEPARATE RESIT EXAM (MAX 70)', style: TextStyle(color: AppColors.gold, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    TextField(
                      controller: ctrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.navy,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        suffixText: '/ 70',
                        suffixStyle: const TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                      onChanged: (val) => _validateResitScore(candidate, val),
                    ),
                    if (candidate.validationError != null)
                      Text(candidate.validationError!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Authoritative preview of new outcome
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New Calculated Standing:', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                Text(
                  resitTotal != null
                      ? '${resitTotal.toStringAsFixed(1)} / 100 (Grade ${candidate.resitGrade})'
                      : 'Pending Resit Mark',
                  style: TextStyle(
                    color: resitTotal != null && resitTotal >= 50.0 ? const Color(0xFF34D399) : AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
