import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'dashboard_data.dart';

class Course {
  final String name;
  final String duration;
  final String tuition;

  const Course({
    required this.name,
    required this.duration,
    required this.tuition,
  });
}

class Program {
  final String title;
  final List<Course> courses;

  const Program({required this.title, required this.courses});
}

final List<Program> programs = [
  const Program(
    title: 'Certification Programs',
    courses: [
      Course(
        name: 'Data Science',
        duration: '9 Months',
        tuition: '350,000 FRS',
      ),
      Course(name: 'DevOps', duration: '9 Months', tuition: '350,000 FRS'),
      Course(
        name: 'Industrial Web Design',
        duration: '6 Months',
        tuition: '300,000 FRS',
      ),
      Course(
        name: 'Digital Marketing and SEO',
        duration: '6 Months',
        tuition: '350,000 FRS',
      ),
    ],
  ),
  const Program(
    title: 'Engineering & Technology — HND (2 Years)',
    courses: [
      Course(
        name: 'Software Engineering',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Web and Graphics Design',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Digital Marketing and E-Commerce',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Network and Maintenance',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
    ],
  ),
  const Program(
    title: 'Engineering & Technology — ND (1 Year)',
    courses: [
      Course(
        name: 'Computer Engineering',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(name: 'ICT', duration: '1 Year', tuition: '150,000 FRS'),
      Course(name: 'Web Design', duration: '1 Year', tuition: '150,000 FRS'),
      Course(
        name: 'Graphics Design and Printing',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(
        name: 'Basic Computer',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(
        name: 'Office Automation Secretaryship',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(
        name: 'Computerized Accounting',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
    ],
  ),
  const Program(
    title: 'Business & Management — HND (2 Years)',
    courses: [
      Course(name: 'Accounting', duration: '2 Years', tuition: '250,000 FRS'),
      Course(name: 'Management', duration: '2 Years', tuition: '250,000 FRS'),
      Course(name: 'Marketing', duration: '2 Years', tuition: '250,000 FRS'),
      Course(
        name: 'Digital Marketing',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Human Resource Management',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
    ],
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.authToken = '',
    this.repository,
    this.onSignOut,
  });

  final String authToken;
  final DashboardRepository? repository;
  final Future<void> Function()? onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _programsKey = GlobalKey();
  late Future<DashboardData> _dashboardFuture;
  _SidebarDestination _selectedDestination = _SidebarDestination.dashboard;
  bool _isSidebarCollapsed = false;

  DashboardRepository get _repository =>
      widget.repository ?? const DemoDashboardRepository();

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    _dashboardFuture = _repository.fetchDashboard(authToken: widget.authToken);
  }

  void _retry() {
    setState(_loadDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      backgroundColor: AppColors.navy,
      drawer: Drawer(
        width: _isSidebarCollapsed ? 72 : 144,
        backgroundColor: AppColors.navyDeep,
        child: SafeArea(child: _buildSidebar()),
      ),
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: _isSidebarCollapsed ? 72 : 144,
              child: _buildSidebar(),
            ),
          Expanded(child: _buildContent(isWide: isWide)),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return _DashboardSidebar(
      selectedDestination: _selectedDestination,
      isCollapsed: _isSidebarCollapsed,
      onDestinationSelected: (destination) {
        setState(() => _selectedDestination = destination);
      },
      onToggleCollapsed: () {
        setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
      },
      onSignOut: _handleSignOut,
    );
  }

  Widget _buildContent({required bool isWide}) {
    return FutureBuilder<DashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final displayName = data?.displayName ?? 'Student';
        Widget section;
        if (snapshot.connectionState != ConnectionState.done) {
          section = const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          section = _DashboardLoadError(onRetry: _retry);
        } else {
          section = _buildSelectedSection(data!);
        }
        return Column(
          children: [
            _StudentTopBar(
              displayName: displayName,
              userId: data?.userId ?? '',
              profileImageUrl: data?.profileImageUrl,
              showMenu: !isWide,
              onMenuTap: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(child: section),
          ],
        );
      },
    );
  }

  Widget _buildSelectedSection(DashboardData data) {
    return switch (_selectedDestination) {
      _SidebarDestination.dashboard =>
        data.role == DashboardRole.student
            ? _buildStudentDashboard(data)
            : Container(color: AppColors.navy, child: _buildDashboard(data)),
      _SidebarDestination.registration => _buildRegistrationPage(data),
      _SidebarDestination.courses => _buildProgramsPage(data, 'Courses'),
      _ => _buildUnavailableSection(_selectedDestination.label),
    };
  }

  Widget _buildProgramsPage(DashboardData data, String title) {
    if (data.role != DashboardRole.student) {
      return _buildUnavailableSection(title);
    }
    return Container(
      color: AppColors.navy,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeading(title),
          const SizedBox(height: 8),
          const Text(
            'Browse available programs and courses.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ...programs.map((program) => _ProgramCard(program: program)),
        ],
      ),
    );
  }

  Widget _buildRegistrationPage(DashboardData data) {
    if (data.role != DashboardRole.student) {
      return _buildUnavailableSection('Registration');
    }
    final registration =
        data.studentRegistration ?? StudentRegistrationSummary.demo();
    final daysRemaining = DateUtils.dateOnly(
      registration.deadline,
    ).difference(DateUtils.dateOnly(DateTime.now())).inDays;
    final deadlineDetail = daysRemaining >= 0
        ? '$daysRemaining days remaining'
        : '${-daysRemaining} days overdue';
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: EdgeInsets.all(constraints.maxWidth < 600 ? 14 : 20),
        children: [
          const Text(
            'Registration',
            style: TextStyle(
              color: AppColors.onNavy,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage your academic registration and document uploads.',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 18),
          _RegistrationSummaryGrid(
            registration: registration,
            deadlineDetail: deadlineDetail,
            width: constraints.maxWidth,
          ),
          const SizedBox(height: 16),
          _StudentPanel(
            title: 'Required Documents',
            child: Column(
              children: registration.documents
                  .map((document) => _RequiredDocumentRow(document: document))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableSection(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.onNavy,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This section will be available when the academy service is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final onSignOut = widget.onSignOut;
    if (onSignOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign out is not available yet.')),
      );
      return;
    }
    await onSignOut();
  }

  Widget _buildDashboard(DashboardData data) {
    final actions = _actionsFor(data.role);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Good morning, ${data.displayName}',
          style: const TextStyle(
            color: AppColors.onNavy,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${data.role.label} dashboard',
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        const _SectionHeading('Your shortcuts'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth >= 560 ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 10,
              mainAxisExtent: 72,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _DashboardActionTile(
                action: action,
                onTap: () => _handleAction(action, data.role),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading('Quick stats'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: data.metrics
                .map(
                  (metric) => SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _MetricTile(metric: metric),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading('Notifications'),
        const SizedBox(height: 8),
        if (data.notifications.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'You are all caught up.',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        else
          ...data.notifications.map(
            (notification) => _NotificationRow(notification: notification),
          ),
        if (data.role == DashboardRole.student) ...[
          const SizedBox(height: 24),
          _SectionHeading('Programs', key: _programsKey),
          const SizedBox(height: 12),
          ...programs.map((program) => _ProgramCard(program: program)),
        ],
      ],
    );
  }

  Widget _buildStudentDashboard(DashboardData data) {
    final finance = data.studentFinance ?? const StudentFinanceSnapshot();
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: EdgeInsets.all(constraints.maxWidth < 600 ? 14 : 20),
        children: [
          const Text(
            'Academic Records & Financial Clearance',
            style: TextStyle(
              color: AppColors.onNavy,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back, ${data.displayName}',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          _ResultsLockNotice(finance: finance),
          const SizedBox(height: 16),
          _StudentMetricGrid(finance: finance, width: constraints.maxWidth),
          const SizedBox(height: 16),
          if (constraints.maxWidth >= 760)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _RecentTransactions(finance: finance)),
                const SizedBox(width: 16),
                Expanded(child: _UpcomingDeadlines(finance: finance)),
              ],
            )
          else ...[
            _RecentTransactions(finance: finance),
            const SizedBox(height: 12),
            _UpcomingDeadlines(finance: finance),
          ],
        ],
      ),
    );
  }

  void _handleAction(_DashboardAction action, DashboardRole role) {
    if (role == DashboardRole.student &&
        action.title == 'Register / Sign Courses') {
      final target = _programsKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 250),
        );
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${action.title} is not available yet.')),
    );
  }
}

enum _SidebarDestination {
  dashboard('Dashboard', Icons.dashboard_outlined),
  registration('Registration', Icons.assignment_outlined),
  courses('Courses', Icons.menu_book_outlined),
  results('Results', Icons.bar_chart_outlined),
  finance('Finance', Icons.account_balance_wallet_outlined),
  timetable('Timetable', Icons.calendar_month_outlined),
  attendance('Attendance', Icons.fact_check_outlined),
  settings('Settings', Icons.settings_outlined);

  const _SidebarDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.selectedDestination,
    required this.isCollapsed,
    required this.onDestinationSelected,
    required this.onToggleCollapsed,
    required this.onSignOut,
  });

  final _SidebarDestination selectedDestination;
  final bool isCollapsed;
  final ValueChanged<_SidebarDestination> onDestinationSelected;
  final VoidCallback onToggleCollapsed;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final destinations = _SidebarDestination.values
        .where((destination) => destination != _SidebarDestination.settings)
        .toList();
    return Container(
      color: AppColors.navyDeep,
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (final destination in destinations)
            _SidebarItem(
              destination: destination,
              selected: selectedDestination == destination,
              isCollapsed: isCollapsed,
              onTap: () => _select(context, destination),
            ),
          const Spacer(),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _SidebarItem(
            destination: _SidebarDestination.settings,
            selected: selectedDestination == _SidebarDestination.settings,
            isCollapsed: isCollapsed,
            onTap: () => _select(context, _SidebarDestination.settings),
          ),
          _SidebarFooterAction(
            icon: Icons.logout,
            label: 'Sign out',
            isCollapsed: isCollapsed,
            color: AppColors.gold,
            onTap: () async {
              await onSignOut();
            },
          ),
          _SidebarFooterAction(
            icon: isCollapsed ? Icons.chevron_right : Icons.chevron_left,
            label: isCollapsed ? 'Expand' : 'Collapse',
            isCollapsed: isCollapsed,
            onTap: onToggleCollapsed,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _select(BuildContext context, _SidebarDestination destination) {
    onDestinationSelected(destination);
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.isCollapsed,
    required this.onTap,
  });

  final _SidebarDestination destination;
  final bool selected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Tooltip(
        message: isCollapsed ? destination.label : '',
        child: SizedBox(
          height: 29,
          child: Material(
            color: selected ? AppColors.surfaceRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: onTap,
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Icon(
                    destination.icon,
                    size: 14,
                    color: selected ? AppColors.onNavy : AppColors.muted,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? AppColors.onNavy : AppColors.muted,
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ] else
                    const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooterAction extends StatelessWidget {
  const _SidebarFooterAction({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.onTap,
    this.color = AppColors.muted,
  });

  final IconData icon;
  final String label;
  final bool isCollapsed;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Tooltip(
        message: isCollapsed ? label : '',
        child: SizedBox(
          height: 29,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: color,
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onTap,
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(icon, size: 14),
                if (!isCollapsed) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentTopBar extends StatefulWidget {
  const _StudentTopBar({
    required this.displayName,
    required this.userId,
    required this.profileImageUrl,
    required this.showMenu,
    required this.onMenuTap,
  });

  final String displayName;
  final String userId;
  final String? profileImageUrl;
  final bool showMenu;
  final VoidCallback onMenuTap;

  @override
  State<_StudentTopBar> createState() => _StudentTopBarState();
}

class _StudentTopBarState extends State<_StudentTopBar> {
  String _language = 'EN';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 620;
    final narrow = width < 620;
    return Container(
      height: narrow ? 96 : 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: AppColors.navyDeep,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: narrow
          ? Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (widget.showMenu) _menuButton(),
                      const Spacer(),
                      _languageToggle(),
                      const SizedBox(width: 7),
                      _notificationButton(context),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _brandLabel(),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _ProfileIdentity(
                      displayName: widget.displayName,
                      userId: widget.userId,
                      imageUrl: widget.profileImageUrl,
                      compact: true,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                if (widget.showMenu) ...[
                  _menuButton(),
                  const SizedBox(width: 8),
                ],
                _brandLabel(),
                if (!compact) ...[
                  const SizedBox(width: 20),
                  Expanded(child: _searchField()),
                ] else
                  const Spacer(),
                const SizedBox(width: 10),
                _languageToggle(),
                const SizedBox(width: 7),
                _notificationButton(context),
                const SizedBox(width: 10),
                Container(width: 1, height: 25, color: AppColors.border),
                const SizedBox(width: 10),
                _ProfileIdentity(
                  displayName: widget.displayName,
                  userId: widget.userId,
                  imageUrl: widget.profileImageUrl,
                  compact: false,
                ),
              ],
            ),
    );
  }

  Widget _menuButton() => SizedBox(
    width: 30,
    child: IconButton(
      tooltip: 'Open navigation',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      onPressed: widget.onMenuTap,
      icon: const Icon(Icons.menu, size: 19),
    ),
  );

  Widget _brandLabel() => const Text(
    'Liah Academy',
    maxLines: 1,
    style: TextStyle(
      color: AppColors.gold,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _searchField() => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 330),
    child: SizedBox(
      height: 30,
      child: TextField(
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search records...',
          hintStyle: const TextStyle(fontSize: 11, color: AppColors.muted),
          prefixIcon: const Icon(
            Icons.search,
            size: 15,
            color: AppColors.muted,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 30,
          ),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );

  Widget _languageToggle() => Container(
    height: 26,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      children: [
        _LanguageOption(
          label: 'EN',
          selected: _language == 'EN',
          onPressed: () => setState(() => _language = 'EN'),
        ),
        _LanguageOption(
          label: 'FR',
          selected: _language == 'FR',
          onPressed: () => setState(() => _language = 'FR'),
        ),
      ],
    ),
  );

  Widget _notificationButton(BuildContext context) => SizedBox(
    width: 30,
    height: 32,
    child: IconButton(
      tooltip: 'Notifications',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      onPressed: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No new notifications'))),
      icon: const Badge(
        smallSize: 6,
        child: Icon(Icons.notifications_none, size: 18, color: AppColors.muted),
      ),
    ),
  );
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.displayName,
    required this.userId,
    required this.imageUrl,
    required this.compact,
  });

  final String displayName;
  final String userId;
  final String? imageUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.surfaceRaised,
          backgroundImage: imageUrl == null || imageUrl!.isEmpty
              ? null
              : NetworkImage(imageUrl!),
          onBackgroundImageError: imageUrl == null || imageUrl!.isEmpty
              ? null
              : (_, _) {},
          child: imageUrl == null || imageUrl!.isEmpty
              ? Text(
                  initials.isEmpty ? 'U' : initials,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: compact ? 120 : 145,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userId.isEmpty ? 'Account ID unavailable' : userId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 22,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: selected
              ? AppColors.surfaceRaised
              : Colors.transparent,
          foregroundColor: selected ? AppColors.gold : AppColors.muted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ResultsLockNotice extends StatelessWidget {
  const _ResultsLockNotice({required this.finance});

  final StudentFinanceSnapshot finance;

  @override
  Widget build(BuildContext context) {
    final locked = finance.balanceDue > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.goldTint,
        border: Border.all(color: AppColors.gold),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            locked ? Icons.lock_outline : Icons.lock_open_outlined,
            size: 15,
            color: AppColors.gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locked
                      ? 'Your results for ${finance.semester} are locked until tuition balance is 0 XAF.'
                      : 'Your results for ${finance.semester} are available.',
                  style: const TextStyle(color: AppColors.onNavy, fontSize: 11),
                ),
                if (locked) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Balance Due: ${_formatXaf(finance.balanceDue)} XAF',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationSummaryGrid extends StatelessWidget {
  const _RegistrationSummaryGrid({
    required this.registration,
    required this.deadlineDetail,
    required this.width,
  });

  final StudentRegistrationSummary registration;
  final String deadlineDetail;
  final double width;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _RegistrationSummaryCard(
        label: 'Registration Status',
        value: registration.status,
        detail: registration.academicYear,
        icon: Icons.task_alt_outlined,
        color: AppColors.gold,
      ),
      _RegistrationSummaryCard(
        label: 'Registration Deadline',
        value: _formatRegistrationDate(registration.deadline),
        detail: deadlineDetail,
        icon: Icons.schedule_outlined,
        color: AppColors.gold,
      ),
      _RegistrationSummaryCard(
        label: 'Documents Uploaded',
        value:
            '${registration.uploadedCount} / ${registration.documents.length}',
        detail: '${registration.pendingCount} documents pending',
        icon: Icons.upload_file_outlined,
        color: AppColors.gold,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width >= 760 ? 3 : 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 96,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class _RegistrationSummaryCard extends StatelessWidget {
  const _RegistrationSummaryCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.muted),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _RequiredDocumentRow extends StatelessWidget {
  const _RequiredDocumentRow({required this.document});

  final StudentRegistrationDocument document;

  @override
  Widget build(BuildContext context) {
    final statusColor = document.uploaded ? AppColors.gold : AppColors.gold;
    return Container(
      constraints: const BoxConstraints(minHeight: 39),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              document.name,
              style: const TextStyle(color: AppColors.onNavy, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            document.uploaded ? Icons.check : Icons.hourglass_bottom,
            size: 11,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            document.uploaded ? 'Uploaded' : 'Pending',
            style: TextStyle(color: statusColor, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

String _formatRegistrationDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

class _StudentMetricGrid extends StatelessWidget {
  const _StudentMetricGrid({required this.finance, required this.width});

  final StudentFinanceSnapshot finance;
  final double width;

  @override
  Widget build(BuildContext context) {
    final total = finance.totalFees;
    final paidPercent = total == 0 ? 1.0 : finance.feesPaid / total;
    final metrics = [
      _StudentMetric(
        label: 'FEE STATUS',
        value: '${(paidPercent * 100).round()}%',
        icon: Icons.people_outline,
        detail: '${_formatXaf(finance.feesPaid)} / ${_formatXaf(total)} XAF',
        status: finance.feeStatus,
        progress: paidPercent,
      ),
      _StudentMetric(
        label: 'CREDITS ENROLLED',
        value: '${finance.creditsEnrolled}',
        icon: Icons.menu_book_outlined,
        detail: '${finance.creditsEnrolled} courses',
      ),
      _StudentMetric(
        label: 'CURRENT GPA',
        value: finance.currentGpa?.toStringAsFixed(2) ?? '—',
        icon: Icons.trending_up,
        detail: finance.currentGpa == null ? 'No grades yet' : 'Current term',
      ),
      _StudentMetric(
        label: 'ATTENDANCE RATE',
        value: finance.attendanceRate == null
            ? '—'
            : '${finance.attendanceRate!.round()}%',
        icon: Icons.groups_outlined,
        detail: finance.attendanceRate == null ? 'No records yet' : 'This term',
      ),
    ];
    final columns = width >= 900
        ? 4
        : width >= 560
        ? 2
        : 1;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 112,
      ),
      itemBuilder: (context, index) =>
          _StudentMetricCard(metric: metrics[index]),
    );
  }
}

class _StudentMetric {
  const _StudentMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.detail,
    this.status,
    this.progress,
  });

  final String label;
  final String value;
  final IconData icon;
  final String detail;
  final String? status;
  final double? progress;
}

class _StudentMetricCard extends StatelessWidget {
  const _StudentMetricCard({required this.metric});

  final _StudentMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (metric.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    metric.status!,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Icon(metric.icon, size: 13, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
          ),
          if (metric.progress != null) ...[
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: metric.progress,
                minHeight: 4,
                backgroundColor: AppColors.border,
                color: AppColors.gold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.finance});

  final StudentFinanceSnapshot finance;

  @override
  Widget build(BuildContext context) {
    return _StudentPanel(
      title: 'Recent Transactions',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (finance.transactions.isEmpty) {
            return const SizedBox(
              height: 95,
              child: Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
            );
          }
          if (constraints.maxWidth < 480) {
            return Column(
              children: finance.transactions
                  .map((transaction) => _TransactionCompactRow(transaction))
                  .toList(),
            );
          }
          return Column(
            children: [
              _TransactionTableHeader(),
              ...finance.transactions.map(_TransactionTableRow.new),
            ],
          );
        },
      ),
    );
  }
}

class _UpcomingDeadlines extends StatelessWidget {
  const _UpcomingDeadlines({required this.finance});

  final StudentFinanceSnapshot finance;

  @override
  Widget build(BuildContext context) {
    return _StudentPanel(
      title: 'Upcoming Deadlines',
      child: finance.upcomingDeadlines.isEmpty
          ? const SizedBox(
              height: 95,
              child: Center(
                child: Text(
                  'No deadlines configured yet',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
            )
          : Column(
              children: finance.upcomingDeadlines
                  .map(
                    (deadline) => ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      title: Text(
                        deadline,
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _StudentPanel extends StatelessWidget {
  const _StudentPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.onNavy,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          child,
        ],
      ),
    );
  }
}

class _TransactionTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const _TransactionTableLine(
    values: ['Transaction ID', 'Method', 'Amount (XAF)', 'Status', 'Date'],
    isHeader: true,
  );
}

class _TransactionTableRow extends StatelessWidget {
  const _TransactionTableRow(this.transaction);

  final StudentTransaction transaction;

  @override
  Widget build(BuildContext context) => _TransactionTableLine(
    values: [
      transaction.id,
      transaction.method,
      _formatXaf(transaction.amount),
      transaction.status,
      transaction.date,
    ],
  );
}

class _TransactionTableLine extends StatelessWidget {
  const _TransactionTableLine({required this.values, this.isHeader = false});

  final List<String> values;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    const flexes = [2, 2, 1, 1, 1];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: isHeader
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            )
          : null,
      child: Row(
        children: [
          for (var index = 0; index < values.length; index++)
            Expanded(
              flex: flexes[index],
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  values[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isHeader ? AppColors.muted : AppColors.onNavy,
                    fontSize: isHeader ? 9 : 10,
                    fontWeight: isHeader ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TransactionCompactRow extends StatelessWidget {
  const _TransactionCompactRow(this.transaction);

  final StudentTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        transaction.method,
        style: const TextStyle(color: AppColors.onNavy, fontSize: 11),
      ),
      subtitle: Text(
        '${transaction.id} · ${transaction.date}',
        style: const TextStyle(color: AppColors.muted, fontSize: 9),
      ),
      trailing: Text(
        '${_formatXaf(transaction.amount)} XAF',
        style: const TextStyle(color: AppColors.onNavy, fontSize: 10),
      ),
    );
  }
}

String _formatXaf(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

class _DashboardAction {
  final String title;
  final String description;
  final IconData icon;

  const _DashboardAction(this.title, this.description, this.icon);
}

List<_DashboardAction> _actionsFor(DashboardRole role) => switch (role) {
  DashboardRole.student => const [
    _DashboardAction(
      'View Results',
      'Check your latest grades',
      Icons.grade_outlined,
    ),
    _DashboardAction(
      'Register / Sign Courses',
      'Browse programs and courses',
      Icons.library_add_outlined,
    ),
    _DashboardAction(
      'Pay Fees via MoMo',
      'Make a mobile money payment',
      Icons.payments_outlined,
    ),
    _DashboardAction(
      'Download Admission Letter',
      'Get your admission document',
      Icons.download_outlined,
    ),
    _DashboardAction(
      'Track Application Status',
      'Follow your application progress',
      Icons.track_changes_outlined,
    ),
    _DashboardAction(
      'Notifications',
      'See updates from the academy',
      Icons.notifications_outlined,
    ),
  ],
  DashboardRole.teacher => const [
    _DashboardAction(
      'View Assigned Courses',
      'Open your teaching schedule',
      Icons.menu_book_outlined,
    ),
    _DashboardAction(
      'Upload Grades',
      'Submit student assessment results',
      Icons.grade_outlined,
    ),
    _DashboardAction(
      'Manage Attendance',
      'Update class attendance',
      Icons.fact_check_outlined,
    ),
    _DashboardAction(
      'Message Students',
      'Communicate with your classes',
      Icons.forum_outlined,
    ),
  ],
  DashboardRole.admin => const [
    _DashboardAction(
      'Approve Admissions',
      'Review pending applications',
      Icons.how_to_reg_outlined,
    ),
    _DashboardAction(
      'Verify Payments',
      'Review pending transactions',
      Icons.verified_outlined,
    ),
    _DashboardAction(
      'Manage Programs',
      'Create and update programs',
      Icons.menu_book_outlined,
    ),
    _DashboardAction(
      'Generate Reports',
      'Review academy performance',
      Icons.summarize_outlined,
    ),
    _DashboardAction(
      'Send Announcements',
      'Share updates with the academy',
      Icons.campaign_outlined,
    ),
  ],
  DashboardRole.superAdmin => const [
    _DashboardAction(
      'System Configuration',
      'Manage institution settings & roles',
      Icons.settings_suggest_outlined,
    ),
    _DashboardAction(
      'Manage Admins',
      'Create and manage admin accounts',
      Icons.admin_panel_settings_outlined,
    ),
    _DashboardAction(
      'Configure Fees',
      'Set tuition and payment structures',
      Icons.price_change_outlined,
    ),
    _DashboardAction(
      'Publish Final Results',
      'Approve and publish school grades',
      Icons.published_with_changes_outlined,
    ),
    _DashboardAction(
      'Audit Logs',
      'View system-wide security actions',
      Icons.receipt_long_outlined,
    ),
  ],
  DashboardRole.parent => const [
    _DashboardAction(
      'Monitor Student Progress',
      'Review grades and attendance',
      Icons.insights_outlined,
    ),
    _DashboardAction(
      'Fee Reminders',
      'Review upcoming payment dates',
      Icons.notifications_active_outlined,
    ),
  ],
};

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.onNavy,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _DashboardActionTile extends StatelessWidget {
  const _DashboardActionTile({required this.action, required this.onTap});

  final _DashboardAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(action.icon, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      action.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, size: 20, color: AppColors.gold),
          const SizedBox(height: 8),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final DashboardNotification notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications_none, color: AppColors.gold),
          title: Text(
            notification.title,
            style: const TextStyle(color: AppColors.onNavy),
          ),
          subtitle: Text(
            notification.message,
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _DashboardLoadError extends StatelessWidget {
  const _DashboardLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dashboard data could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onNavy),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final Program program;

  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        iconColor: AppColors.gold,
        collapsedIconColor: AppColors.gold,
        title: Text(
          program.title,
          style: const TextStyle(
            color: AppColors.onNavy,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: program.courses.map((course) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(color: AppColors.onNavy),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.duration} • ${course.tuition}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Registered for ${course.name} (placeholder)',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: AppColors.navyDeep, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
