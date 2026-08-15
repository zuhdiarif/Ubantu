import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';

class SupabaseSosService {
  final SupabaseClient? _client;

  SupabaseSosService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<SosReportModel>> submitSosReport(String issueType) async {
    try {
      final user = _effectiveClient.auth.currentUser;
      final payload = {
        'reporter_id': user?.id,
        'issue_type': issueType,
        'status': SosStatus.received.name,
      };

      final response = await _effectiveClient
          .from('sos_reports')
          .insert(payload)
          .select()
          .single();

      return AppResult.success(SosReportModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> updateSosStatus(String reportId, SosStatus status) async {
    try {
      await _effectiveClient
          .from('sos_reports')
          .update({'status': status.name})
          .eq('id', reportId);

      return AppResult.success(true);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
