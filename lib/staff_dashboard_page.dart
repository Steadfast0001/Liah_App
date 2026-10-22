import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';
import 'package:liah_app/attendance_register_page.dart';
import 'package:liah_app/dashboard_data.dart';
import 'package:liah_app/grade_entry_page.dart';
import 'package:liah_app/resit_management_page.dart';
import 'package:liah_app/staff_announcements_page.dart';
import 'package:liah_app/staff_courses_page.dart';
import 'package:liah_app/staff_timetable_page.dart';

/// Staff Dashboard Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Assigned course count, next class, attendance tasks, pending grade submissions, and notices.
/// Required interactions: Open tasks and refresh.
class StaffDashboardPage extends StatefulWidget {
  final DashboardData? data;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onSignOut;
  final Function(int targetTab)? onNavigateTab;

  const StaffDashboardPage({
    super.key,
    this.data,
    this.onRefresh,
    this.onSignOut,
    this.onNavigateTab,
  });

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final staffName = widget.data?.displayName.isNotEmpty == true
        ? widget.data!.displayName
        : 'Engr. Divine Mbella';
    final staffId = widget.data?.userId.isNotEmpty == true
        ? widget.data!.userId
        : 'LIAH-FAC-2019-012';

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: RefreshIndicator(
        color: AppColors.gold,
        backgroundColor: AppColors.surface,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Staff Header Banner
              _buildStaffHeader(staffName, staffId),
              const SizedBox(height: 16),

              // 2. Metrics & Key Indicators
              _buildSummaryStatsRow(),
              const SizedBox(height: 16),

              // 3. Next Upcoming Class Card
              _buildNextClassCard(),
              const SizedBox(height: 16),

              // 4. Pending Tasks: Attendance Tasks & Grade Submissions
              _buildTasksSection(),
              const SizedBox(height: 16),

              // 5. Quick Actions Grid
              _buildQuickActionsGrid(),
              const SizedBox(height: 16),

              // 6. Faculty Notices Preview
              _buildFacultyNoticesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffHeader(String name, String staffId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.gold,
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'L',
              style: const TextStyle(
                color: AppColors.navyDeep,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
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
                      'Welcome, $name',
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'STAFF ID: $staffId • Senior Lecturer',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Dept of Computer Science & Software Engineering',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  )
                : const Icon(Icons.refresh, color: AppColors.gold, size: 20),
            tooltip: 'Refresh Dashboard',
            onPressed: _handleRefresh,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'ASSIGNED COURSES',
            value: '3 Active',
            subtitle: '116 Students Total',
            icon: Icons.menu_book,
            color: AppColors.gold,
            onTap: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(1); // Go to Courses
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffCoursesPage()));
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'ATTENDANCE AUDIT',
            value: '2 Pending',
            subtitle: 'Unlogged sessions',
            icon: Icons.how_to_reg,
            color: const Color(0xFFF59E0B),
            onTap: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(2); // Go to Attendance
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceRegisterPage()));
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'GRADE SHEETS',
            value: '1 Draft',
            subtitle: 'Senate Due Nov 25',
            icon: Icons.assignment_turned_in,
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GradeEntryPage()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextClassCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'NEXT UPCOMING LECTURE',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldTint,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Today • 10:00 - 12:00',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'SWE201: Data Structures & Algorithms',
            style: TextStyle(
              color: AppColors.onNavy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
              SizedBox(width: 4),
              Text(
                'Amphi 250 • Main Campus',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              SizedBox(width: 14),
              Icon(Icons.groups_outlined, size: 14, color: AppColors.muted),
              SizedBox(width: 4),
              Text(
                '42 Students • Level 200 SE',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.how_to_reg, size: 16),
                  label: const Text('Take Attendance Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyDeep,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceRegisterPage(initialCourseCode: 'SWE201'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffTimetablePage()));
                },
                child: const Text('View Timetable', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PENDING TEACHING & ASSESSMENT TASKS',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Task 1: Attendance task
        _buildTaskItem(
          icon: Icons.checklist,
          color: const Color(0xFFF59E0B),
          title: 'Mark Attendance: CEF205 Lab 03',
          subtitle: 'Computer Architecture • Hardware Lab 1 (Yesterday 14:00)',
          badge: 'Unlogged',
          badgeColor: const Color(0xFFF59E0B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AttendanceRegisterPage(initialCourseCode: 'CEF205'),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // Task 2: Grade submission task
        _buildTaskItem(
          icon: Icons.edit_document,
          color: const Color(0xFF60A5FA),
          title: 'Submit CA Continuous Assessment: SWE201',
          subtitle: 'Continuous Assessment (30%) • 41/42 students entered',
          badge: 'Pending Submission',
          badgeColor: const Color(0xFF3B82F6),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GradeEntryPage(initialCourseCode: 'SWE201'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.onNavy,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: badgeColor, width: 0.8),
          ),
          child: Text(
            badge,
            style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FACULTY QUICK ACTIONS',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.15,
          children: [
            _buildActionTile(
              icon: Icons.menu_book,
              label: 'My Courses',
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(1);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffCoursesPage()));
                }
              },
            ),
            _buildActionTile(
              icon: Icons.how_to_reg,
              label: 'Attendance',
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(2);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceRegisterPage()));
                }
              },
            ),
            _buildActionTile(
              icon: Icons.grade,
              label: 'Grade Entry',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GradeEntryPage()));
              },
            ),
            _buildActionTile(
              icon: Icons.replay,
              label: 'Resits',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ResitManagementPage()));
              },
            ),
            _buildActionTile(
              icon: Icons.calendar_month,
              label: 'Timetable',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffTimetablePage()));
              },
            ),
            _buildActionTile(
              icon: Icons.campaign,
              label: 'Notices',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffAnnouncementsPage()));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onNavy,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyNoticesSection() {
    return Container(
      padding: const EdgeInsets.all(14),
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
              const Text(
                'OFFICIAL FACULTY NOTICES',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffAnnouncementsPage()));
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF60A5FA)),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Senate Grade Moderation Deadline (2026/2027 S1)',
                      style: TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'All First Semester Continuous Assessment (30%) sheets must be submitted through the portal by Friday 25 November at 17:00.',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
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
