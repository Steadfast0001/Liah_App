import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';

class ClassListStudent {
  final String name;
  final String matricule;
  final String email;
  final String phone;
  final String cohort;
  final double attendanceRate;
  final String feeClearanceStatus; // 'Cleared' | 'Pending Phase 2'
  final bool isRepeating;

  const ClassListStudent({
    required this.name,
    required this.matricule,
    required this.email,
    required this.phone,
    required this.cohort,
    required this.attendanceRate,
    required this.feeClearanceStatus,
    this.isRepeating = false,
  });
}

/// Staff Class List Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Authorized students, matricules, and relevant class information.
/// Required interactions: Search students and open permitted profiles.
class StaffClassListPage extends StatefulWidget {
  final String courseCode;
  final String courseTitle;

  const StaffClassListPage({
    super.key,
    this.courseCode = 'SWE201',
    this.courseTitle = 'Data Structures & Algorithms',
  });

  @override
  State<StaffClassListPage> createState() => _StaffClassListPageState();
}

class _StaffClassListPageState extends State<StaffClassListPage> {
  String _searchQuery = '';
  String _filterCriteria = 'All'; // 'All' | 'Below 75%' | 'Repeating'

  final List<ClassListStudent> _students = const [
    ClassListStudent(
      name: 'Martin Ngono',
      matricule: 'LIAH-2024-SW0482',
      email: 'm.ngono@student.liah.edu.cm',
      phone: '+237 671 234 567',
      cohort: 'Level 200 - Cohort A',
      attendanceRate: 88.5,
      feeClearanceStatus: 'Cleared',
    ),
    ClassListStudent(
      name: 'Clarisse Eyenga',
      matricule: 'LIAH-2024-SW0489',
      email: 'c.eyenga@student.liah.edu.cm',
      phone: '+237 699 123 456',
      cohort: 'Level 200 - Cohort A',
      attendanceRate: 94.0,
      feeClearanceStatus: 'Cleared',
    ),
    ClassListStudent(
      name: 'Jean-Paul Abega',
      matricule: 'LIAH-2024-SW0491',
      email: 'j.abega@student.liah.edu.cm',
      phone: '+237 655 432 109',
      cohort: 'Level 200 - Cohort A',
      attendanceRate: 71.0,
      feeClearanceStatus: 'Pending Phase 2',
    ),
    ClassListStudent(
      name: 'Boris Tchakounte',
      matricule: 'LIAH-2024-SW0495',
      email: 'b.tchakounte@student.liah.edu.cm',
      phone: '+237 678 901 234',
      cohort: 'Level 200 - Cohort A',
      attendanceRate: 82.0,
      feeClearanceStatus: 'Cleared',
    ),
    ClassListStudent(
      name: 'Fongang Kelly',
      matricule: 'LIAH-2024-SW0502',
      email: 'k.fongang@student.liah.edu.cm',
      phone: '+237 651 889 900',
      cohort: 'Level 200 - Cohort A',
      attendanceRate: 64.0,
      feeClearanceStatus: 'Cleared',
      isRepeating: true,
    ),
    ClassListStudent(
      name: 'Sandrine Nkomo',
      matricule: 'LIAH-2024-SW0510',
      email: 's.nkomo@student.liah.edu.cm',
      phone: '+237 690 334 556',
      cohort: 'Level 200 - Cohort A',
      attendanceRate: 96.0,
      feeClearanceStatus: 'Cleared',
    ),
  ];

  List<ClassListStudent> get _filteredStudents {
    return _students.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.matricule.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_filterCriteria == 'Below 75%') {
        return s.attendanceRate < 75.0;
      } else if (_filterCriteria == 'Repeating') {
        return s.isRepeating;
      }
      return true;
    }).toList();
  }

  void _showStudentProfileModal(ClassListStudent student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      student.name.substring(0, 1),
                      style: const TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          student.matricule,
                          style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          student.cohort,
                          style: const TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              _buildModalRow(Icons.email_outlined, 'Email', student.email),
              const SizedBox(height: 10),
              _buildModalRow(Icons.phone_outlined, 'Emergency Phone', student.phone),
              const SizedBox(height: 10),
              _buildModalRow(
                Icons.how_to_reg,
                'Attendance Standing',
                '${student.attendanceRate}% (MINESUP 75% ${student.attendanceRate >= 75 ? "Satisfied" : "Breached"})',
              ),
              const SizedBox(height: 10),
              _buildModalRow(
                Icons.verified_user_outlined,
                'Fee Registration Clearance',
                student.feeClearanceStatus,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close Profile'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _exportClassListPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Official class roster for ${widget.courseCode} (${_students.length} students) exported as PDF.',
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
    final filtered = _filteredStudents;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.courseCode} Class List',
              style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_students.length} Authorized Students Enrolled',
              style: const TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.gold),
            tooltip: 'Export Class List PDF',
            onPressed: _exportClassListPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.muted, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.navy,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Below 75%'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Repeating'),
                  ],
                ),
              ],
            ),
          ),

          // 2. Student List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No students matching "$_searchQuery"',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final student = filtered[i];
                      final isBelow75 = student.attendanceRate < 75.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: ListTile(
                          onTap: () => _showStudentProfileModal(student),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.surfaceRaised,
                            child: Text(
                              student.name.substring(0, 1),
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (student.isRepeating) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                                  ),
                                  child: const Text('Repeating', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            '${student.matricule} • ${student.cohort}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 11),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${student.attendanceRate}% Attendance',
                                style: TextStyle(
                                  color: isBelow75 ? const Color(0xFFF87171) : const Color(0xFF34D399),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.muted),
                            ],
                          ),
                        ),
                      );
                    },
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
        fontSize: 11.5,
      ),
      onSelected: (val) {
        if (val) setState(() => _filterCriteria = label);
      },
    );
  }
}
