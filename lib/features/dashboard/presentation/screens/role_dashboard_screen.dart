import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../registration/presentation/screens/course_registration_screen.dart';
import '../../../students/presentation/screens/create_student_screen.dart';
import '../../../students/presentation/screens/student_list_screen.dart';

/// Unified role-based dashboard supporting:
/// - Student: Bottom Navigation (Home, Courses, Fees, Results, More)
/// - Lecturer: Bottom Nav / Drawer (Home, My Courses, Attendance, Grades, More)
/// - Admin: Drawer / Side Navigation (9 sections)
/// - Super Admin: Drawer / Side Navigation (9 sections + 4 system management modules)
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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Liah Academy SMS')),
        body: ErrorState(
          message: 'Failed to load profile: $err',
          onRetry: () => ref.invalidate(currentUserProfileProvider),
        ),
      ),
      data: (profile) {
        final activeRole =
            _previewRoleOverride ?? profile?.primaryRole ?? AppRole.admin;

        return switch (activeRole) {
          AppRole.student => _buildStudentShell(context, profile, activeRole),
          AppRole.lecturer => _buildLecturerShell(context, profile, activeRole),
          AppRole.admin || AppRole.superAdmin =>
            _buildAdminShell(context, profile, activeRole),
        };
      },
    );
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
          tooltip: 'Switch role preview',
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

  // ===========================================================================
  // 1. STUDENT SHELL
  // Bottom Nav:
  // 1. Home (Dashboard)
  // 2. Courses
  // 3. Fees
  // 4. Results
  // 5. More (Profile, Documents, Notifications, Transcripts)
  // ===========================================================================
  Widget _buildStudentShell(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    const titles = [
      'Student Home',
      'Course Registration',
      'Fees & Payments',
      'Academic Results',
      'More Services',
    ];
    final safeIndex = _selectedIndex.clamp(0, titles.length - 1);

    return Scaffold(
      appBar: _buildAppBar(context, titles[safeIndex], activeRole),
      body: IndexedStack(
        index: safeIndex,
        children: [
          _buildStudentHomeTab(context, profile, activeRole),
          const CourseRegistrationScreen(embedded: true),
          _buildStudentFeesTab(context),
          _buildStudentResultsTab(context),
          _buildStudentMoreTab(context, profile, activeRole),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Fees',
          ),
          NavigationDestination(
            icon: Icon(Icons.grade_outlined),
            selectedIcon: Icon(Icons.grade),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

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
                onTap: () => setState(() => _selectedIndex = 1),
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
                onTap: () => setState(() => _selectedIndex = 2),
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
          onTap: () => setState(() => _selectedIndex = 3),
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
              'Official published results for completed semesters',
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
            leading: Icon(Icons.verified_outlined, color: AppColors.gold),
            title: Text(
              'Transcripts & Documents',
              style: TextStyle(
                color: AppColors.onNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Request official transcripts and download admission papers',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentFeesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          backgroundColor: AppColors.navyDeep,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Outstanding Tuition & Charges',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  StatusChip(status: 'CLEARED'),
                ],
              ),
              const SizedBox(height: 8),
              const AmountText(
                0,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Pay via Mobile Money (MTN MoMo / Orange Money)',
                icon: Icons.payments_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mobile Money checkout creates payment intent via create-payment-intent Edge Function.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Semester Fee Schedule',
          subtitle: 'All fees charged in Central African CFA (XAF)',
        ),
        const AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tuition Fee',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'First Semester 2026/2027',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
              AmountText(
                350000,
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registration Fee',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Annual Registration & ICT',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
              AmountText(
                25000,
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentResultsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SectionHeader(
          title: 'Official Published Results',
          subtitle: 'Enforced by Row Level Security (workflow_status = published)',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'First Semester 2026/2027',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  StatusChip(status: 'IN PROGRESS'),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Continuous Assessment (CA) and Final Exam scores are being graded by course lecturers.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              SizedBox(height: 12),
              Divider(color: AppColors.border),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Cumulative GPA:',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  Text(
                    '3.82 / 4.00',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
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
          title: 'Student Services',
          subtitle: 'Profile, Documents, Notifications & Transcripts',
        ),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.badge_outlined, color: AppColors.gold),
            title: const Text(
              'Student Profile',
              style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Matricule: LA-2026-BSC-CS-0001 • ${profile?.email ?? ""}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_outlined, color: AppColors.gold),
            title: const Text(
              'Documents',
              style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Admission letter, registration receipts, identity scans',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined, color: AppColors.gold),
            title: const Text(
              'Notifications',
              style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Academic alerts, fee deadlines, registration notices',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: const StatusChip(status: '2 NEW'),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.verified_outlined, color: AppColors.gold),
            title: const Text(
              'Transcripts',
              style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Generate & download official partial or full transcript PDF',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transcripts invoke generate-transcript Edge Function.'),
                ),
              );
            },
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

  // ===========================================================================
  // 2. LECTURER SHELL
  // Bottom Nav / Drawer:
  // 1. Home
  // 2. My Courses
  // 3. Attendance
  // 4. Grades
  // 5. More
  // ===========================================================================
  Widget _buildLecturerShell(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    const titles = [
      'Lecturer Home',
      'My Courses & Class Roster',
      'Attendance Tracking',
      'Assessment & Grades',
      'More Services',
    ];
    final safeIndex = _selectedIndex.clamp(0, titles.length - 1);

    const lecturerNavItems = [
      ('Home', Icons.home_outlined, Icons.home),
      ('My Courses', Icons.class_outlined, Icons.class_),
      ('Attendance', Icons.fact_check_outlined, Icons.fact_check),
      ('Grades', Icons.grading_outlined, Icons.grading),
      ('More', Icons.more_horiz_outlined, Icons.more_horiz),
    ];

    return Scaffold(
      appBar: _buildAppBar(context, titles[safeIndex], activeRole),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, color: AppColors.primary, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Liah Academy SMS',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const StatusChip(status: 'LECTURER'),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: lecturerNavItems.length,
                  itemBuilder: (context, index) {
                    final item = lecturerNavItems[index];
                    final selected = index == safeIndex;
                    return ListTile(
                      selected: selected,
                      selectedTileColor: AppColors.primaryContainer,
                      leading: Icon(
                        selected ? item.$3 : item.$2,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      title: Text(
                        item.$1,
                        style: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: safeIndex,
        children: [
          ListView(
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
                onTap: () => setState(() => _selectedIndex = 2),
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
                onTap: () => setState(() => _selectedIndex = 3),
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
          ),
          const CourseRegistrationScreen(embedded: true),
          _buildFeatureModulePlaceholder(
            title: 'Attendance Sessions',
            subtitle: 'Take and verify attendance per lecture for enrolled students.',
            icon: Icons.fact_check_outlined,
            status: 'ACTIVE',
          ),
          _buildFeatureModulePlaceholder(
            title: 'Assessment Config & Grade Entry',
            subtitle: 'Configure CA/Exam weight distribution and submit grades for approval.',
            icon: Icons.grading_outlined,
            status: 'DRAFT',
          ),
          _buildStudentMoreTab(context, profile, activeRole),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_),
            label: 'My Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.grading_outlined),
            selectedIcon: Icon(Icons.grading),
            label: 'Grades',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. ADMIN & SUPER ADMIN SHELL
  // Drawer / Side Navigation:
  // Admin:
  // 1. Dashboard
  // 2. Admissions
  // 3. Students
  // 4. Staff
  // 5. Academics
  // 6. Finance
  // 7. Results
  // 8. Reports
  // 9. Settings
  // Super Admin:
  // Same as Admin + extra:
  // - Roles & Permissions
  // - System Configuration
  // - Audit Logs
  // - Fee & Credit Configuration
  // ===========================================================================
  Widget _buildAdminShell(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    final isSuperAdmin = activeRole == AppRole.superAdmin;
    final items = <_AdminNavItem>[
      const _AdminNavItem('Dashboard', Icons.dashboard_outlined),
      const _AdminNavItem('Admissions', Icons.how_to_reg_outlined),
      const _AdminNavItem('Students', Icons.people_alt_outlined),
      const _AdminNavItem('Staff', Icons.badge_outlined),
      const _AdminNavItem('Academics', Icons.school_outlined),
      const _AdminNavItem('Finance', Icons.payments_outlined),
      const _AdminNavItem('Results', Icons.assignment_turned_in_outlined),
      const _AdminNavItem('Reports', Icons.bar_chart_outlined),
      const _AdminNavItem('Settings', Icons.settings_outlined),
      if (isSuperAdmin) ...[
        const _AdminNavItem(
          'Roles & Permissions',
          Icons.admin_panel_settings_outlined,
          superAdminOnly: true,
        ),
        const _AdminNavItem(
          'System Configuration',
          Icons.tune_outlined,
          superAdminOnly: true,
        ),
        const _AdminNavItem(
          'Audit Logs',
          Icons.history_edu_outlined,
          superAdminOnly: true,
        ),
        const _AdminNavItem(
          'Fee & Credit Config',
          Icons.request_quote_outlined,
          superAdminOnly: true,
        ),
      ],
    ];

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
            trailing: nav.superAdminOnly
                ? const Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: AppColors.accent,
                  )
                : null,
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
                    'Liah Academy SMS',
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

    if (isWideScreen) {
      // Side Navigation (Desktop & Wide Tablet)
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
              child: _buildAdminContent(
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

    // Drawer (Mobile & Compact screens)
    return Scaffold(
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
      body: _buildAdminContent(
        context,
        profile,
        activeRole,
        selectedItem.label,
      ),
    );
  }

  Widget _buildAdminContent(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
    String sectionLabel,
  ) {
    return switch (sectionLabel) {
      'Dashboard' => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileRoleBanner(
              profile: profile,
              activeRole: activeRole,
              onRoleChanged: _selectRole,
            ),
            const SizedBox(height: 16),
            SectionHeader(
              title: '${activeRole.label} Workspace',
              subtitle: 'Core administration & school operations',
            ),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _AdminQuickTile(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Admissions',
                  subtitle: 'Applicant processing',
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _AdminQuickTile(
                  icon: Icons.people_alt_outlined,
                  title: 'Students',
                  subtitle: 'Student roster & profiles',
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                _AdminQuickTile(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Create Student',
                  subtitle: 'Matricule auto-generation',
                  onTap: () => context.push(CreateStudentScreen.routePath),
                ),
                _AdminQuickTile(
                  icon: Icons.school_outlined,
                  title: 'Academics',
                  subtitle: 'Courses & offerings',
                  onTap: () => setState(() => _selectedIndex = 4),
                ),
                _AdminQuickTile(
                  icon: Icons.payments_outlined,
                  title: 'Finance',
                  subtitle: 'Tuition & payment reconciliation',
                  onTap: () => setState(() => _selectedIndex = 5),
                ),
                _AdminQuickTile(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Results',
                  subtitle: 'Exam Board workflow',
                  onTap: () => setState(() => _selectedIndex = 6),
                ),
              ],
            ),
          ],
        ),
      'Admissions' => _buildFeatureModulePlaceholder(
          title: 'Admissions Management',
          subtitle: 'Review student applications, approve admissions, and issue matricules.',
          icon: Icons.how_to_reg_outlined,
          status: 'ACTIVE',
        ),
      'Students' => const StudentListScreen(embedded: true),
      'Staff' => _buildFeatureModulePlaceholder(
          title: 'Staff Directory',
          subtitle: 'Faculty lecturers, department heads, and academic advisors.',
          icon: Icons.badge_outlined,
          status: 'ACTIVE',
        ),
      'Academics' => const CourseRegistrationScreen(embedded: true),
      'Finance' => _buildFeatureModulePlaceholder(
          title: 'Finance & Tuition Revenue',
          subtitle: 'Student charges, fee categories, and MTN MoMo / Orange Money reconciliation.',
          icon: Icons.payments_outlined,
          status: 'ACTIVE',
        ),
      'Results' => _buildFeatureModulePlaceholder(
          title: 'Examination Board & Result Approval',
          subtitle: 'Draft ➔ Submitted ➔ Approved ➔ Finalized ➔ Published pipeline.',
          icon: Icons.assignment_turned_in_outlined,
          status: 'ACTIVE',
        ),
      'Reports' => _buildFeatureModulePlaceholder(
          title: 'Reports & Analytics',
          subtitle: 'Enrollment statistics, fee collection rates, and academic performance.',
          icon: Icons.bar_chart_outlined,
          status: 'ACTIVE',
        ),
      'Settings' => _buildStudentMoreTab(context, profile, activeRole),
      'Roles & Permissions' => _buildFeatureModulePlaceholder(
          title: 'Roles & Permissions Matrix',
          subtitle: 'Manage RBAC permissions for Super Admin, Admin, Lecturer, and Student.',
          icon: Icons.admin_panel_settings_outlined,
          status: 'SUPER ADMIN',
        ),
      'System Configuration' => _buildFeatureModulePlaceholder(
          title: 'System Configuration',
          subtitle: 'Configure academic years, semester registration windows, and integrations.',
          icon: Icons.tune_outlined,
          status: 'SUPER ADMIN',
        ),
      'Audit Logs' => _buildFeatureModulePlaceholder(
          title: 'Security Audit Logs',
          subtitle: 'Immutable record of security events, grade approvals, and user modifications.',
          icon: Icons.history_edu_outlined,
          status: 'SUPER ADMIN',
        ),
      'Fee & Credit Config' => _buildFeatureModulePlaceholder(
          title: 'Fee & Credit Bounds Configuration',
          subtitle: 'Set semester credit limits (15-24 credits) and program tuition structures.',
          icon: Icons.request_quote_outlined,
          status: 'SUPER ADMIN',
        ),
      _ => _buildFeatureModulePlaceholder(
          title: sectionLabel,
          subtitle: '$sectionLabel module connected to Supabase RLS and Edge Functions.',
          icon: Icons.layers_outlined,
          status: 'ACTIVE',
        ),
    };
  }

  Widget _buildFeatureModulePlaceholder({
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: AppColors.primary, size: 32),
                  StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
      backgroundColor: AppColors.primary,
      borderColor: AppColors.primaryLight,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  (profile?.fullName.isNotEmpty == true
                          ? profile!.fullName[0]
                          : 'L')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.fullName ?? 'Authenticated User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profile?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(status: activeRole.label),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.primaryLight, height: 1),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final role in AppRole.values)
                ChoiceChip(
                  label: Text(role.label),
                  selected: activeRole == role,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.primaryLight,
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  onSelected: (_) => onRoleChanged(role),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem(
    this.label,
    this.icon, {
    this.superAdminOnly = false,
  });

  final String label;
  final IconData icon;
  final bool superAdminOnly;
}

class _AdminQuickTile extends StatelessWidget {
  const _AdminQuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
