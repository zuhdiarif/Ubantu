import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';

class SubmitSosUseCase {
  final ISosRepository repository;

  SubmitSosUseCase(this.repository);

  Future<AppResult<SosReportModel>> execute(String issueType) {
    return repository.submitSosReport(issueType);
  }
}
