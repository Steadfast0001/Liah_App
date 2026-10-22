import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'dashboard_data.dart';

/// Access level indicators from the Liah Academy security specification.
enum AccessLevel {
  /// ✅ Required / expected access
  granted,

  /// 🔒 Restricted
  restricted,

  /// 🟡 Requires confirmation
  requiresConfirmation,

  /// 🔒/🟡 Restricted unless explicit confirmation/override provided
  restrictedOrConfirmation,
}

extension AccessLevelExtension on AccessLevel {
  String get symbol => switch (this) {
        AccessLevel.granted => '✅',
        AccessLevel.restricted => '🔒',
        AccessLevel.requiresConfirmation => '🟡',
        AccessLevel.restrictedOrConfirmation => '🔒/🟡',
      };

  String get label => switch (this) {
        AccessLevel.granted => 'Expected Access',
        AccessLevel.restricted => 'Restricted',
        AccessLevel.requiresConfirmation => 'Requires Confirmation',
        AccessLevel.restrictedOrConfirmation => 'Restricted / Confirmation',
      };

  Color get color => switch (this) {
        AccessLevel.granted => const Color(0xFF22C55E),
        AccessLevel.restricted => const Color(0xFFEF4444),
        AccessLevel.requiresConfirmation => const Color(0xFFF59E0B),
        AccessLevel.restrictedOrConfirmation => const Color(0xFFF97316),
      };

  IconData get icon => switch (this) {
        AccessLevel.granted => Icons.check_circle_outline,
        AccessLevel.restricted => Icons.lock_outline,
        AccessLevel.requiresConfirmation => Icons.warning_amber_rounded,
        AccessLevel.restrictedOrConfirmation => Icons.security,
      };

  bool get isDirectlyAllowed => this == AccessLevel.granted;
  bool get isRestricted => this == AccessLevel.restricted;
  bool get needsConfirmation =>
      this == AccessLevel.requiresConfirmation ||
      this == AccessLevel.restrictedOrConfirmation;
}

/// The 24 standard modules and functions defined in the institutional baseline.
enum AppModuleFunction {
  login('Login', 'System authentication and session initialization'),
  selfRegistration('Self-registration', 'Public or invited profile self-enrollment'),
  userManagement('User management', 'Creation, editing, and archiving of user accounts'),
  roleManagement('Role management', 'Assignment and modification of user roles and security privileges'),
  systemConfiguration('System configuration', 'Core parameters, semester dates, and academic policies'),
  studentManagement('Student management', 'Admission records, biodata, and academic standing records'),
  lecturerManagement('Lecturer management', 'Faculty directory, contracts, and workload allocation'),
  academicManagement('Academic management', 'Faculties, departments, degree curricula, and course programs'),
  enrollment('Enrollment', 'Semester matriculation, fee-linked activation, and session enrollment'),
  courseManagement('Course management', 'Course catalog, credit weighting, syllabi, and prerequisites'),
  examinationSetup('Examination setup', 'Assessment weightings, exam timetabling, and hall allocations'),
  enterMarks('Enter marks', 'CA continuous assessment and semester terminal exam score entry'),
  viewResults('View results', 'Senate broadsheets, individual grade reports, and GPA/CGPA computation'),
  timetableManagement('Timetable management', 'Lecture scheduling, room allocations, and schedule conflict resolution'),
  viewTimetable('View timetable', 'Day and week lecture, lab, and examination schedules'),
  feeConfiguration('Fee configuration', 'Tuition schedules, installment milestones, and late penalty rules'),
  recordManualPayment('Record manual payment', 'Physical bank deposit slip (UBA/Afriland) validation and receipting'),
  onlinePayment('Online payment', 'Direct mobile money (MTN MoMo/Orange Money) or card transactions'),
  viewOwnFinancialRecords('View own financial records', 'Statement of account, payment receipts, and balance status'),
  announcements('Announcements', 'Publishing institution-wide, faculty, or course notices and circulars'),
  viewAnnouncements('View announcements', 'Reading verified institutional notices and urgent alerts'),
  reports('Reports', 'Bursary statements, enrollment statistics, and academic performance aggregates'),
  documentManagement('Document management', 'Attestations, transcripts, admission letters, and certificates'),
  auditLogs('Audit logs', 'Immutable activity trails, login histories, and sensitive operation traces');

  final String title;
  final String description;

  const AppModuleFunction(this.title, this.description);
}

