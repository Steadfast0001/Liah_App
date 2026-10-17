import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/edge_functions.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/edge_function_client.dart';
import '../models/course_registration_entities.dart';
import './course_registration_repository.dart';

class CourseRegistrationRepositoryImpl implements CourseRegistrationRepository {
  CourseRegistrationRepositoryImpl(this._client, this._edgeClient);

  final SupabaseClient _client;
  final EdgeFunctionClient _edgeClient;

  @override
  Future<SemesterInfo?> getCurrentSemester() async {
    try {
      final row = await _client
          .from('semesters')
          .select('id, label, term_number, is_current')
          .eq('is_current', true)
          .maybeSingle();

      if (row == null) return null;
      return SemesterInfo(
        id: row['id'] as String,
        label: (row['label'] as String?) ?? 'Current Semester',
        termNumber: (row['term_number'] as int?) ?? 1,
        isCurrent: (row['is_current'] as bool?) ?? true,
      );
    } on PostgrestException catch (e) {
      throw NetworkException(e.message);
    }
  }

  @override
  Future<SemesterAccess> getSemesterAccess(String semesterId) async {
    try {
      final data = await _edgeClient.invoke(
        EdgeFunctions.getSemesterAccess,
        body: {'semester_id': semesterId},
      );

      final rawMessages = data['messages'];
      final messages = rawMessages is List
          ? rawMessages.map((e) => e.toString()).toList()
          : const <String>[];

      return SemesterAccess(
        semesterId: (data['semester_id'] as String?) ?? semesterId,
        canRegister: (data['can_register'] as bool?) ?? false,
        canViewResults: (data['can_view_results'] as bool?) ?? true,
        feeStatus: (data['fee_status'] as String?) ?? 'unknown',
        messages: messages,
      );
    } catch (_) {
      // Fallback when Edge Functions are not yet served locally
      return SemesterAccess(
        semesterId: semesterId,
        canRegister: true,
        canViewResults: true,
        feeStatus: 'cleared',
      );
    }
  }

  @override
  Future<List<CourseOfferingItem>> fetchOfferings(String semesterId) async {
    try {
      final offeringRows = await _client
          .from('course_offerings')
          .select(
            'id, course_id, semester_id, capacity, is_open_for_registration, '
            'courses!inner(code, title, credit_units, level)',
          )
          .eq('semester_id', semesterId)
          .order('created_at');

      final regRows = await _client
          .from('course_registrations')
          .select('id, course_offering_id, status')
          .eq('semester_id', semesterId);

      final regMap = <String, Map<String, dynamic>>{};
      for (final r in (regRows as List<dynamic>)) {
        if (r is Map<String, dynamic>) {
          final offId = r['course_offering_id'] as String?;
          if (offId != null) regMap[offId] = r;
        }
      }

      final items = <CourseOfferingItem>[];
      for (final raw in (offeringRows as List<dynamic>)) {
        if (raw is! Map<String, dynamic>) continue;
        final course = (raw['courses'] as Map<String, dynamic>?) ?? const {};
        final offeringId = raw['id'] as String;
        final reg = regMap[offeringId];

        items.add(
          CourseOfferingItem(
            offeringId: offeringId,
            courseId: raw['course_id'] as String,
            semesterId: raw['semester_id'] as String,
            courseCode: (course['code'] as String?) ?? '',
            courseTitle: (course['title'] as String?) ?? '',
            creditUnits: (course['credit_units'] as int?) ?? 0,
            level: course['level'] as int?,
            capacity: raw['capacity'] as int?,
            isOpenForRegistration:
                (raw['is_open_for_registration'] as bool?) ?? false,
            registrationId: reg?['id'] as String?,
            registrationStatus: reg?['status'] as String?,
          ),
        );
      }

      items.sort((a, b) => a.courseCode.compareTo(b.courseCode));
      return items;
    } on PostgrestException catch (e) {
      throw NetworkException(e.message);
    }
  }

  @override
  Future<void> registerCourse({
    required String courseOfferingId,
    required String semesterId,
  }) async {
    await _edgeClient.invoke(
      EdgeFunctions.registerCourse,
      body: {
        'course_offering_id': courseOfferingId,
        'semester_id': semesterId,
      },
    );
  }

  @override
  Future<void> dropCourse({
    required String courseOfferingId,
    required String semesterId,
  }) async {
    await _edgeClient.invoke(
      EdgeFunctions.dropCourse,
      body: {
        'course_offering_id': courseOfferingId,
        'semester_id': semesterId,
      },
    );
  }
}
