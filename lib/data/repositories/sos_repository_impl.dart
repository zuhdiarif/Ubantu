import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_sos_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';

class SosRepositoryImpl implements ISosRepository {
  final SupabaseSosService? _supabaseSosService;
  SosStatus _status = SosStatus.received;

  SosRepositoryImpl({SupabaseSosService? service})
      : _supabaseSosService = service;

  @override
  Future<AppResult<SosReportModel>> submitSosReport(String issueType) async {
    final service = _supabaseSosService;
    if (service != null) {
      final result = await service.submitSosReport(issueType);
      if (result.isSuccess) {
        return result;
      }
    }

    final report = SosReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'usr_farel',
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
}