/// Baseline Role-Permission Matrix for Liah Academy.
/// Roles: Super Admin, Admin, Lecturer, Student.
class RolePermissionMatrix {
  static const Map<AppModuleFunction, Map<DashboardRole, AccessLevel>> matrix = {
    AppModuleFunction.login: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.granted,
      DashboardRole.student: AccessLevel.granted,
    },
    AppModuleFunction.selfRegistration: {
      DashboardRole.superAdmin: AccessLevel.requiresConfirmation,
      DashboardRole.admin: AccessLevel.restricted,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.granted,
    },
    AppModuleFunction.userManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.roleManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.systemConfiguration: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.studentManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.requiresConfirmation,
    },
    AppModuleFunction.lecturerManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.academicManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.enrollment: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.requiresConfirmation,
    },
    AppModuleFunction.courseManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.requiresConfirmation,
    },
    AppModuleFunction.examinationSetup: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.enterMarks: {
      DashboardRole.superAdmin: AccessLevel.restrictedOrConfirmation,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.viewResults: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.granted,
    },
    AppModuleFunction.timetableManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.viewTimetable: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.granted,
      DashboardRole.student: AccessLevel.granted,
    },
    AppModuleFunction.feeConfiguration: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.recordManualPayment: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.onlinePayment: {
      DashboardRole.superAdmin: AccessLevel.requiresConfirmation,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.granted,
    },
    AppModuleFunction.viewOwnFinancialRecords: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.granted,
    },
    AppModuleFunction.announcements: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.restricted,
    },
    AppModuleFunction.viewAnnouncements: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.granted,
      DashboardRole.teacher: AccessLevel.granted,
      DashboardRole.student: AccessLevel.granted,
    },
    AppModuleFunction.reports: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.requiresConfirmation,
    },
    AppModuleFunction.documentManagement: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.requiresConfirmation,
      DashboardRole.student: AccessLevel.requiresConfirmation,
    },
    AppModuleFunction.auditLogs: {
      DashboardRole.superAdmin: AccessLevel.granted,
      DashboardRole.admin: AccessLevel.requiresConfirmation,
      DashboardRole.teacher: AccessLevel.restricted,
      DashboardRole.student: AccessLevel.restricted,
    },
  };

  /// Returns the access level for a given role and module function.
  static AccessLevel getAccess(DashboardRole role, AppModuleFunction function) {
    final roleMap = matrix[function];
    if (roleMap == null) return AccessLevel.restricted;
    return roleMap[role] ?? AccessLevel.restricted;
  }

  /// Checks if a role is directly granted access.
  static bool isGranted(DashboardRole role, AppModuleFunction function) {
    return getAccess(role, function) == AccessLevel.granted;
  }

  /// Checks if a role is restricted from this function.
  static bool isRestricted(DashboardRole role, AppModuleFunction function) {
    return getAccess(role, function) == AccessLevel.restricted;
  }

  /// Checks if an action requires confirmation before proceeding.
  static bool requiresConfirmation(DashboardRole role, AppModuleFunction function) {
    final access = getAccess(role, function);
    return access == AccessLevel.requiresConfirmation ||
        access == AccessLevel.restrictedOrConfirmation;
  }

  /// Security execution guard that checks permissions and requests confirmation when required.
  static Future<bool> executeWithGuard({
    required BuildContext context,
    required DashboardRole role,
    required AppModuleFunction function,
    required String actionDescription,
    required Future<void> Function() onAuthorized,
  }) async {
    final access = getAccess(role, function);

    if (access == AccessLevel.restricted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.lock, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Access Denied: ${role.label} is restricted from performing "${function.title}".',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
      return false;
    }

    if (access.needsConfirmation) {
      final isSuperAdminMarkOverride =
          function == AppModuleFunction.enterMarks && role == DashboardRole.superAdmin;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.navyDeep,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              Icon(
                isSuperAdminMarkOverride ? Icons.warning_rounded : Icons.help_outline_rounded,
                color: isSuperAdminMarkOverride ? const Color(0xFFF97316) : AppColors.gold,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isSuperAdminMarkOverride
                      ? 'Override Confirmation'
                      : 'Security Confirmation',
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(access.symbol, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${function.title} (${access.label})',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Action: $actionDescription',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                isSuperAdminMarkOverride
                    ? 'Super Admin mark alteration is normally restricted (🔒/🟡) and requires formal audit justification before bypassing academic grading controls.'
                    : 'This operation carries elevated privileges or requires administrative verification. Do you confirm you wish to proceed?',
                style: const TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuperAdminMarkOverride ? const Color(0xFFF97316) : AppColors.gold,
                foregroundColor: AppColors.navyDeep,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Authorize & Proceed', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirmed != true) return false;
    }

    await onAuthorized();
    return true;
  }
}

/// Interactive Role-Permission Matrix viewer page.
class RolePermissionMatrixPage extends StatefulWidget {
  final DashboardRole initialRole;

  const RolePermissionMatrixPage({super.key, this.initialRole = DashboardRole.superAdmin});

  @override
  State<RolePermissionMatrixPage> createState() => _RolePermissionMatrixPageState();
}

class _RolePermissionMatrixPageState extends State<RolePermissionMatrixPage> {
  String _searchQuery = '';
  DashboardRole? _selectedRoleFilter;

  final List<DashboardRole> _matrixRoles = const [
    DashboardRole.superAdmin,
    DashboardRole.admin,
    DashboardRole.teacher,
    DashboardRole.student,
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFunctions = AppModuleFunction.values.where((func) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return func.title.toLowerCase().contains(q) ||
          func.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.gold, size: 22),
            SizedBox(width: 10),
            Text(
              'Role-Permission Matrix',
              style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Institutional RBAC Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user, color: AppColors.gold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'LIAH ACADEMY RBAC SECURITY BASELINE',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Formal role-permission authorization matrix controlling administrative, pedagogical, financial, and student operations.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildLegendBadge(AccessLevel.granted),
                    _buildLegendBadge(AccessLevel.restricted),
                    _buildLegendBadge(AccessLevel.requiresConfirmation),
                    _buildLegendBadge(AccessLevel.restrictedOrConfirmation),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search & Filter Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.muted, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5),
                          decoration: const InputDecoration(
                            hintText: 'Search function or module...',
                            hintStyle: TextStyle(color: AppColors.muted, fontSize: 12),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DashboardRole?>(
                    value: _selectedRoleFilter,
                    dropdownColor: AppColors.navyDeep,
                    style: const TextStyle(color: AppColors.onNavy, fontSize: 12),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Roles (4)')),
                      ..._matrixRoles.map(
                        (r) => DropdownMenuItem(value: r, child: Text(r.label)),
                      ),
                    ],
                    onChanged: (role) => setState(() => _selectedRoleFilter = role),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Matrix Data Table
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF0F1A3D)),
                dataRowMinHeight: 52,
                dataRowMaxHeight: 64,
                columnSpacing: 22,
                columns: [
                  const DataColumn(
                    label: Text(
                      'Module / Function',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.superAdmin)
                    const DataColumn(
                      label: Center(
                        child: Text(
                          'Super Admin',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.admin)
                    const DataColumn(
                      label: Center(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.teacher)
                    const DataColumn(
                      label: Center(
                        child: Text(
                          'Lecturer',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.student)
                    const DataColumn(
                      label: Center(
                        child: Text(
                          'Student',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
                rows: filteredFunctions.map((func) {
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () => _showFunctionDetail(context, func),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  func.title,
                                  style: const TextStyle(
                                    color: AppColors.onNavy,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  func.description,
                                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.superAdmin)
                        DataCell(_buildCellBadge(func, DashboardRole.superAdmin)),
                      if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.admin)
                        DataCell(_buildCellBadge(func, DashboardRole.admin)),
                      if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.teacher)
                        DataCell(_buildCellBadge(func, DashboardRole.teacher)),
                      if (_selectedRoleFilter == null || _selectedRoleFilter == DashboardRole.student)
                        DataCell(_buildCellBadge(func, DashboardRole.student)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegendBadge(AccessLevel level) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(level.symbol, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(
          level.label,
          style: TextStyle(
            color: level.color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCellBadge(AppModuleFunction func, DashboardRole role) {
    final access = RolePermissionMatrix.getAccess(role, func);

    return InkWell(
      onTap: () => _showCellAudit(context, func, role, access),
      borderRadius: BorderRadius.circular(6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: access.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: access.color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(access.symbol, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                access.name.toUpperCase(),
                style: TextStyle(
                  color: access.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFunctionDetail(BuildContext context, AppModuleFunction func) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_person, color: AppColors.gold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    func.title,
                    style: const TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              func.description,
              style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'AUTHORIZED ROLES BREAKDOWN',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            ..._matrixRoles.map((role) {
              final access = RolePermissionMatrix.getAccess(role, func);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      role.label,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(access.symbol, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          access.label,
                          style: TextStyle(
                            color: access.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCellAudit(
    BuildContext context,
    AppModuleFunction func,
    DashboardRole role,
    AccessLevel access,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Icon(access.icon, color: access.color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${role.label} • ${func.title}',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: access.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: access.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(access.symbol, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          access.label.toUpperCase(),
                          style: TextStyle(color: access.color, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          access == AccessLevel.granted
                              ? 'Access granted by default policy'
                              : access == AccessLevel.restricted
                                  ? 'Access denied by institutional policy'
                                  : 'Requires explicit administrative confirmation',
                          style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              func.description,
              style: const TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}
