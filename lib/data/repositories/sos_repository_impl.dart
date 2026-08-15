import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';

class SosRepositoryImpl implements ISosRepository {
  SosStatus _status = SosStatus.received;

  @override
  Future<AppResult<SosReportModel>> submitSosReport(String issueType) async {
    await Future.delayed(const Duration(milliseconds: 200));
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
