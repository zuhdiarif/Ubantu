import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/smart_schedule_model.dart';
import 'package:ubantu/data/models/student_schedule_model.dart';

class SupabaseScheduleService {
  final SupabaseClient? _client;

  bool get isAvailable => _client != null || SupabaseService.instance.isInitialized;

  SupabaseScheduleService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<SmartScheduleModel>>> getSchedules(String userId) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final response = await _effectiveClient
          .from('schedules')
          .select()
          .eq('user_id', userId)
          .order('scheduled_time', ascending: true);

      final items = (response as List<dynamic>)
          .map((json) => SmartScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return AppResult.success(items);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<SmartScheduleModel>> bookSchedule(SmartScheduleModel schedule) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final data = schedule.toJson()..remove('id');
      final response = await _effectiveClient
          .from('schedules')
          .insert(data)
          .select()
          .single();

      return AppResult.success(SmartScheduleModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<List<StudentScheduleModel>>> getStudentSchedules(String userId) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final response = await _effectiveClient
          .from('student_schedules')
          .select()
          .eq('user_id', userId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      final items = (response as List<dynamic>)
          .map((json) => StudentScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return AppResult.success(items);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<StudentScheduleModel>> addStudentSchedule(StudentScheduleModel schedule) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final data = schedule.toJson();
      if (data['id'] == '' || data['id'] == null) {
        data.remove('id');
      }
      final response = await _effectiveClient
          .from('student_schedules')
          .insert(data)
          .select()
          .single();

      return AppResult.success(StudentScheduleModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> deleteStudentSchedule(String scheduleId) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      await _effectiveClient
          .from('student_schedules')
          .delete()
          .eq('id', scheduleId);

      return AppResult.success(true);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
