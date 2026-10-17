import 'package:equatable/equatable.dart';

class FeeConfiguration extends Equatable {
  const FeeConfiguration({
    required this.id,
    required this.academicYear,
    required this.programName,
    required this.annualTuitionXaf,
    required this.registrationFeeXaf,
    required this.latePenaltyPercentage,
    required this.minCreditUnits,
    required this.maxCreditUnits,
    required this.updatedAt,
  });

  final String id;
  final String academicYear;
  final String programName;
  final int annualTuitionXaf;
  final int registrationFeeXaf;
  final double latePenaltyPercentage;
  final int minCreditUnits;
  final int maxCreditUnits;
  final DateTime updatedAt;

  factory FeeConfiguration.initial() {
    return FeeConfiguration(
      id: 'default-config',
      academicYear: '2026/2027',
      programName: 'Undergraduate Degree',
      annualTuitionXaf: 700000,
      registrationFeeXaf: 25000,
      latePenaltyPercentage: 5.0,
      minCreditUnits: 15,
      maxCreditUnits: 24,
      updatedAt: DateTime.now(),
    );
  }

  FeeConfiguration copyWith({
    String? academicYear,
    String? programName,
    int? annualTuitionXaf,
    int? registrationFeeXaf,
    double? latePenaltyPercentage,
    int? minCreditUnits,
    int? maxCreditUnits,
    DateTime? updatedAt,
  }) {
    return FeeConfiguration(
      id: id,
      academicYear: academicYear ?? this.academicYear,
      programName: programName ?? this.programName,
      annualTuitionXaf: annualTuitionXaf ?? this.annualTuitionXaf,
      registrationFeeXaf: registrationFeeXaf ?? this.registrationFeeXaf,
      latePenaltyPercentage: latePenaltyPercentage ?? this.latePenaltyPercentage,
      minCreditUnits: minCreditUnits ?? this.minCreditUnits,
      maxCreditUnits: maxCreditUnits ?? this.maxCreditUnits,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        academicYear,
        programName,
        annualTuitionXaf,
        registrationFeeXaf,
        latePenaltyPercentage,
        minCreditUnits,
        maxCreditUnits,
        updatedAt,
      ];
}
