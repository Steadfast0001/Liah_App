import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/dashboard_data.dart';
import 'package:liah_app/role_permission_matrix.dart';

void main() {
  group('Liah Academy — Role-Permission Matrix Specification Tests', () {
    test('Matrix contains all 24 standard functions', () {
      expect(AppModuleFunction.values.length, 24);
      for (final func in AppModuleFunction.values) {
        expect(RolePermissionMatrix.matrix.containsKey(func), isTrue,
            reason: 'Missing matrix entry for ${func.title}');
      }
    });

    test('All 24 functions match the official specification for Super Admin', () {
      final expected = <AppModuleFunction, AccessLevel>{
        AppModuleFunction.login: AccessLevel.granted,
        AppModuleFunction.selfRegistration: AccessLevel.requiresConfirmation,
        AppModuleFunction.userManagement: AccessLevel.granted,
        AppModuleFunction.roleManagement: AccessLevel.granted,
        AppModuleFunction.systemConfiguration: AccessLevel.granted,
        AppModuleFunction.studentManagement: AccessLevel.granted,
        AppModuleFunction.lecturerManagement: AccessLevel.granted,
        AppModuleFunction.academicManagement: AccessLevel.granted,
        AppModuleFunction.enrollment: AccessLevel.granted,
        AppModuleFunction.courseManagement: AccessLevel.granted,
        AppModuleFunction.examinationSetup: AccessLevel.granted,
        AppModuleFunction.enterMarks: AccessLevel.restrictedOrConfirmation,
        AppModuleFunction.viewResults: AccessLevel.granted,
        AppModuleFunction.timetableManagement: AccessLevel.granted,
        AppModuleFunction.viewTimetable: AccessLevel.granted,
        AppModuleFunction.feeConfiguration: AccessLevel.granted,
        AppModuleFunction.recordManualPayment: AccessLevel.granted,
        AppModuleFunction.onlinePayment: AccessLevel.requiresConfirmation,
        AppModuleFunction.viewOwnFinancialRecords: AccessLevel.granted,
        AppModuleFunction.announcements: AccessLevel.granted,
        AppModuleFunction.viewAnnouncements: AccessLevel.granted,
        AppModuleFunction.reports: AccessLevel.granted,
        AppModuleFunction.documentManagement: AccessLevel.granted,
        AppModuleFunction.auditLogs: AccessLevel.granted,
      };

      for (final entry in expected.entries) {
        final access = RolePermissionMatrix.getAccess(DashboardRole.superAdmin, entry.key);
        expect(access, entry.value,
            reason: 'Mismatch for Super Admin on ${entry.key.title}');
      }
    });

    test('All 24 functions match the official specification for Admin', () {
      final expected = <AppModuleFunction, AccessLevel>{
        AppModuleFunction.login: AccessLevel.granted,
        AppModuleFunction.selfRegistration: AccessLevel.restricted,
        AppModuleFunction.userManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.roleManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.systemConfiguration: AccessLevel.requiresConfirmation,
        AppModuleFunction.studentManagement: AccessLevel.granted,
        AppModuleFunction.lecturerManagement: AccessLevel.granted,
        AppModuleFunction.academicManagement: AccessLevel.granted,
        AppModuleFunction.enrollment: AccessLevel.granted,
        AppModuleFunction.courseManagement: AccessLevel.granted,
        AppModuleFunction.examinationSetup: AccessLevel.granted,
        AppModuleFunction.enterMarks: AccessLevel.requiresConfirmation,
        AppModuleFunction.viewResults: AccessLevel.granted,
        AppModuleFunction.timetableManagement: AccessLevel.granted,
        AppModuleFunction.viewTimetable: AccessLevel.granted,
        AppModuleFunction.feeConfiguration: AccessLevel.requiresConfirmation,
        AppModuleFunction.recordManualPayment: AccessLevel.requiresConfirmation,
        AppModuleFunction.onlinePayment: AccessLevel.requiresConfirmation,
        AppModuleFunction.viewOwnFinancialRecords: AccessLevel.granted,
        AppModuleFunction.announcements: AccessLevel.granted,
        AppModuleFunction.viewAnnouncements: AccessLevel.granted,
        AppModuleFunction.reports: AccessLevel.requiresConfirmation,
        AppModuleFunction.documentManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.auditLogs: AccessLevel.requiresConfirmation,
      };

      for (final entry in expected.entries) {
        final access = RolePermissionMatrix.getAccess(DashboardRole.admin, entry.key);
        expect(access, entry.value,
            reason: 'Mismatch for Admin on ${entry.key.title}');
      }
    });

    test('All 24 functions match the official specification for Lecturer', () {
      final expected = <AppModuleFunction, AccessLevel>{
        AppModuleFunction.login: AccessLevel.granted,
        AppModuleFunction.selfRegistration: AccessLevel.restricted,
        AppModuleFunction.userManagement: AccessLevel.restricted,
        AppModuleFunction.roleManagement: AccessLevel.restricted,
        AppModuleFunction.systemConfiguration: AccessLevel.restricted,
        AppModuleFunction.studentManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.lecturerManagement: AccessLevel.restricted,
        AppModuleFunction.academicManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.enrollment: AccessLevel.requiresConfirmation,
        AppModuleFunction.courseManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.examinationSetup: AccessLevel.requiresConfirmation,
        AppModuleFunction.enterMarks: AccessLevel.requiresConfirmation,
        AppModuleFunction.viewResults: AccessLevel.requiresConfirmation,
        AppModuleFunction.timetableManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.viewTimetable: AccessLevel.granted,
        AppModuleFunction.feeConfiguration: AccessLevel.restricted,
        AppModuleFunction.recordManualPayment: AccessLevel.restricted,
        AppModuleFunction.onlinePayment: AccessLevel.restricted,
        AppModuleFunction.viewOwnFinancialRecords: AccessLevel.restricted,
        AppModuleFunction.announcements: AccessLevel.requiresConfirmation,
        AppModuleFunction.viewAnnouncements: AccessLevel.granted,
        AppModuleFunction.reports: AccessLevel.requiresConfirmation,
        AppModuleFunction.documentManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.auditLogs: AccessLevel.restricted,
      };

      for (final entry in expected.entries) {
        final access = RolePermissionMatrix.getAccess(DashboardRole.teacher, entry.key);
        expect(access, entry.value,
            reason: 'Mismatch for Lecturer on ${entry.key.title}');
      }
    });

    test('All 24 functions match the official specification for Student', () {
      final expected = <AppModuleFunction, AccessLevel>{
        AppModuleFunction.login: AccessLevel.granted,
        AppModuleFunction.selfRegistration: AccessLevel.granted,
        AppModuleFunction.userManagement: AccessLevel.restricted,
        AppModuleFunction.roleManagement: AccessLevel.restricted,
        AppModuleFunction.systemConfiguration: AccessLevel.restricted,
        AppModuleFunction.studentManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.lecturerManagement: AccessLevel.restricted,
        AppModuleFunction.academicManagement: AccessLevel.restricted,
        AppModuleFunction.enrollment: AccessLevel.requiresConfirmation,
        AppModuleFunction.courseManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.examinationSetup: AccessLevel.restricted,
        AppModuleFunction.enterMarks: AccessLevel.restricted,
        AppModuleFunction.viewResults: AccessLevel.granted,
        AppModuleFunction.timetableManagement: AccessLevel.restricted,
        AppModuleFunction.viewTimetable: AccessLevel.granted,
        AppModuleFunction.feeConfiguration: AccessLevel.restricted,
        AppModuleFunction.recordManualPayment: AccessLevel.restricted,
        AppModuleFunction.onlinePayment: AccessLevel.granted,
        AppModuleFunction.viewOwnFinancialRecords: AccessLevel.granted,
        AppModuleFunction.announcements: AccessLevel.restricted,
        AppModuleFunction.viewAnnouncements: AccessLevel.granted,
        AppModuleFunction.reports: AccessLevel.requiresConfirmation,
        AppModuleFunction.documentManagement: AccessLevel.requiresConfirmation,
        AppModuleFunction.auditLogs: AccessLevel.restricted,
      };

      for (final entry in expected.entries) {
        final access = RolePermissionMatrix.getAccess(DashboardRole.student, entry.key);
        expect(access, entry.value,
            reason: 'Mismatch for Student on ${entry.key.title}');
      }
    });

    test('Helper access methods calculate correctly', () {
      // Student viewing timetable is directly granted
      expect(RolePermissionMatrix.isGranted(DashboardRole.student, AppModuleFunction.viewTimetable), isTrue);
      expect(RolePermissionMatrix.isRestricted(DashboardRole.student, AppModuleFunction.viewTimetable), isFalse);
      expect(RolePermissionMatrix.requiresConfirmation(DashboardRole.student, AppModuleFunction.viewTimetable), isFalse);

      // Student entering marks is restricted
      expect(RolePermissionMatrix.isRestricted(DashboardRole.student, AppModuleFunction.enterMarks), isTrue);
      expect(RolePermissionMatrix.isGranted(DashboardRole.student, AppModuleFunction.enterMarks), isFalse);

      // Lecturer entering marks requires confirmation
      expect(RolePermissionMatrix.requiresConfirmation(DashboardRole.teacher, AppModuleFunction.enterMarks), isTrue);
      expect(RolePermissionMatrix.isGranted(DashboardRole.teacher, AppModuleFunction.enterMarks), isFalse);
    });

    testWidgets('executeWithGuard directly runs granted operations', (tester) async {
      bool actionRan = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  RolePermissionMatrix.executeWithGuard(
                    context: ctx,
                    role: DashboardRole.student,
                    function: AppModuleFunction.viewTimetable,
                    actionDescription: 'View lecture timetable',
                    onAuthorized: () async {
                      actionRan = true;
                    },
                  );
                },
                child: const Text('Execute Action'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Execute Action'));
      await tester.pumpAndSettle();

      expect(actionRan, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('executeWithGuard blocks restricted operations with error snackbar', (tester) async {
      bool actionRan = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  RolePermissionMatrix.executeWithGuard(
                    context: ctx,
                    role: DashboardRole.student,
                    function: AppModuleFunction.enterMarks,
                    actionDescription: 'Alter exam marks',
                    onAuthorized: () async {
                      actionRan = true;
                    },
                  );
                },
                child: const Text('Execute Action'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Execute Action'));
      await tester.pumpAndSettle();

      expect(actionRan, isFalse);
      expect(find.textContaining('Access Denied'), findsOneWidget);
    });

    testWidgets('executeWithGuard shows confirmation dialog for elevated operations', (tester) async {
      bool actionRan = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  RolePermissionMatrix.executeWithGuard(
                    context: ctx,
                    role: DashboardRole.teacher,
                    function: AppModuleFunction.enterMarks,
                    actionDescription: 'Submit continuous assessment marks',
                    onAuthorized: () async {
                      actionRan = true;
                    },
                  );
                },
                child: const Text('Execute Action'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Execute Action'));
      await tester.pumpAndSettle();

      // Dialog should be displayed
      expect(find.text('Security Confirmation'), findsOneWidget);
      expect(find.textContaining('Submit continuous assessment marks'), findsOneWidget);
      expect(actionRan, isFalse);

      // Confirm button
      await tester.tap(find.text('Authorize & Proceed'));
      await tester.pumpAndSettle();

      expect(actionRan, isTrue);
    });

    testWidgets('RolePermissionMatrixPage renders table, legend and search', (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: RolePermissionMatrixPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Role-Permission Matrix'), findsOneWidget);
      expect(find.text('LIAH ACADEMY RBAC SECURITY BASELINE'), findsOneWidget);
      expect(find.text('Expected Access'), findsOneWidget);
      expect(find.text('Restricted'), findsOneWidget);
      expect(find.text('Requires Confirmation'), findsOneWidget);
      expect(find.text('Module / Function'), findsOneWidget);

      // Search functionality
      await tester.enterText(find.byType(TextField), 'Audit logs');
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(DataTable), matching: find.text('Audit logs')),
        findsOneWidget,
      );
    });
  });
}
