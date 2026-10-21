import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';
import 'package:liah_app/assessment_setup_page.dart';
import 'package:liah_app/attendance_register_page.dart';
import 'package:liah_app/grade_entry_page.dart';
import 'package:liah_app/staff_class_list_page.dart';
import 'package:liah_app/staff_courses_page.dart';

/// Staff Course Detail Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Course information, class list, timetable, assessments, and permitted course documents.
/// Required interactions: Open attendance, grade entry or student list.
class StaffCourseDetailPage extends StatefulWidget {
  final StaffCourseItem? course;

  const StaffCourseDetailPage({
    super.key,
    this.course,
  });

  @override
  State<StaffCourseDetailPage> createState() => _StaffCourseDetailPageState();
}

class _StaffCourseDetailPageState extends State<StaffCourseDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late final StaffCourseItem _course;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _course = widget.course ??
        const StaffCourseItem(
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
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _downloadCourseSyllabusPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Official course syllabus for ${_course.code} downloaded as PDF.',
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
        title: Text(
          '${_course.code} Details',
          style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.gold),
            tooltip: 'Download Course Syllabus PDF',
            onPressed: _downloadCourseSyllabusPdf,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Class List'),
            Tab(text: 'Assessments'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildClassListTab(),
          _buildAssessmentsTab(),
          _buildDocumentsTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Text(
                        _course.code,
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Text(
                      '${_course.credits} Credits • Liah Academy',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _course.title,
                  style: const TextStyle(color: AppColors.onNavy, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_course.program} • ${_course.cohort}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timetable & Venue Schedule
          const Text(
            'LECTURE & LAB SCHEDULE',
            style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.gold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _course.scheduleTime,
                        style: const TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border, height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.gold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _course.venue,
                        style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Syllabus Description & Prerequisites
          const Text(
            'COURSE DESCRIPTION & SYLLABUS',
            style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: const Text(
              'This course covers foundational and advanced data structures and algorithms analysis. Topics include algorithmic complexity (Big-O notation), stacks, queues, linked lists, binary search trees, hash tables, heaps, graph traversal (BFS/DFS), sorting algorithms, and dynamic programming implementations in Java and C++.',
              style: TextStyle(color: AppColors.onNavy, fontSize: 12.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassListTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_course.enrolledCount} Registered Students',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new, size: 15),
                label: const Text('Open Full Class List', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffClassListPage(courseCode: _course.code, courseTitle: _course.title),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildStudentPreviewCard('Martin Ngono', 'LIAH-2024-SW0482', '88% Attendance', 'Good Standing'),
                _buildStudentPreviewCard('Clarisse Eyenga', 'LIAH-2024-SW0489', '94% Attendance', 'Good Standing'),
                _buildStudentPreviewCard('Jean-Paul Abega', 'LIAH-2024-SW0491', '72% Attendance', 'Warning (<75%)'),
                _buildStudentPreviewCard('Boris Tchakounte', 'LIAH-2024-SW0495', '82% Attendance', 'Good Standing'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentPreviewCard(String name, String matricule, String attendance, String status) {
    final isWarning = status.contains('Warning');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceRaised,
                child: Text(
                  name.substring(0, 1),
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(matricule, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                attendance,
                style: TextStyle(
                  color: isWarning ? const Color(0xFFF87171) : const Color(0xFF34D399),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
              Text(status, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Configured Assessments',
                style: TextStyle(color: AppColors.onNavy, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings, size: 14),
                label: const Text('Configure Weights', style: TextStyle(fontSize: 11.5)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssessmentSetupPage(courseCode: _course.code),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAssessmentCard('Continuous Assessment (CA)', 'Max 30 Marks', '30% Weight', 'Due Nov 15, 2026', const Color(0xFF3B82F6)),
          const SizedBox(height: 10),
          _buildAssessmentCard('Final Examination', 'Max 70 Marks', '70% Weight', 'Exam Period Jan 2027', const Color(0xFF10B981)),
          const SizedBox(height: 10),
          _buildAssessmentCard('Resit Examination (Rattrapage)', 'Max 70 Marks', 'Replaces Final Exam', 'Post-Exam Session', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(String title, String maxMarks, String weight, String schedule, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('$maxMarks • $schedule', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 0.8),
            ),
            child: Text(weight, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDocumentTile('Official Course Outline & Syllabus 2026.pdf', 'PDF Document • 1.2 MB', 'Verified Registry Template'),
        _buildDocumentTile('SWE201 Lecture Notes Module 1 to 4.pdf', 'PDF Document • 4.8 MB', 'Uploaded by Lecturer'),
        _buildDocumentTile('Continuous Assessment Test Guide & Rubric.pdf', 'PDF Document • 840 KB', 'Department Standard'),
      ],
    );
  }

  Widget _buildDocumentTile(String title, String size, String author) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 24),
        title: Text(title, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('$size • $author', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: AppColors.gold, size: 20),
          tooltip: 'Download',
          onPressed: _downloadCourseSyllabusPdf,
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.navyDeep,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.how_to_reg, size: 16),
                label: const Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceRegisterPage(initialCourseCode: _course.code),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.grade, size: 16),
                label: const Text('Grade Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GradeEntryPage(initialCourseCode: _course.code),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
