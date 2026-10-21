import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';
import 'package:liah_app/grade_submission_detail_page.dart';

enum GradeSheetState { draft, submitted, returned, approved }

class StudentGradeEntry {
  final String matricule;
  final String name;
  double? caMark;
  double? examMark;
  String? caError;
  String? examError;

  StudentGradeEntry({
    required this.matricule,
    required this.name,
    this.caMark,
    this.examMark,
    this.caError,
    this.examError,
  });

  double? get totalScore {
    if (caMark == null && examMark == null) return null;
    return (caMark ?? 0.0) + (examMark ?? 0.0);
  }

  String get letterGrade {
    final t = totalScore;
    if (t == null) return '—';
    if (t >= 80.0) return 'A';
    if (t >= 70.0) return 'B+';
    if (t >= 60.0) return 'B';
    if (t >= 55.0) return 'C+';
    if (t >= 50.0) return 'C';
    if (t >= 45.0) return 'D';
    return 'F';
  }

  double? get gradePoint {
    final t = totalScore;
    if (t == null) return null;
    if (t >= 80.0) return 4.0;
    if (t >= 70.0) return 3.5;
    if (t >= 60.0) return 3.0;
    if (t >= 55.0) return 2.5;
    if (t >= 50.0) return 2.0;
    if (t >= 45.0) return 1.5;
    return 0.0;
  }
}

/// Grade Entry Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Student list, CA marks, exam marks, total preview and validation feedback.
/// Required interactions: Save draft, validate marks and submit the grade sheet.
class GradeEntryPage extends StatefulWidget {
  final String initialCourseCode;

  const GradeEntryPage({
    super.key,
    this.initialCourseCode = 'SWE201',
  });

  @override
  State<GradeEntryPage> createState() => _GradeEntryPageState();
}

class _GradeEntryPageState extends State<GradeEntryPage> {
  late String _selectedCourseCode;
  String _searchQuery = '';
  String _filterCriteria = 'All'; // 'All' | 'Missing CA' | 'Missing Exam' | 'Failing (<50)'
  GradeSheetState _sheetState = GradeSheetState.draft;
  bool _isSubmitting = false;

  final double _maxCaMark = 30.0;
  final double _maxExamMark = 70.0;

  final List<String> _courses = const ['SWE201', 'CEF205', 'SWE203'];

  // Persistent student grade entries across searches and navigation
  late final List<StudentGradeEntry> _entries;

