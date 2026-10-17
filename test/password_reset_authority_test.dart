import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/features/administration/domain/entities/password_reset_authority.dart';
import 'package:liah_app/features/auth/domain/entities/user_profile.dart';

void main() {
  group('PasswordResetAuthority Unit Tests', () {
    test('SuperAdmin has authority to reset Admin, Lecturer, and Student', () {
      expect(
        PasswordResetAuthority.canReset(
          actorRole: AppRole.superAdmin,
          targetRole: AppRole.admin,
        ),
        isTrue,
      );
      expect(
        PasswordResetAuthority.canReset(
          actorRole: AppRole.superAdmin,
          targetRole: AppRole.lecturer,
        ),
        isTrue,
      );
      expect(
        PasswordResetAuthority.canReset(
          actorRole: AppRole.superAdmin,
          targetRole: AppRole.student,
        ),
        isTrue,
      );
    });

    test('Admin CAN reset Lecturer and Student', () {
      expect(
        PasswordResetAuthority.canReset(
          actorRole: AppRole.admin,
          targetRole: AppRole.lecturer,
        ),
        isTrue,
      );
      expect(
        PasswordResetAuthority.canReset(
          actorRole: AppRole.admin,
          targetRole: AppRole.student,
        ),
        isTrue,
      );
    });

    test('Admin CANNOT reset SuperAdmin or fellow Admin accounts', () {
      expect(
        PasswordResetAuthority.canReset(
          actorRole: AppRole.admin,
          targetRole: AppRole.superAdmin,
        ),
        isFalse,
      );
      expect(
        PasswordResetAuthority.canReset(
          actorRole: AppRole.admin,
          targetRole: AppRole.admin,
        ),
        isFalse,
      );
    });

    test('Lecturer and Student CANNOT reset any accounts', () {
      for (final target in AppRole.values) {
        expect(
          PasswordResetAuthority.canReset(
            actorRole: AppRole.student,
            targetRole: target,
          ),
          isFalse,
        );
        expect(
          PasswordResetAuthority.canReset(
            actorRole: AppRole.lecturer,
            targetRole: target,
          ),
          isFalse,
        );
      }
    });
  });
}
