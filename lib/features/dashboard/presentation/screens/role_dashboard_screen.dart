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
import '../../../authentication/domain/entities/user_profile.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/screens/login_screen.dart';
import '../../../course_registration/presentation/screens/course_registration_screen.dart';
import '../../../students/presentation/screens/create_student_screen.dart';
import '../../../students/presentation/screens/student_list_screen.dart';

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

  // ---------------------------------------------------------------------------
  // 1. STUDENT SHELL (Bottom Navigation: Home, Courses, Fees, Results, More)
  // ---------------------------------------------------------------------------
  Widget _buildStudentShell(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    const titles = [
      'Student Dashboard',
      'Course Registration',
      'Fees & Payments',
      'Academic Results',
      'More',
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
          _buildMoreTab(
            context,
            profile,
            activeRole,
            extraItems: const [
              ('Documents', 'Admission letter, receipts, uploads', Icons.folder_outlined),
              ('Transcripts', 'Request official full or partial transcript', Icons.verified_outlined),
              ('Notifications', 'Academic & financial alerts', Icons.notifications_outlined),
            ],
          ),
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
          title: 'Semester Summary',
          subtitle: 'First Semester 2026/2027',
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
                      'Add or drop semester offerings',
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
                      'Fee Status',
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
                        fontSize: 13,
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
          title: 'Recent Announcements',
          subtitle: 'Official notices from Liah Academy',
        ),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.campaign_outlined, color: AppColors.gold),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'First Semester 2026/2027 Registration Open',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Students may now register for First Semester courses under the Courses tab.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
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
                    'Outstanding Balance',
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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Pay with MTN MoMo / Orange Money',
                icon: Icons.payments_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mobile Money payment intent flows through create-payment-intent Edge Function.',
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
          subtitle: 'Amounts in Central African CFA (XAF)',
        ),
        const AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester Tuition',
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
      ],
    );
  }

  Widget _buildStudentResultsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SectionHeader(
          title: 'Published Results',
          subtitle: 'Only results with workflow_status = published are shown',
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
                    ),
                  ),
                  StatusChip(status: 'PENDING'),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Results will appear here once finalized and published by the Academic Board.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. LECTURER SHELL (Bottom Navigation: Home, My Courses, Attendance, Grades, More)
  // ---------------------------------------------------------------------------
  Widget _buildLecturerShell(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole,
  ) {
    const titles = [
      'Lecturer Dashboard',
      'My Courses & Roster',
      'Attendance',
      'Assessment & Grades',
      'More',
    ];
    final safeIndex = _selectedIndex.clamp(0, titles.length - 1);

    return Scaffold(
      appBar: _buildAppBar(context, titles[safeIndex], activeRole),
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
                subtitle: 'Manage assigned offerings, attendance, and grades',
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
                    'View enrolled students per course offering',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                onTap: () => setState(() => _selectedIndex = 3),
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.rule_folder_outlined, color: AppColors.gold),
                  title: Text(
                    'Enter CA / Exam Scores & Submit Grades',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Submit course grades for Admin approval',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const CourseRegistrationScreen(embedded: true),
          _buildFeatureModulePlaceholder(
            title: 'Attendance Sessions',
            subtitle: 'Mark and review class attendance for assigned offerings.',
            icon: Icons.fact_check_outlined,
            status: 'ACTIVE',
          ),
          _buildFeatureModulePlaceholder(
            title: 'Assessment Config & Grade Entry',
            subtitle:
                'Configure CA/Exam weights, enter student scores, and invoke submit-course-grades.',
            icon: Icons.grading_outlined,
            status: 'DRAFT',
          ),
          _buildMoreTab(context, profile, activeRole),
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
            label: 'More',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ADMIN & SUPER ADMIN SHELL (Drawer / Side Navigation)
  // ---------------------------------------------------------------------------
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

    return Scaffold(
      appBar: _buildAppBar(context, selectedItem.label, activeRole),
      drawer: Drawer(
        backgroundColor: AppColors.navyDeep,
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
                        const Icon(
                          Icons.school_outlined,
                          color: AppColors.gold,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Liah Academy SMS',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.onNavy,
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
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final nav = items[index];
                    final selected = index == safeIndex;
                    return ListTile(
                      selected: selected,
                      selectedTileColor: AppColors.surfaceRaised,
                      leading: Icon(
                        nav.icon,
                        color: selected ? AppColors.gold : AppColors.muted,
                      ),
                      title: Text(
                        nav.label,
                        style: TextStyle(
                          color: selected ? AppColors.gold : AppColors.onNavy,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: nav.superAdminOnly
                          ? const Icon(
                              Icons.shield_outlined,
                              size: 15,
                              color: AppColors.gold,
                            )
                          : null,
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
      body: _buildAdminContent(context, profile, activeRole, selectedItem.label),
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
              subtitle: 'Core administration & academic operations',
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
                  icon: Icons.people_alt_outlined,
                  title: 'Students',
                  subtitle: 'Directory & matricules',
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                _AdminQuickTile(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Create Student',
                  subtitle: 'Edge Function enrollment',
                  onTap: () => context.push(CreateStudentScreen.routePath),
                ),
                _AdminQuickTile(
                  icon: Icons.school_outlined,
                  title: 'Academics',
                  subtitle: 'Offerings & registration',
                  onTap: () => setState(() => _selectedIndex = 4),
                ),
                _AdminQuickTile(
                  icon: Icons.payments_outlined,
                  title: 'Finance',
                  subtitle: 'Fee rules & payments',
                  onTap: () => setState(() => _selectedIndex = 5),
                ),
              ],
            ),
          ],
        ),
      'Students' => const StudentListScreen(embedded: true),
      'Academics' => const CourseRegistrationScreen(embedded: true),
      'Settings' => _buildMoreTab(context, profile, activeRole),
      _ => _buildFeatureModulePlaceholder(
          title: sectionLabel,
          subtitle:
              '$sectionLabel module connected to Supabase RLS and Edge Functions.',
          icon: Icons.layers_outlined,
          status: 'ACTIVE',
        ),
    };
  }

  Widget _buildMoreTab(
    BuildContext context,
    UserProfile? profile,
    AppRole activeRole, {
    List<(String, String, IconData)> extraItems = const [],
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileRoleBanner(
          profile: profile,
          activeRole: activeRole,
          onRoleChanged: _selectRole,
        ),
        const SizedBox(height: 16),
        if (extraItems.isNotEmpty) ...[
          const SectionHeader(title: 'Services & Records'),
          for (final item in extraItems) ...[
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.$3, color: AppColors.gold),
                title: Text(
                  item.$1,
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  item.$2,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
        const SectionHeader(title: 'Account & Security'),
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
                  Icon(icon, color: AppColors.gold, size: 32),
                  StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
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
      backgroundColor: AppColors.navyDeep,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.goldTint,
                child: Text(
                  (profile?.fullName.isNotEmpty == true
                          ? profile!.fullName[0]
                          : 'L')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.gold,
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
                        color: AppColors.onNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profile?.email ?? '',
                      style: const TextStyle(
                        color: AppColors.muted,
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
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final role in AppRole.values)
                ChoiceChip(
                  label: Text(role.label),
                  selected: activeRole == role,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.surfaceRaised,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: activeRole == role
                        ? AppColors.navyDeep
                        : AppColors.onNavy,
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
          Icon(icon, color: AppColors.gold, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onNavy,
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
                  color: AppColors.muted,
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