  // Controllers mapped to matricule for text editing
  final Map<String, TextEditingController> _caControllers = {};
  final Map<String, TextEditingController> _examControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedCourseCode = widget.initialCourseCode;
    _initializeData();
  }

  void _initializeData() {
    _entries = [
      StudentGradeEntry(matricule: 'LIAH-2024-SW0482', name: 'Martin Ngono', caMark: 24.5, examMark: 56.0),
      StudentGradeEntry(matricule: 'LIAH-2024-SW0489', name: 'Clarisse Eyenga', caMark: 28.0, examMark: 62.0),
      StudentGradeEntry(matricule: 'LIAH-2024-SW0491', name: 'Jean-Paul Abega', caMark: 18.0, examMark: 24.0), // Resit candidate
      StudentGradeEntry(matricule: 'LIAH-2024-SW0495', name: 'Boris Tchakounte', caMark: 22.0, examMark: 48.0),
      StudentGradeEntry(matricule: 'LIAH-2024-SW0502', name: 'Fongang Kelly', caMark: 14.0, examMark: null), // Missing exam
      StudentGradeEntry(matricule: 'LIAH-2024-SW0510', name: 'Sandrine Nkomo', caMark: 27.0, examMark: 58.0),
      StudentGradeEntry(matricule: 'LIAH-2024-SW0514', name: 'Alain Fotso', caMark: null, examMark: 50.0), // Missing CA
      StudentGradeEntry(matricule: 'LIAH-2024-SW0518', name: 'Beatrice Mbah', caMark: 20.0, examMark: 45.0),
    ];

    for (var entry in _entries) {
      _caControllers[entry.matricule] = TextEditingController(
        text: entry.caMark != null ? entry.caMark.toString() : '',
      );
      _examControllers[entry.matricule] = TextEditingController(
        text: entry.examMark != null ? entry.examMark.toString() : '',
      );
    }
  }

  @override
  void dispose() {
    for (var c in _caControllers.values) {
      c.dispose();
    }
    for (var c in _examControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _validateCa(StudentGradeEntry entry, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        entry.caMark = null;
        entry.caError = null;
        return;
      }
      final parsed = double.tryParse(value.trim());
      if (parsed == null) {
        entry.caError = 'Must be a valid number';
        entry.caMark = null;
      } else if (parsed < 0.0 || parsed > _maxCaMark) {
        entry.caError = 'Must be between 0 and ${_maxCaMark.toInt()}';
        entry.caMark = parsed;
      } else {
        entry.caError = null;
        entry.caMark = parsed;
      }
    });
  }

  void _validateExam(StudentGradeEntry entry, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        entry.examMark = null;
        entry.examError = null;
        return;
      }
      final parsed = double.tryParse(value.trim());
      if (parsed == null) {
        entry.examError = 'Must be a valid number';
        entry.examMark = null;
      } else if (parsed < 0.0 || parsed > _maxExamMark) {
        entry.examError = 'Must be between 0 and ${_maxExamMark.toInt()}';
        entry.examMark = parsed;
      } else {
        entry.examError = null;
        entry.examMark = parsed;
      }
    });
  }

  List<StudentGradeEntry> get _filteredEntries {
    return _entries.where((e) {
      final matchesSearch = _searchQuery.isEmpty ||
          e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.matricule.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_filterCriteria == 'Missing CA') return e.caMark == null;
      if (_filterCriteria == 'Missing Exam') return e.examMark == null;
      if (_filterCriteria == 'Failing (<50)') {
        final t = e.totalScore;
        return t != null && t < 50.0;
      }
      return true;
    }).toList();
  }

  bool get _hasAnyValidationErrors {
    return _entries.any((e) => e.caError != null || e.examError != null);
  }

  int get _missingCount => _entries.where((e) => e.caMark == null || e.examMark == null).length;

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F5132),
        content: Text('Grade sheet draft for $_selectedCourseCode saved locally.'),
      ),
    );
  }

  Future<void> _submitGradeSheet() async {
    if (_hasAnyValidationErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF5E1717),
          content: Text('Cannot submit: Please correct invalid mark inputs first.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Grade Sheet Submission', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to submit the official grades for $_selectedCourseCode (${_entries.length} students).',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13)),
            if (_missingCount > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Notice: $_missingCount student(s) currently have incomplete or missing marks.',
                style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Once submitted, the grade sheet will be routed to the Head of Department (HOD) and Senate for moderation.',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navyDeep),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm & Submit to HOD', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Prevent repeated submissions while request in progress
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _sheetState = GradeSheetState.submitted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F5132),
        content: Text('Grade sheet for $_selectedCourseCode submitted successfully to HOD.'),
      ),
    );
  }

  void _downloadGradeSheetPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Authoritative grade sheet for $_selectedCourseCode downloaded as PDF.',
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
    final filtered = _filteredEntries;

    String stateLabel = 'Draft';
    Color stateColor = const Color(0xFFF59E0B);
    if (_sheetState == GradeSheetState.submitted) {
      stateLabel = 'Submitted to HOD';
      stateColor = const Color(0xFF3B82F6);
    } else if (_sheetState == GradeSheetState.approved) {
      stateLabel = 'Approved by Senate';
      stateColor = const Color(0xFF10B981);
    } else if (_sheetState == GradeSheetState.returned) {
      stateLabel = 'Returned for Correction';
      stateColor = const Color(0xFFEF4444);
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grade Entry • $_selectedCourseCode',
              style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Continuous Assessment (30) • Written Exam (70)',
              style: TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.gold),
            tooltip: 'Download Grade Sheet PDF',
            onPressed: _downloadGradeSheetPdf,
          ),
          IconButton(
            icon: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.gold),
            tooltip: 'View Submission Details',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GradeSubmissionDetailPage(courseCode: _selectedCourseCode),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Course Selector & Sheet Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedCourseCode,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                  items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCourseCode = val);
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: stateColor, width: 0.8),
                  ),
                  child: Text(
                    stateLabel,
                    style: TextStyle(color: stateColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 2. Security / Senate Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF1E293B),
            child: const Row(
              children: [
                Icon(Icons.security, size: 14, color: AppColors.gold),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lecturer Policy: Result publication is strictly reserved for the Academic Senate and Registrar. Lecturers cannot publish results directly.',
                    style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                  ),
                ),
              ],
            ),
          ),

          // 3. Search Bar & Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search by student name or matricule...',
                    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
                    prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.muted, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.navy,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Missing CA'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Missing Exam'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Failing (<50)'),
                  ],
                ),
              ],
            ),
          ),

          // 4. Student Mark Input Rows
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final entry = filtered[i];
                return _buildStudentGradeCard(entry);
              },
            ),
          ),

          // 5. Bottom Action Bar (Save Draft, Submit to HOD)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.navyDeep,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Save Draft'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.gold),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _sheetState == GradeSheetState.approved ? null : _saveDraft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDeep),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: Text(_isSubmitting ? 'Submitting...' : 'Submit to HOD'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (_isSubmitting || _sheetState == GradeSheetState.approved)
                          ? null
                          : _submitGradeSheet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterCriteria == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.gold,
      backgroundColor: AppColors.navy,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.navyDeep : AppColors.muted,
        fontWeight: FontWeight.bold,
        fontSize: 10.5,
      ),
      onSelected: (val) {
        if (val) setState(() => _filterCriteria = label);
      },
    );
  }

  Widget _buildStudentGradeCard(StudentGradeEntry entry) {
    final caCtrl = _caControllers[entry.matricule];
    final examCtrl = _examControllers[entry.matricule];
    final total = entry.totalScore;
    final isFailing = total != null && total < 50.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (entry.caError != null || entry.examError != null)
              ? const Color(0xFFEF4444)
              : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info & Authoritative Result Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      entry.matricule,
                      style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isFailing ? const Color(0xFFF87171) : AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      total != null ? '${total.toStringAsFixed(1)} / 100' : '— / 100',
                      style: TextStyle(
                        color: isFailing ? const Color(0xFFF87171) : AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isFailing ? const Color(0xFF5E1717) : const Color(0xFF0F5132),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.letterGrade,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Inputs for CA and Exam Marks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CA Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CA MARK (MAX 30)', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: caCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.navy,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: entry.caError != null ? const Color(0xFFEF4444) : AppColors.border,
                          ),
                        ),
                        suffixText: '/ 30',
                        suffixStyle: const TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                      onChanged: (val) => _validateCa(entry, val),
                    ),
                    if (entry.caError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          entry.caError!,
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Exam Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EXAM MARK (MAX 70)', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: examCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.navy,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: entry.examError != null ? const Color(0xFFEF4444) : AppColors.border,
                          ),
                        ),
                        suffixText: '/ 70',
                        suffixStyle: const TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                      onChanged: (val) => _validateExam(entry, val),
                    ),
                    if (entry.examError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          entry.examError!,
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
