import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'course_registration_page.dart';
import 'dashboard_data.dart';
import 'student_announcements_page.dart';
import 'student_attendance_page.dart';
import 'student_documents_page.dart';
import 'student_fees_page.dart';
import 'student_notifications_page.dart';
import 'student_results_page.dart';
import 'student_settings_page.dart';
import 'student_timetable_page.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({
    super.key,
    this.data,
    this.onRefresh,
    this.onSignOut,
  });

  final DashboardData? data;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onSignOut;

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = widget.data?.displayName.isNotEmpty == true
        ? widget.data!.displayName
        : 'Martin Ngono';
    final firstName = fullName.split(' ').first;
    final matricule = widget.data?.userId.isNotEmpty == true
        ? widget.data!.userId
        : 'LIAH-2024-SW0482';

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.navyDeep,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header: Greeting, Student Photo, Matricule & Notification Pill
            _buildStudentGreetingCard(context, firstName, fullName, matricule),
            const SizedBox(height: 16),

            // 2. Academic & Semester Summary Card
            _buildAcademicStandingCard(widget.data),
            const SizedBox(height: 16),

            // 3. Status Badges: Registration Status & Fee-Access Clearance
            _buildStatusBanners(context, widget.data),
            const SizedBox(height: 16),

            // 4. Next Scheduled Class Card
            _buildNextClassCard(context),
            const SizedBox(height: 20),

            // 5. Quick Actions Grid (All modules reachable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'QUICK ACTIONS & SERVICES',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                TextButton(
                  onPressed: () => _openMoreMenu(context),
                  child: const Text('More Options', style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 20),

            // 6. Institutional Announcements Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACADEMIC ANNOUNCEMENTS',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentAnnouncementsPage()),
                    );
                  },
                  child: const Text('View All', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildAnnouncementsList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentGreetingCard(
      BuildContext context, String firstName, String fullName, String matricule) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
              color: AppColors.navyDeep,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Center(
                  child: Text(
                    firstName.isNotEmpty ? firstName[0] : 'S',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()}, $firstName',
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      matricule,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'B.Eng Software Engineering • Level 200',
                  style: TextStyle(color: AppColors.muted, fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Badge(
              label: Text('3'),
              backgroundColor: AppColors.gold,
              textColor: AppColors.navyDeep,
              child: Icon(Icons.notifications_outlined, color: AppColors.onNavy),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentNotificationsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicStandingCard([DashboardData? data]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACADEMIC SUMMARY',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '2026/2027 • Semester 1',
                  style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  label: 'CURRENT GPA',
                  value: '3.68',
                  subtext: 'Scale of 4.00',
                  color: AppColors.gold,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildMetricItem(
                  label: 'CUMULATIVE CGPA',
                  value: '3.62',
                  subtext: 'First Class Honors',
                  color: AppColors.onNavy,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildMetricItem(
                  label: 'CREDITS EARNED',
                  value: '48 / 120',
                  subtext: 'Norm 100%',
                  color: AppColors.onNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(subtext, style: const TextStyle(color: AppColors.muted, fontSize: 9.5), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildStatusBanners(BuildContext context, [DashboardData? data]) {
    return Row(
      children: [
        // Registration Status
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseRegistrationPage()),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F261C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Registration', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                        Text('Validated (24 cr)', style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Fee Access Clearance Status
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentFeesPage()),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF261C08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_outlined, color: AppColors.gold, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fee Clearance', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                        Text('Exam Cleared (75%)', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextClassCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.alarm, color: AppColors.gold, size: 16),
                  SizedBox(width: 6),
                  Text('NEXT UPCOMING CLASS', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentTimetablePage()),
                  );
                },
                child: const Text('Timetable', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'SWE201: Data Structures & Algorithms',
            style: TextStyle(color: AppColors.onNavy, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Text('10:00 - 12:00', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(' • ', style: TextStyle(color: AppColors.muted)),
              Text('Amphi 250 (Main Campus)', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(' • ', style: TextStyle(color: AppColors.muted)),
              Text('Dr. Paul F. Tiku', style: TextStyle(color: AppColors.gold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      (
        'Registration',
        Icons.app_registration_rounded,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseRegistrationPage())),
      ),
      (
        'Timetable',
        Icons.calendar_month_outlined,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentTimetablePage())),
      ),
      (
        'Attendance',
        Icons.co_present_outlined,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAttendancePage())),
      ),
      (
        'Fees (XAF)',
        Icons.payments_outlined,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFeesPage())),
      ),
      (
        'Results & GPA',
        Icons.assessment_outlined,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentResultsPage())),
      ),
      (
        'Documents',
        Icons.description_outlined,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentDocumentsPage())),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final item = actions[i];
        return InkWell(
          onTap: item.$3,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: AppColors.gold, size: 24),
                const SizedBox(height: 6),
                Text(
                  item.$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementsList(BuildContext context) {
    final notices = [
      (
        'Mid-Semester Continuous Assessment (CA) Schedule',
        'Official CA sessions will take place between Nov 10 and Nov 15.',
        '21 Oct 2026',
        'Faculty Office',
      ),
      (
        'Bursary Second Installment (XAF) Reminder',
        'Students must clear at least 75% tuition to access Exam Slips.',
        '19 Oct 2026',
        'Bursary Office',
      ),
    ];

    return Column(
      children: notices.map((n) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.campaign_outlined, color: AppColors.gold, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.$1, style: const TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(n.$2, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                    const SizedBox(height: 6),
                    Text('${n.$4} • ${n.$3}', style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _openMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'More Student Services',
                  style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.gold),
                  title: const Text('Official Documents & Transcripts', style: TextStyle(color: AppColors.onNavy)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentDocumentsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.campaign_outlined, color: AppColors.gold),
                  title: const Text('Announcements Board', style: TextStyle(color: AppColors.onNavy)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAnnouncementsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.gold),
                  title: const Text('Settings & Preferences', style: TextStyle(color: AppColors.onNavy)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentSettingsPage()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
