import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';

enum AttendanceStatus { present, absent, late, excused }

class StudentAttendanceEntry {
  final String matricule;
  final String name;
  AttendanceStatus status;
  String? remarks;

  StudentAttendanceEntry({
    required this.matricule,
    required this.name,
    this.status = AttendanceStatus.present,
    this.remarks,
  });
}

/// Attendance Register Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Course/session selection, student list and attendance status.
/// Required interactions: Mark attendance, save and correct records if permitted.
/// Constraint: Only lecturers of a particular course can mark attendance for their assigned course.
class AttendanceRegisterPage extends StatefulWidget {
  final String initialCourseCode;

  const AttendanceRegisterPage({
    super.key,
    this.initialCourseCode = 'SWE201',
  });

  @override
  State<AttendanceRegisterPage> createState() => _AttendanceRegisterPageState();
}

class _AttendanceRegisterPageState extends State<AttendanceRegisterPage> {
  late String _selectedCourseCode;
  String _selectedSession = 'Session 08 • 21 Oct 2026 (10:00 - 12:00)';
  bool _isSaving = false;
  bool _hasSaved = false;

  // Assigned courses for current logged-in lecturer
  final List<String> _lecturerAssignedCourses = const ['SWE201', 'CEF205', 'SWE203'];
  final List<String> _allCatalogCourses = const ['SWE201', 'CEF205', 'SWE203', 'MAT201', 'ICT207'];

  final List<String> _sessions = const [
    'Session 08 • 21 Oct 2026 (10:00 - 12:00)',
    'Session 07 • 19 Oct 2026 (10:00 - 12:00)',
    'Session 06 • 14 Oct 2026 (10:00 - 12:00)',
    'Session 05 • 12 Oct 2026 (10:00 - 12:00)',
  ];

  late List<StudentAttendanceEntry> _attendanceEntries;

  @override
  void initState() {
    super.initState();
    _selectedCourseCode = widget.initialCourseCode;
    _initializeStudents();
  }

  void _initializeStudents() {
    _attendanceEntries = [
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0482', name: 'Martin Ngono', status: AttendanceStatus.present),
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0489', name: 'Clarisse Eyenga', status: AttendanceStatus.present),
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0491', name: 'Jean-Paul Abega', status: AttendanceStatus.absent),
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0495', name: 'Boris Tchakounte', status: AttendanceStatus.late),
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0502', name: 'Fongang Kelly', status: AttendanceStatus.present),
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0510', name: 'Sandrine Nkomo', status: AttendanceStatus.present),
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0514', name: 'Alain Fotso', status: AttendanceStatus.excused, remarks: 'Authorized medical slip'),
      StudentAttendanceEntry(matricule: 'LIAH-2024-SW0518', name: 'Beatrice Mbah', status: AttendanceStatus.present),
    ];
  }

  bool get _isAuthorizedToMark {
    return _lecturerAssignedCourses.contains(_selectedCourseCode);
  }

  int get _presentCount => _attendanceEntries.where((e) => e.status == AttendanceStatus.present).length;
  int get _absentCount => _attendanceEntries.where((e) => e.status == AttendanceStatus.absent).length;
  int get _lateCount => _attendanceEntries.where((e) => e.status == AttendanceStatus.late).length;
  int get _excusedCount => _attendanceEntries.where((e) => e.status == AttendanceStatus.excused).length;

  void _markAllPresent() {
    if (!_isAuthorizedToMark) return;
    setState(() {
      for (var entry in _attendanceEntries) {
        entry.status = AttendanceStatus.present;
      }
      _hasSaved = false;
    });
  }

  Future<void> _saveAttendanceRegister() async {
    if (!_isAuthorizedToMark) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _hasSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F5132),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Attendance records for $_selectedCourseCode ($_selectedSession) saved and audited with registry.',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadAttendancePdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Attendance sheet for $_selectedCourseCode downloaded as PDF.',
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
        title: const Text(
          'Attendance Register',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.gold),
            tooltip: 'Download Attendance PDF',
            onPressed: _downloadAttendancePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Course & Session Dropdown Selector
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
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SELECT COURSE', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
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
                              items: _allCatalogCourses.map((c) {
                                final isMine = _lecturerAssignedCourses.contains(c);
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    isMine ? '$c (Assigned)' : '$c (Unassigned)',
                                    style: TextStyle(
                                      color: isMine ? AppColors.gold : AppColors.muted,
                                      fontWeight: isMine ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCourseCode = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SESSION & DATE', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedSession,
                              isExpanded: true,
                              dropdownColor: AppColors.surface,
                              underline: const SizedBox.shrink(),
                              style: const TextStyle(color: AppColors.onNavy, fontSize: 12, fontWeight: FontWeight.w600),
                              items: _sessions.map((s) {
                                return DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSession = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Authorization Banner if Lecturer NOT assigned to this course
                if (!_isAuthorizedToMark) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E1717).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF87171)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline, color: Color(0xFFF87171), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Authorization Locked: Only lecturers assigned to this specific course can mark attendance.',
                            style: TextStyle(color: Color(0xFFF87171), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. Summary Counters (Present, Absent, Late, Excused)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceRaised,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatPill('Present', '$_presentCount', const Color(0xFF10B981)),
                _buildStatPill('Absent', '$_absentCount', const Color(0xFFEF4444)),
                _buildStatPill('Late', '$_lateCount', const Color(0xFFF59E0B)),
                _buildStatPill('Excused', '$_excusedCount', const Color(0xFF3B82F6)),
                if (_isAuthorizedToMark)
                  TextButton.icon(
                    icon: const Icon(Icons.done_all, size: 14, color: AppColors.gold),
                    label: const Text('All Present', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: _markAllPresent,
                  ),
              ],
            ),
          ),

          // 3. Student Attendance List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _attendanceEntries.length,
              itemBuilder: (context, i) {
                final entry = _attendanceEntries[i];
                return _buildStudentAttendanceTile(entry);
              },
            ),
          ),

          // 4. Bottom Save / Correction Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.navyDeep,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDeep),
                            )
                          : const Icon(Icons.save, size: 18),
                      label: Text(
                        _isSaving
                            ? 'Saving Records...'
                            : (_hasSaved ? 'Update & Correct Register' : 'Save Attendance Register'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAuthorizedToMark ? AppColors.gold : AppColors.border,
                        foregroundColor: AppColors.navyDeep,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (_isSaving || !_isAuthorizedToMark) ? null : _saveAttendanceRegister,
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

  Widget _buildStatPill(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        Text(
          count,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStudentAttendanceTile(StudentAttendanceEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.8),
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
              if (entry.remarks != null)
                Text(
                  entry.remarks!,
                  style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 10.5, fontStyle: FontStyle.italic),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusButton(entry, AttendanceStatus.present, 'Present', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildStatusButton(entry, AttendanceStatus.absent, 'Absent', const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _buildStatusButton(entry, AttendanceStatus.late, 'Late', const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildStatusButton(entry, AttendanceStatus.excused, 'Excused', const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    StudentAttendanceEntry entry,
    AttendanceStatus status,
    String label,
    Color color,
  ) {
    final isSelected = entry.status == status;

    return Expanded(
      child: InkWell(
        onTap: !_isAuthorizedToMark
            ? null
            : () {
                setState(() {
                  entry.status = status;
                  _hasSaved = false;
                });
              },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: isSelected ? 1.5 : 0.6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
