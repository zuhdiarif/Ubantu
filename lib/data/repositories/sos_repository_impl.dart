import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_sos_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/domain/repositories/session_scoped.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';

class SosRepositoryImpl implements ISosRepository, SessionScoped {
  final SupabaseSosService _supabaseSosService;
  SosStatus _status = SosStatus.received;

  SosRepositoryImpl({
    SupabaseSosService? service,
    SupabaseSosService? remoteService,
  }) : _supabaseSosService = remoteService ?? service ?? SupabaseSosService();

  bool get hasRemoteService => true;
  SupabaseSosService get remoteService => _supabaseSosService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;

  @override
  Future<AppResult<SosReportModel>> submitSosReport(String issueType) async {
    if (isRemoteActive) {
      final result = await _supabaseSosService.submitSosReport(issueType);
      if (result.isSuccess) {
        return result;
      }
    }

    final currentUserId = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser?.id ?? 'usr_guest'
        : 'usr_guest';

    final report = SosReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUserId,
      issueType: issueType,
      status: _status,
      createdAt: DateTime.now(),
    );
    return AppResult.success(report);
  }

  @override
  Future<void> updateSosStatus(SosStatus status) async {
    _status = status;
  }

  @override
  void clearSessionCache() {
    _status = SosStatus.received;
  }
}
