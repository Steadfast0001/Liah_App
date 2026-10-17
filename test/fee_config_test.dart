import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/features/administration/domain/entities/fee_config.dart';

void main() {
  group('FeeConfiguration Tests', () {
    test('Default bounds adhere to the academic credit rules (15-24 CU)', () {
      final config = FeeConfiguration.initial();

      expect(config.minCreditUnits, 15);
      expect(config.maxCreditUnits, 24);
      expect(config.annualTuitionXaf, 700000);
      expect(config.registrationFeeXaf, 25000);
      expect(config.latePenaltyPercentage, 5.0);
    });

    test('Custom configuration overrides correctly via copyWith', () {
      final initial = FeeConfiguration.initial();
      final updated = initial.copyWith(
        academicYear: '2026/2027',
        annualTuitionXaf: 850000,
        registrationFeeXaf: 30000,
        latePenaltyPercentage: 10.0,
        minCreditUnits: 16,
        maxCreditUnits: 22,
      );

      expect(updated.academicYear, '2026/2027');
      expect(updated.minCreditUnits, 16);
      expect(updated.maxCreditUnits, 22);
      expect(updated.annualTuitionXaf, 850000);
      expect(updated.registrationFeeXaf, 30000);
      expect(updated.latePenaltyPercentage, 10.0);
    });
  });
}
