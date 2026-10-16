import 'package:equatable/equatable.dart';

class SemesterInfo extends Equatable {
  const SemesterInfo({
    required this.id,
    required this.label,
    required this.termNumber,
    required this.isCurrent,
  });

  final String id;
  final String label;
  final int termNumber;
  final bool isCurrent;

  @override
  List<Object?> get props => [id, label, termNumber, isCurrent];
}

class SemesterAccess extends Equatable {
  const SemesterAccess({
    required this.semesterId,
    required this.canRegister,
    required this.canViewResults,
    required this.feeStatus,
    this.messages = const [],
  });

  final String semesterId;
  final bool canRegister;
  final bool canViewResults;
  final String feeStatus;
  final List<String> messages;

  @override
  List<Object?> get props => [
        semesterId,
        canRegister,
        canViewResults,
        feeStatus,
        messages,
      ];
}

class CourseOfferingItem extends Equatable {
  const CourseOfferingItem({
    required this.offeringId,
    required this.courseId,
    required this.semesterId,
    required this.courseCode,
    required this.courseTitle,
    required this.creditUnits,
    this.level,
    this.capacity,
    required this.isOpenForRegistration,
    this.registrationId,
    this.registrationStatus,
  });

  final String offeringId;
  final String courseId;
  final String semesterId;
  final String courseCode;
  final String courseTitle;
  final int creditUnits;
  final int? level;
  final int? capacity;
  final bool isOpenForRegistration;
  final String? registrationId;
  final String? registrationStatus;

  bool get isRegistered => registrationStatus == 'registered';

  @override
  List<Object?> get props => [
        offeringId,
        courseId,
        semesterId,
        courseCode,
        courseTitle,
        creditUnits,
        level,
        capacity,
        isOpenForRegistration,
        registrationId,
        registrationStatus,
      ];
}
