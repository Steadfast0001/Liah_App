import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../academics/screens/academic_structure_view.dart';
import '../../administration/screens/admin_dashboard_view.dart';
import '../../administration/screens/super_admin_dashboard_view.dart';
import '../../administration/widgets/admin_management_view.dart';
import '../../administration/widgets/audit_log_table.dart';
import '../../announcements/screens/announcements_view.dart';
import '../../attendance/screens/attendance_management_view.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/screens/login_screen.dart';
import '../../documents/screens/documents_view.dart';
import '../../fees/screens/fees_management_view.dart';
import '../../registration/screens/course_registration_screen.dart';
import '../../reports/screens/reports_analytics_view.dart';
import '../../results/screens/results_management_view.dart';
import '../../students/screens/student_list_screen.dart';

/// Fah Academy SMS — Role-Based Unified Shell
///
/// Implements 4 distinct role-based experiences over one shared Flutter codebase:
/// 1. Super Admin — 13 institutional governance & configuration sections
/// 2. Admin — 12 operational administration & verification sections
/// 3. Lecturer / Staff — 9 academic duty, teaching, and grading sections
/// 4. Student — 11 personal academic, enrollment, and fee sections
class RoleDashboardScreen extends ConsumerStatefulWidget {
  const RoleDashboardScreen({super.key});

  static const routePath = '/dashboard';

  @override
  ConsumerState<RoleDashboardScreen> createState() =>
      _RoleDashboardScreenState();
}

class _RoleDashboardScreenState extends ConsumerState<RoleDashboardScreen> {
  AppRole? _previewRoleOverride;
  int _selectedIndex = 0;

  void _selectRole(AppRole role) {
    setState(() {
      _previewRoleOverride = role;
      _selectedIndex = 0;
    });
  }

