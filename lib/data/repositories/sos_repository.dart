import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/sos_report_model.dart';

abstract class ISosRepository {
  Future<AppResult<SosReportModel>> submitSosReport(String issueType);
  Future<void> updateSosStatus(SosStatus status);
}
