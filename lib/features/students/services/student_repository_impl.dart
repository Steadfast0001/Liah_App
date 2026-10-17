import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/edge_functions.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/edge_function_client.dart';
import '../models/student_entities.dart';
import './student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._client, this._edgeClient);

  final SupabaseClient _client;
  final EdgeFunctionClient _edgeClient;

  @override
  Future<List<StudentRecord>> fetchStudents({String? searchQuery}) async {
    try {
      final rows = await _client
          .from('students')
          .select(
            'id, profile_id, matricule, program_id, cohort_id, status, admission_date, '
            'profiles!inner(full_name, email, phone), '
            'programs!inner(code, name), '
            'cohorts(label)',
          )
          .order('created_at', ascending: false);

      final list = <StudentRecord>[];
      for (final raw in (rows as List<dynamic>)) {
        if (raw is! Map<String, dynamic>) continue;
        final profile = (raw['profiles'] as Map<String, dynamic>?) ?? const {};
        final program = (raw['programs'] as Map<String, dynamic>?) ?? const {};
        final cohort = raw['cohorts'] as Map<String, dynamic>?;

        final record = StudentRecord(
          id: raw['id'] as String,
          profileId: raw['profile_id'] as String,
          matricule: (raw['matricule'] as String?) ?? '',
          fullName: (profile['full_name'] as String?) ?? '',
          email: (profile['email'] as String?) ?? '',
          phone: profile['phone'] as String?,
          programId: raw['program_id'] as String,
          programCode: (program['code'] as String?) ?? '',
          programName: (program['name'] as String?) ?? '',
          cohortId: raw['cohort_id'] as String?,
          cohortLabel: cohort?['label'] as String?,
          status: (raw['status'] as String?) ?? 'active',
          admissionDate: DateTime.tryParse(
                (raw['admission_date'] as String?) ?? '',
              ) ??
              DateTime.now(),
        );

        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final q = searchQuery.trim().toLowerCase();
          final matches = record.fullName.toLowerCase().contains(q) ||
              record.matricule.toLowerCase().contains(q) ||
              record.email.toLowerCase().contains(q) ||
              record.programCode.toLowerCase().contains(q);
          if (!matches) continue;
        }

        list.add(record);
      }

      return list;
    } on PostgrestException catch (e) {
      throw NetworkException(e.message);
    }
  }

  @override
  Future<List<ProgramOption>> fetchPrograms() async {
    try {
      final rows = await _client
          .from('programs')
          .select('id, code, name')
          .eq('is_active', true)
          .order('code');

      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(
            (r) => ProgramOption(
              id: r['id'] as String,
              code: (r['code'] as String?) ?? '',
              name: (r['name'] as String?) ?? '',
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw NetworkException(e.message);
    }
  }

  @override
  Future<List<CohortOption>> fetchCohorts({String? programId}) async {
    try {
      var query = _client
          .from('cohorts')
          .select('id, program_id, intake_year, label');
      if (programId != null && programId.isNotEmpty) {
        query = query.eq('program_id', programId);
      }
      final rows = await query.order('intake_year', ascending: false);

      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(
            (r) => CohortOption(
              id: r['id'] as String,
              programId: r['program_id'] as String,
              intakeYear: (r['intake_year'] as int?) ?? DateTime.now().year,
              label: (r['label'] as String?) ?? '',
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw NetworkException(e.message);
    }
  }

  @override
  Future<CreatedStudentResult> createStudent({
    required String email,
    required String fullName,
    required String programId,
    String? cohortId,
    String? phone,
    String? password,
  }) async {
    final data = await _edgeClient.invoke(
      EdgeFunctions.adminCreateStudent,
      body: {
        'email': email.trim(),
        'full_name': fullName.trim(),
        'program_id': programId,
        if (cohortId != null && cohortId.isNotEmpty) 'cohort_id': cohortId,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (password != null && password.trim().isNotEmpty)
          'password': password.trim(),
      },
    );

    return CreatedStudentResult(
      studentId: (data['student_id'] as String?) ?? '',
      matricule: (data['matricule'] as String?) ?? '',
      profileId: (data['profile_id'] as String?) ?? '',
      temporaryPassword: data['temporary_password'] as String?,
    );
  }
}