  // Navigation matrices specified by Fah Academy RBAC specification
  static const _superAdminNavItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined),
    _NavItem('Users & Roles', Icons.manage_accounts_outlined),
    _NavItem('Students', Icons.people_alt_outlined),
    _NavItem('Staff', Icons.badge_outlined),
    _NavItem('Admissions', Icons.how_to_reg_outlined),
    _NavItem('Academic Structure', Icons.school_outlined),
    _NavItem('Courses & Registration', Icons.menu_book_outlined),
    _NavItem('Results', Icons.assignment_turned_in_outlined),
    _NavItem('Fees & Financial Policies', Icons.request_quote_outlined),
    _NavItem('Documents & Transcripts', Icons.folder_shared_outlined),
    _NavItem('Reports', Icons.bar_chart_outlined),
    _NavItem('Audit Logs', Icons.history_edu_outlined),
    _NavItem('System Settings', Icons.settings_outlined),
  ];

  static const _adminNavItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined),
    _NavItem('Students', Icons.people_alt_outlined),
    _NavItem('Staff', Icons.badge_outlined),
    _NavItem('Admissions', Icons.how_to_reg_outlined),
    _NavItem('Academic Operations', Icons.school_outlined),
    _NavItem('Course Registration Oversight', Icons.menu_book_outlined),
    _NavItem('Payments', Icons.payments_outlined),
    _NavItem('Results Review', Icons.assignment_turned_in_outlined),
    _NavItem('Attendance & Timetable', Icons.fact_check_outlined),
    _NavItem('Documents', Icons.folder_outlined),
    _NavItem('Announcements', Icons.campaign_outlined),
    _NavItem('Reports', Icons.bar_chart_outlined),
  ];

  static const _lecturerNavItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined),
    _NavItem('My Courses', Icons.class_outlined),
    _NavItem('Class Lists', Icons.people_outline),
    _NavItem('Attendance', Icons.fact_check_outlined),
    _NavItem('Assessments & Grades', Icons.grading_outlined),
    _NavItem('Resits', Icons.replay_outlined),
    _NavItem('Timetable', Icons.calendar_today_outlined),
    _NavItem('Announcements', Icons.campaign_outlined),
    _NavItem('Profile', Icons.person_outline),
  ];

  static const _studentNavItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined),
    _NavItem('My Academics', Icons.school_outlined),
    _NavItem('Course Registration', Icons.menu_book_outlined),
    _NavItem('Timetable', Icons.calendar_today_outlined),
    _NavItem('Attendance', Icons.fact_check_outlined),
    _NavItem('Fees', Icons.account_balance_wallet_outlined),
    _NavItem('Results', Icons.grade_outlined),
    _NavItem('Documents & Transcripts', Icons.folder_shared_outlined),
    _NavItem('Announcements', Icons.campaign_outlined),
    _NavItem('Notifications', Icons.notifications_outlined),
    _NavItem('Profile & Settings', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Fah Academy SMS')),
        body: ErrorState(
          message: 'Failed to load profile: $err',
          onRetry: () => ref.invalidate(currentUserProfileProvider),
        ),
      ),
      data: (profile) {
        final activeRole =
            _previewRoleOverride ?? profile?.primaryRole ?? AppRole.admin;

        final items = _navItemsForRole(activeRole);
        final safeIndex = _selectedIndex.clamp(0, items.length - 1);
        final selectedItem = items[safeIndex];
        final isWideScreen = MediaQuery.sizeOf(context).width >= 900;

        Widget navList({required bool inDrawer}) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final nav = items[index];
              final selected = index == safeIndex;
              return ListTile(
                selected: selected,
                selectedTileColor: AppColors.primaryContainer,
                leading: Icon(
                  nav.icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  nav.label,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  setState(() => _selectedIndex = index);
                  if (inDrawer) Navigator.of(context).pop();
                },
              );
            },
          );
        }

        Widget drawerHeader() {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Fah Academy SMS',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StatusChip(status: activeRole.label),
              ],
            ),
          );
        }

        // 1. Desktop / Tablet (Persistent Sidebar)
        if (isWideScreen) {
          return Scaffold(
            appBar: _buildAppBar(context, selectedItem.label, activeRole),
            body: Row(
              children: [
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(right: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      drawerHeader(),
                      const Divider(color: AppColors.border, height: 1),
                      Expanded(child: navList(inDrawer: false)),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildRoleContent(
                    context,
                    profile,
                    activeRole,
                    selectedItem.label,
                  ),
                ),
              ],
            ),
          );
        }

        // 2. Mobile / Compact Screen (Drawer + Optional Bottom Navigation)
        final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

        return Scaffold(
          key: scaffoldKey,
          appBar: _buildAppBar(context, selectedItem.label, activeRole),
          drawer: Drawer(
            backgroundColor: AppColors.surface,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  drawerHeader(),
                  const Divider(color: AppColors.border, height: 1),
                  Expanded(child: navList(inDrawer: true)),
                ],
              ),
            ),
          ),
          body: _buildRoleContent(
            context,
            profile,
            activeRole,
            selectedItem.label,
          ),
          bottomNavigationBar: _buildBottomNav(
            context,
            activeRole,
            safeIndex,
            scaffoldKey,
          ),
        );
      },
    );
  }

  List<_NavItem> _navItemsForRole(AppRole role) {
    return switch (role) {
      AppRole.superAdmin => _superAdminNavItems,
      AppRole.admin => _adminNavItems,
      AppRole.lecturer => _lecturerNavItems,
      AppRole.student => _studentNavItems,
    };
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    String title,
    AppRole activeRole,
  ) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<AppRole>(
          tooltip: 'Switch role preview (RBAC Testing)',
          icon: const Icon(Icons.switch_account_outlined),
          onSelected: _selectRole,
          itemBuilder: (context) => [
            for (final role in AppRole.values)
              CheckedPopupMenuItem<AppRole>(
                value: role,
                checked: role == activeRole,
                child: Text(role.label),
              ),
          ],
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) context.go(LoginScreen.routePath);
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  Widget? _buildBottomNav(
    BuildContext context,
    AppRole activeRole,
    int currentIndex,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    if (activeRole == AppRole.student) {
      // Top 4 Student Destinations: Home, Courses, Fees, Results, All Services
      final bottomIndex = switch (currentIndex) {
        0 => 0,
        2 => 1,
        5 => 2,
        6 => 3,
        _ => 4,
      };

      return NavigationBar(
        selectedIndex: bottomIndex,
        onDestinationSelected: (idx) {
          if (idx == 0) setState(() => _selectedIndex = 0);
          if (idx == 1) setState(() => _selectedIndex = 2);
          if (idx == 2) setState(() => _selectedIndex = 5);
          if (idx == 3) setState(() => _selectedIndex = 6);
          if (idx == 4) scaffoldKey.currentState?.openDrawer();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.grade_outlined), selectedIcon: Icon(Icons.grade), label: 'Results'),
          NavigationDestination(icon: Icon(Icons.menu_open_outlined), selectedIcon: Icon(Icons.menu_open), label: 'All Services'),
        ],
      );
    }

    if (activeRole == AppRole.lecturer) {
      // Top 4 Lecturer Destinations: Home, My Courses, Attendance, Grades, All Services
      final bottomIndex = switch (currentIndex) {
        0 => 0,
        1 => 1,
        3 => 2,
        4 => 3,
        _ => 4,
      };

      return NavigationBar(
        selectedIndex: bottomIndex,
        onDestinationSelected: (idx) {
          if (idx == 0) setState(() => _selectedIndex = 0);
          if (idx == 1) setState(() => _selectedIndex = 1);
          if (idx == 2) setState(() => _selectedIndex = 3);
          if (idx == 3) setState(() => _selectedIndex = 4);
          if (idx == 4) scaffoldKey.currentState?.openDrawer();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.class_outlined), selectedIcon: Icon(Icons.class_), label: 'My Courses'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.grading_outlined), selectedIcon: Icon(Icons.grading), label: 'Grades'),
          NavigationDestination(icon: Icon(Icons.menu_open_outlined), selectedIcon: Icon(Icons.menu_open), label: 'All Services'),
        ],
      );
    }

    return null;
  }

  // =========================================================================
  // ROLE CONTENT RESOLUTION
  // =========================================================================
  Widget _buildRoleContent(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
    String sectionLabel,
  ) {
    return switch (sectionLabel) {
      // 1. Dashboard
      'Dashboard' => switch (activeRole) {
          AppRole.superAdmin => const SuperAdminDashboardView(),
          AppRole.admin => const AdminDashboardView(),
          AppRole.lecturer => _buildLecturerHomeTab(context, profile, activeRole),
          AppRole.student => _buildStudentHomeTab(context, profile, activeRole),
        },

      // 2. Users & Roles (SuperAdmin only)
      'Users & Roles' => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AdminManagementView(actorRole: activeRole),
        ),

      // 3. Students (SuperAdmin & Admin)
      'Students' => const StudentListScreen(embedded: true),

      // 4. Staff Directory & Accounts (SuperAdmin & Admin)
      'Staff' => _buildStaffManagement(context, activeRole),

      // 5. Admissions (SuperAdmin & Admin)
      'Admissions' => _buildAdmissionsManagement(context, activeRole),

      // 6. Academic Structure (SuperAdmin) & Academic Operations (Admin) & My Academics (Student)
      'Academic Structure' || 'Academic Operations' || 'My Academics' =>
        AcademicStructureView(actorRole: activeRole),

      // 7. Courses & Registration
      'Courses & Registration' ||
      'Course Registration Oversight' ||
      'Course Registration' =>
        const CourseRegistrationScreen(embedded: true),

      // 8. Results Review & Finalization
      'Results' || 'Results Review' || 'Assessments & Grades' =>
        ResultsManagementView(actorRole: activeRole),

      // 9. Fees & Payments
      'Fees & Financial Policies' => Column(
          children: [
            Expanded(
              child: FeesManagementView(actorRole: activeRole),
            ),
          ],
        ),
      'Payments' || 'Fees' => FeesManagementView(actorRole: activeRole),

      // 10. Attendance & Timetable
      'Attendance & Timetable' || 'Attendance' =>
        AttendanceManagementView(actorRole: activeRole),

      // 11. Timetable
      'Timetable' => switch (activeRole) {
          AppRole.lecturer => _buildLecturerTimetableTab(context),
          AppRole.student => _buildStudentTimetableTab(context),
          _ => AttendanceManagementView(actorRole: activeRole),
        },

      // 12. Documents & Transcripts
      'Documents & Transcripts' || 'Documents' =>
        DocumentsView(actorRole: activeRole),

      // 13. Announcements
      'Announcements' => AnnouncementsView(actorRole: activeRole),

      // 14. Reports & Analytics
      'Reports' => ReportsAnalyticsView(actorRole: activeRole),

      // 15. Audit Logs (SuperAdmin only)
      'Audit Logs' => const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: AuditLogTable(),
        ),

      // 16. System Settings
      'System Settings' => _buildSystemSettings(context, activeRole),

      // 17. Lecturer-specific destinations
      'My Courses' => _buildLecturerCoursesTab(context),
      'Class Lists' => _buildLecturerClassListsTab(context),
      'Resits' => _buildLecturerResitsTab(context),

      // 18. Student-specific destinations
      'Notifications' => _buildStudentNotificationsTab(context),
      'Profile & Settings' || 'Profile' =>
        _buildStudentMoreTab(context, profile, activeRole),

      // Fallback
      _ => Center(
          child: Text('Viewing $sectionLabel for ${activeRole.label}'),
        ),
    };
  }

  // =========================================================================
  // SUB-VIEWS FOR STUDENT
  // =========================================================================
  Widget _buildStudentHomeTab(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileRoleBanner(
          profile: profile,
          activeRole: activeRole,
          onRoleChanged: _selectRole,
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Current Semester Overview',
          subtitle: 'First Semester 2026/2027 • B.Sc. Computer Science',
        ),
        Row(
          children: [
            Expanded(
              child: AppCard(
                onTap: () => setState(() => _selectedIndex = 2),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.menu_book_outlined, color: AppColors.gold),
                        StatusChip(status: 'OPEN'),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Course Registration',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add or drop offerings (15-24 credits)',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                onTap: () => setState(() => _selectedIndex = 5),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.gold,
                        ),
                        StatusChip(status: 'CLEARED'),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Fee Balance',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    AmountText(
                      0,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Academic Quick Access',
          subtitle: 'Published results and official records',
        ),
        AppCard(
          onTap: () => setState(() => _selectedIndex = 6),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.grade_outlined, color: AppColors.gold),
            title: Text(
              'View Semester Grades & GPA',
              style: TextStyle(
                color: AppColors.onNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Official published results for completed semesters (GPA: 3.82)',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          onTap: () => setState(() => _selectedIndex = 7),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.verified_outlined, color: AppColors.gold),
            title: Text(
              'Transcripts & Documents',
              style: TextStyle(
                color: AppColors.onNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Request official transcripts and download enrollment certificate',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentTimetableTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SectionHeader(
          title: 'My Weekly Lecture Timetable',
          subtitle: 'First Semester 2026/2027 • Level 100 Computer Science',
        ),
        SizedBox(height: 12),
        AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Text('MON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            title: Text('CS101: Introduction to Computer Science', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('10:00 - 12:00 • Amphitheatre 300 • Dr. Marcus Vance'),
          ),
        ),
        SizedBox(height: 10),
        AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Text('WED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            title: Text('MATH101: Calculus & Linear Algebra', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('08:00 - 10:00 • Hall 2 • Dr. Jean-Paul Kamga'),
          ),
        ),
        SizedBox(height: 10),
        AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Text('FRI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            title: Text('CS102: Data Structures & Algorithms', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('14:00 - 16:00 • Lab 1 (Software) • Prof. Amina Bello'),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentNotificationsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SectionHeader(
          title: 'Notifications & Alerts',
          subtitle: 'Important communications regarding registration, fees, and results',
        ),
        SizedBox(height: 12),
        AppCard(
          child: ListTile(
            leading: Icon(Icons.check_circle_outline, color: AppColors.secondary),
            title: Text('Tuition Milestone Satisfied', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Your tuition deposit for Semester 1 has been verified. Result access is fully unlocked.'),
          ),
        ),
        SizedBox(height: 10),
        AppCard(
          child: ListTile(
            leading: Icon(Icons.menu_book, color: AppColors.primary),
            title: Text('Course Registration Approved', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Your 19 Credit Units registration has been approved by the Faculty Academic Advisor.'),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentMoreTab(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileRoleBanner(
          profile: profile,
          activeRole: activeRole,
          onRoleChanged: _selectRole,
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Profile & Account Details',
          subtitle: 'Matricule, contact preferences & session settings',
        ),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.badge_outlined, color: AppColors.gold),
            title: const Text(
              'Student Matricule',
              style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'FA-2026-BSC-CS-0001 • Program: B.Sc. Computer Science • ${profile?.email ?? ""}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.security_outlined, color: AppColors.gold),
            title: const Text(
              'Role & Permissions Scope',
              style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Student Role: Personal records only. Cannot modify academic structure, publish grades, or verify fees.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Sign Out',
          icon: Icons.logout,
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) context.go(LoginScreen.routePath);
          },
        ),
      ],
    );
  }

  // =========================================================================
  // SUB-VIEWS FOR LECTURER
  // =========================================================================
  Widget _buildLecturerHomeTab(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileRoleBanner(
          profile: profile,
          activeRole: activeRole,
          onRoleChanged: _selectRole,
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Lecturer Quick Actions',
          subtitle: 'Manage assigned course offerings, attendance, and grades',
        ),
        AppCard(
          onTap: () => setState(() => _selectedIndex = 1),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.class_outlined, color: AppColors.gold),
            title: Text(
              'My Assigned Courses & Class Roster',
              style: TextStyle(
                color: AppColors.onNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'CS101 (Intro to Programming), CS102 (Data Structures)',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          onTap: () => setState(() => _selectedIndex = 3),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.fact_check_outlined, color: AppColors.gold),
            title: Text(
              'Take Attendance',
              style: TextStyle(
                color: AppColors.onNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Record student attendance session for today',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          onTap: () => setState(() => _selectedIndex = 4),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.grading_outlined, color: AppColors.gold),
            title: Text(
              'Grade Entry & Submit Results',
              style: TextStyle(
                color: AppColors.onNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Continuous Assessment (30%) + Final Exam (70%)',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _buildLecturerCoursesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SectionHeader(
          title: 'My Assigned Courses (Semester 1)',
          subtitle: 'Course catalog allocations assigned by Head of Department',
        ),
        SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CS101: Introduction to Computer Science', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  StatusChip(status: '4 CREDITS'),
                ],
              ),
              SizedBox(height: 6),
              Text('Enrolled Students: 42 • Level 100 • Hall 3B • Schedule: Mon 10:00 - 12:00'),
            ],
          ),
        ),
        SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CS102: Data Structures & Algorithms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  StatusChip(status: '4 CREDITS'),
                ],
              ),
              SizedBox(height: 6),
              Text('Enrolled Students: 39 • Level 100 • Lab 1 • Schedule: Fri 14:00 - 16:00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLecturerClassListsTab(BuildContext context) {
    return const StudentListScreen(embedded: true);
  }

  Widget _buildLecturerResitsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SectionHeader(
          title: 'Assigned Resit Examination Management',
          subtitle: 'Fah Academy Policy: Resit attempts are recorded without erasing original failed grades',
        ),
        SizedBox(height: 12),
        AppCard(
          child: ListTile(
            leading: Icon(Icons.replay_outlined, color: AppColors.accent),
            title: Text('CS101 Resit Roster (4 Candidates)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Original scores retained in audit ledger. Resit exam scheduled for Feb 25, 2027.'),
          ),
        ),
      ],
    );
  }

  Widget _buildLecturerTimetableTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SectionHeader(
          title: 'Lecturer Teaching Schedule',
          subtitle: 'Weekly lecture hours & allocated amphitheatres',
        ),
        SizedBox(height: 12),
        AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Text('MON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            title: Text('CS101: Lecture & Discussion', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('10:00 - 12:00 • Hall 3B • 42 Enrolled Students'),
          ),
        ),
        SizedBox(height: 10),
        AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Text('FRI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            title: Text('CS102: Practical Programming Lab', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('14:00 - 16:00 • Lab 1 • 39 Enrolled Students'),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SUB-VIEWS FOR ADMIN & SUPER ADMIN (SHARED OPERATIONAL HELPERS)
  // =========================================================================
  Widget _buildStaffManagement(BuildContext context, AppRole activeRole) {
    final staff = [
      {'name': 'Dr. Marcus Vance', 'dept': 'Computer Science', 'role': 'Senior Lecturer', 'courses': 'CS101'},
      {'name': 'Prof. Amina Bello', 'dept': 'Software Engineering', 'role': 'Professor', 'courses': 'CS102, SE201'},
      {'name': 'Dr. Jean-Paul Kamga', 'dept': 'Mathematics', 'role': 'Senior Lecturer', 'courses': 'MATH101'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          title: 'Faculty & Academic Staff Directory',
          subtitle: 'Manage faculty assignments, departments, and course lecturers',
          trailing: activeRole == AppRole.superAdmin
              ? AppButton(
                  label: 'Add Faculty Member',
                  icon: Icons.person_add,
                  onPressed: () {},
                )
              : null,
        ),
        const SizedBox(height: 12),
        for (final member in staff) ...[
          AppCard(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              title: Text(member['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${member['role']} • Dept of ${member['dept']}\nAssigned Courses: ${member['courses']}'),
              trailing: const StatusChip(status: 'ACTIVE'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildAdmissionsManagement(BuildContext context, AppRole activeRole) {
    final applicants = [
      {'name': 'Kenjo Cedric Fai', 'program': 'B.Sc. Computer Science', 'gpa': '3.90', 'status': 'REVIEW_PASSED'},
      {'name': 'Nabila Sandra Tataw', 'program': 'B.Eng. Software Engineering', 'gpa': '3.75', 'status': 'PENDING_DOCS'},
      {'name': 'Tume Clinton Vernyuy', 'program': 'B.Sc. Information Technology', 'gpa': '3.82', 'status': 'APPROVED'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          title: 'Admissions Pipeline & Verification',
          subtitle: 'Review incoming applicant credentials, verify documents, and issue matricules',
          trailing: AppButton(
            label: 'Process New Application',
            icon: Icons.how_to_reg,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 12),
        for (final app in applicants) ...[
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${app['program']} • High School GPA: ${app['gpa']}'),
                  ],
                ),
                StatusChip(status: app['status']!),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildSystemSettings(BuildContext context, AppRole activeRole) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          title: 'Fah Academy SMS — System Configuration',
          subtitle: 'Institutional parameters, academic calendar & security controls',
        ),
        const SizedBox(height: 12),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Academic Year Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 6),
              Text('Current Academic Year: 2026/2027 • Active Semester: Semester 1\nAdd/Drop Credit Range Bounds: 15 to 24 Credit Units (CU)'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Security & Two-Factor Authentication (2FA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 6),
              Text('SuperAdmin & Admin 2FA: Mandatory OTP via SMS/Email\nSession Inactivity Timeout: 15 minutes\nSecurity Audit Logging: Enabled & Immutable'),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ProfileRoleBanner extends StatelessWidget {
  const _ProfileRoleBanner({
    required this.profile,
    required this.activeRole,
    required this.onRoleChanged,
  });

  final UserProfile? profile;
  final AppRole activeRole;
  final ValueChanged<AppRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primaryContainer,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              (profile?.fullName.isNotEmpty ?? false)
                  ? profile!.fullName[0].toUpperCase()
                  : 'F',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.fullName ?? 'Fah Academy User',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  profile?.email ?? 'user@fahacademy.com',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusChip(status: activeRole.label),
        ],
      ),
    );
  }
}
