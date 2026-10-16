import '../entities/course_registration_entities.dart';

abstract class CourseRegistrationRepository {
  Future<SemesterInfo?> getCurrentSemester();

  Future<SemesterAccess> getSemesterAccess(String semesterId);

  Future<List<CourseOfferingItem>> fetchOfferings(String semesterId);

  Future<void> registerCourse({
    required String courseOfferingId,
    required String semesterId,
  });

  Future<void> dropCourse({
    required String courseOfferingId,
    required String semesterId,
  });
}
