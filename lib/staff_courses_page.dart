import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';
import 'package:liah_app/attendance_register_page.dart';
import 'package:liah_app/grade_entry_page.dart';
import 'package:liah_app/staff_class_list_page.dart';
import 'package:liah_app/staff_course_detail_page.dart';

class StaffCourseItem {
  final String code;
  final String title;
  final String program;
  final String semester;
  final String cohort;
  final int enrolledCount;
  final int credits;
  final String scheduleTime;
  final String venue;
  final String gradeSheetStatus; // 'Draft' | 'Submitted' | 'Approved' | 'Returned'

  const StaffCourseItem({
    required this.code,
    required this.title,
    required this.program,
    required this.semester,
    required this.cohort,
    required this.enrolledCount,
    required this.credits,
    required this.scheduleTime,
    required this.venue,
    required this.gradeSheetStatus,
  });
}

/// Staff Courses Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Assigned courses, course codes, programs, semesters, cohorts, and enrolled-student counts.
/// Required interactions: Search courses and open details.
class StaffCoursesPage extends StatefulWidget {
  final Function(StaffCourseItem course)? onSelectCourse;

  const StaffCoursesPage({
    super.key,
    this.onSelectCourse,
  });

  @override
  State<StaffCoursesPage> createState() => _StaffCoursesPageState();
}

class _StaffCoursesPageState extends State<StaffCoursesPage> {
  String _searchQuery = '';
  String _selectedSemester = 'All Semesters';

  final List<StaffCourseItem> _assignedCourses = const [
    StaffCourseItem(
      code: 'SWE201',
      title: 'Data Structures & Algorithms',
      program: 'B.Eng Software Engineering',
      semester: '2026/2027 Semester 1',
      cohort: 'Level 200 - Cohort A',
      enrolledCount: 42,
      credits: 4,
      scheduleTime: 'Mon 10:00 - 12:00, Wed 08:00 - 10:00',
      venue: 'Amphi 250 (Main Campus)',
      gradeSheetStatus: 'Draft (41/42 entered)',
    ),
    StaffCourseItem(
      code: 'CEF205',
      title: 'Computer Architecture & Assembly',
      program: 'B.Sc Computer Engineering',
      semester: '2026/2027 Semester 1',
      cohort: 'Level 200 - Cohort B',
      enrolledCount: 38,
      credits: 4,
      scheduleTime: 'Tue 14:00 - 16:00, Thu 10:00 - 12:00',
      venue: 'Hardware Lab 1',
      gradeSheetStatus: 'Submitted to HOD',
    ),
    StaffCourseItem(
      code: 'SWE203',
      title: 'Object-Oriented Programming (Java)',
      program: 'B.Eng Software Engineering',
      semester: '2026/2027 Semester 1',
      cohort: 'Level 200 - Cohort A',
      enrolledCount: 36,
      credits: 4,
      scheduleTime: 'Fri 08:00 - 11:00',
      venue: 'Software Lab 3',
      gradeSheetStatus: 'Approved by Senate',
    ),
  ];

  List<StaffCourseItem> get _filteredCourses {
    return _assignedCourses.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.program.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.cohort.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSemester = _selectedSemester == 'All Semesters' ||
          c.semester.contains(_selectedSemester);

      return matchesSearch && matchesSemester;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCourses;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Assigned Courses',
              style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Teaching Portfolio • 2026/2027 Academic Year',
              style: TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar & Semester Filter
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
                    hintText: 'Search by course code, title, program, or cohort...',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Courses Found',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _selectedSemester,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
                      underline: const SizedBox.shrink(),
                      icon: const Icon(Icons.filter_list, color: AppColors.gold, size: 16),
                      items: const [
                        DropdownMenuItem(value: 'All Semesters', child: Text('All Semesters')),
                        DropdownMenuItem(value: 'Semester 1', child: Text('Semester 1')),
                        DropdownMenuItem(value: 'Semester 2', child: Text('Semester 2')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSemester = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Courses List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.muted),
                        const SizedBox(height: 12),
                        Text(
                          'No assigned courses matching "$_searchQuery"',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final course = filtered[i];
                      return _buildCourseCard(course);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(StaffCourseItem course) {
    Color statusBadgeColor = AppColors.border;
    if (course.gradeSheetStatus.contains('Approved')) {
      statusBadgeColor = const Color(0xFF10B981);
    } else if (course.gradeSheetStatus.contains('Submitted')) {
      statusBadgeColor = const Color(0xFF3B82F6);
    } else if (course.gradeSheetStatus.contains('Draft')) {
      statusBadgeColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Code, Credits, Title
          InkWell(
            onTap: () {
              if (widget.onSelectCourse != null) {
                widget.onSelectCourse!(course);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StaffCourseDetailPage(course: course),
                  ),
                );
              }
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.gold, width: 0.8),
                        ),
                        child: Text(
                          course.code,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBadgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusBadgeColor, width: 0.8),
                        ),
                        child: Text(
                          course.gradeSheetStatus,
                          style: TextStyle(
                            color: statusBadgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${course.program} • ${course.cohort}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        '${course.enrolledCount} Students Enrolled',
                        style: const TextStyle(color: AppColors.gold, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.schedule, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        '${course.credits} Credits • ${course.semester}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),

          // Course Action Shortcuts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.how_to_reg, size: 15, color: AppColors.gold),
                  label: const Text('Attendance', style: TextStyle(color: AppColors.gold, fontSize: 11.5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceRegisterPage(initialCourseCode: course.code),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.grade, size: 15, color: AppColors.gold),
                  label: const Text('Grade Entry', style: TextStyle(color: AppColors.gold, fontSize: 11.5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GradeEntryPage(initialCourseCode: course.code),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.group, size: 15, color: AppColors.gold),
                  label: const Text('Class List', style: TextStyle(color: AppColors.gold, fontSize: 11.5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffClassListPage(courseCode: course.code, courseTitle: course.title),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
