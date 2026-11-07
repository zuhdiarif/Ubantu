import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_sos_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/sos_report_model.dart';
import 'package:ubantu/data/repositories/session_scoped.dart';
import 'package:ubantu/data/repositories/sos_repository.dart';

class SosRepositoryImpl implements ISosRepository, SessionScoped {
  final SupabaseSosService _supabaseSosService;
  SosStatus _status = SosStatus.received;
  String? _lastReportId;

  SosRepositoryImpl({
    SupabaseSosService? service,
    SupabaseSosService? remoteService,
  }) : _supabaseSosService = remoteService ?? service ?? SupabaseSosService();

  bool get hasRemoteService => true;
  SupabaseSosService get remoteService => _supabaseSosService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  String? get lastReportId => _lastReportId;

  @override
  Future<AppResult<SosReportModel>> submitSosReport(String issueType) async {
    if (isRemoteActive) {
      final remoteResult = await _supabaseSosService.submitSosReport(issueType);
      if (remoteResult.isSuccess && remoteResult.data != null) {
        _status = remoteResult.data!.status;
        _lastReportId = remoteResult.data!.id;
      }
      return remoteResult;
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
    _lastReportId = report.id;
    return AppResult.success(report);
  }

  @override
  Future<void> updateSosStatus(SosStatus status) async {
    _status = status;
    if (isRemoteActive && _lastReportId != null && _lastReportId!.isNotEmpty) {
      await _supabaseSosService.updateSosStatus(_lastReportId!, status);
    }
  }

  @override
  void clearSessionCache() {
    _status = SosStatus.received;
    _lastReportId = null;
  }

  void clearCache() => clearSessionCache();
}
