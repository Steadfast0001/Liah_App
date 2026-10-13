import '../entities/student_entities.dart';

abstract class StudentRepository {
  Future<List<StudentRecord>> fetchStudents({String? searchQuery});

  Future<List<ProgramOption>> fetchPrograms();

  Future<List<CohortOption>> fetchCohorts({String? programId});

  Future<CreatedStudentResult> createStudent({
    required String email,
    required String fullName,
    required String programId,
    String? cohortId,
    String? phone,
    String? password,
  });
}
