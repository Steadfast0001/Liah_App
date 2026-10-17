import 'package:equatable/equatable.dart';

class StudentRecord extends Equatable {
  const StudentRecord({
    required this.id,
    required this.profileId,
    required this.matricule,
    required this.fullName,
    required this.email,
    this.phone,
    required this.programId,
    required this.programCode,
    required this.programName,
    this.cohortId,
    this.cohortLabel,
    required this.status,
    required this.admissionDate,
  });

  final String id;
  final String profileId;
  final String matricule;
  final String fullName;
  final String email;
  final String? phone;
  final String programId;
  final String programCode;
  final String programName;
  final String? cohortId;
  final String? cohortLabel;
  final String status;
  final DateTime admissionDate;

  @override
  List<Object?> get props => [
        id,
        profileId,
        matricule,
        fullName,
        email,
        phone,
        programId,
        programCode,
        programName,
        cohortId,
        cohortLabel,
        status,
        admissionDate,
      ];
}

class ProgramOption extends Equatable {
  const ProgramOption({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;

  @override
  List<Object?> get props => [id, code, name];
}

class CohortOption extends Equatable {
  const CohortOption({
    required this.id,
    required this.programId,
    required this.intakeYear,
    required this.label,
  });

  final String id;
  final String programId;
  final int intakeYear;
  final String label;

  @override
  List<Object?> get props => [id, programId, intakeYear, label];
}

class CreatedStudentResult extends Equatable {
  const CreatedStudentResult({
    required this.studentId,
    required this.matricule,
    required this.profileId,
    this.temporaryPassword,
  });

  final String studentId;
  final String matricule;
  final String profileId;
  final String? temporaryPassword;

  @override
  List<Object?> get props => [
        studentId,
        matricule,
        profileId,
        temporaryPassword,
      ];
}
