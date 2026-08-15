import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';

class SupabaseScheduleService {
  final SupabaseClient? _client;

  SupabaseScheduleService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<SmartScheduleModel>>> getSchedules(String userId) async {
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
}
