import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/core/permissions/app_permissions.dart';
import 'package:liah_app/features/auth/models/user_profile.dart';

void main() {
  group('Fah Academy RBAC — RolePermissions Action Matrix Tests (Table 7)', () {
    test('Create Admin account: Super Admin allowed, others denied', () {
      expect(RolePermissions.canCreateAdmin(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canCreateAdmin(AppRole.admin), isFalse);
      expect(RolePermissions.canCreateAdmin(AppRole.lecturer), isFalse);
      expect(RolePermissions.canCreateAdmin(AppRole.student), isFalse);
    });

    test('Create Student account: Super Admin and Admin allowed, others denied', () {
      expect(RolePermissions.canCreateStudent(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canCreateStudent(AppRole.admin), isTrue);
      expect(RolePermissions.canCreateStudent(AppRole.lecturer), isFalse);
      expect(RolePermissions.canCreateStudent(AppRole.student), isFalse);
    });

    test('Change fee structures: Super Admin allowed, Admin and others denied', () {
      expect(RolePermissions.canChangeFeeStructures(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canChangeFeeStructures(AppRole.admin), isFalse);
      expect(RolePermissions.canChangeFeeStructures(AppRole.lecturer), isFalse);
      expect(RolePermissions.canChangeFeeStructures(AppRole.student), isFalse);
    });

    test('Publish Final Results: Super Admin strictly allowed, Admin denied by default', () {
      expect(RolePermissions.canPublishFinalResults(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canPublishFinalResults(AppRole.admin), isFalse);
      expect(RolePermissions.canPublishFinalResults(AppRole.lecturer), isFalse);
      expect(RolePermissions.canPublishFinalResults(AppRole.student), isFalse);
    });

    test('Approve Grade Submission: Admin allowed, Lecturer cannot approve own submission', () {
      expect(RolePermissions.canApproveGradeSubmission(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canApproveGradeSubmission(AppRole.admin), isTrue);
      expect(
        RolePermissions.canApproveGradeSubmission(AppRole.lecturer, isOwnSubmission: true),
        isFalse,
      );
      expect(
        RolePermissions.canApproveGradeSubmission(AppRole.admin, isOwnSubmission: true),
        isFalse,
      );
    });

    test('Verify payments: Super Admin and Admin allowed, others denied', () {
      expect(RolePermissions.canVerifyPayment(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canVerifyPayment(AppRole.admin), isTrue);
      expect(RolePermissions.canVerifyPayment(AppRole.lecturer), isFalse);
      expect(RolePermissions.canVerifyPayment(AppRole.student), isFalse);
    });

    test('Audit logs full oversight: Super Admin allowed, others denied', () {
      expect(RolePermissions.canReadAuditLogs(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canReadAuditLogs(AppRole.admin), isFalse);
      expect(RolePermissions.canReadAuditLogs(AppRole.lecturer), isFalse);
      expect(RolePermissions.canReadAuditLogs(AppRole.student), isFalse);
    });

    test('Workflow overrides: Super Admin allowed, others denied', () {
      expect(RolePermissions.canOverrideWorkflow(AppRole.superAdmin), isTrue);
      expect(RolePermissions.canOverrideWorkflow(AppRole.admin), isFalse);
      expect(RolePermissions.canOverrideWorkflow(AppRole.lecturer), isFalse);
      expect(RolePermissions.canOverrideWorkflow(AppRole.student), isFalse);
    });

    test('Password reset matrix: Admin cannot reset Admin or SuperAdmin', () {
      expect(
        RolePermissions.canResetPassword(
          actorRole: AppRole.admin,
          targetRole: AppRole.student,
        ),
        isTrue,
      );
      expect(
        RolePermissions.canResetPassword(
          actorRole: AppRole.admin,
          targetRole: AppRole.lecturer,
        ),
        isTrue,
      );
      expect(
        RolePermissions.canResetPassword(
          actorRole: AppRole.admin,
          targetRole: AppRole.admin,
        ),
        isFalse,
      );
      expect(
        RolePermissions.canResetPassword(
          actorRole: AppRole.admin,
          targetRole: AppRole.superAdmin,
        ),
        isFalse,
      );
    });
  });
}
