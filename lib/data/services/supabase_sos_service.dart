import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/sos_report_model.dart';

class SupabaseSosService {
  final SupabaseClient? _client;

  bool get isAvailable => _client != null || SupabaseService.instance.isInitialized;

  SupabaseSosService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<SosReportModel>> submitSosReport(dynamic reportOrIssueType, {String? userId}) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final user = _effectiveClient.auth.currentUser;
      final String issueType;
      final String? effectiveUserId;
      if (reportOrIssueType is SosReportModel) {
        issueType = reportOrIssueType.issueType;
        effectiveUserId = reportOrIssueType.userId.isNotEmpty ? reportOrIssueType.userId : user?.id;
      } else {
        issueType = reportOrIssueType.toString();
        effectiveUserId = userId ?? user?.id;
      }

      final payload = <String, dynamic>{
        if (effectiveUserId != null && effectiveUserId.isNotEmpty) ...{
          'user_id': effectiveUserId,
          'reporter_id': effectiveUserId,
        },
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
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
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
