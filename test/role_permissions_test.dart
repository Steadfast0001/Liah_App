import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/dashboard_data.dart';

void main() {
  group('Liah Academy RBAC — Role Mapping & Dashboard Data Tests', () {
    test('DashboardRoleLabel maps strings to roles accurately', () {
      expect(DashboardRoleLabel.fromString('super_admin'), DashboardRole.superAdmin);
      expect(DashboardRoleLabel.fromString('superadmin'), DashboardRole.superAdmin);
      expect(DashboardRoleLabel.fromString('admin'), DashboardRole.admin);
      expect(DashboardRoleLabel.fromString('administrator'), DashboardRole.admin);
      expect(DashboardRoleLabel.fromString('lecturer'), DashboardRole.teacher);
      expect(DashboardRoleLabel.fromString('teacher'), DashboardRole.teacher);
      expect(DashboardRoleLabel.fromString('staff'), DashboardRole.teacher);
      expect(DashboardRoleLabel.fromString('student'), DashboardRole.student);
      expect(DashboardRoleLabel.fromString('parent'), DashboardRole.parent);
      expect(DashboardRoleLabel.fromString('unknown_role'), DashboardRole.student);
    });

    test('DashboardRoleLabel returns correct display label', () {
      expect(DashboardRole.superAdmin.label, 'Super Admin');
      expect(DashboardRole.admin.label, 'Administrator');
      expect(DashboardRole.teacher.label, 'Lecturer');
      expect(DashboardRole.student.label, 'Student');
      expect(DashboardRole.parent.label, 'Parent');
    });

    test('DemoDashboardRepository returns populated metrics for all roles', () async {
      for (final role in DashboardRole.values) {
        final repo = DemoDashboardRepository(role: role);
        final data = await repo.fetchDashboard(authToken: 'test_token');
        expect(data.role, role);
        expect(data.metrics, isNotEmpty);
      }
    });

    test('Student dashboard data contains finance and registration details', () async {
      const repo = DemoDashboardRepository(role: DashboardRole.student);
      final data = await repo.fetchDashboard(authToken: 'test_token');
      
      expect(data.studentFinance, isNotNull);
      expect(data.studentRegistration, isNotNull);
      expect(data.studentFinance!.totalFees, greaterThan(0));
      expect(data.studentRegistration!.documents, isNotEmpty);
    });
  });
}
