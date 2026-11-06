import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/sos_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';
import 'package:ubantu/domain/usecases/submit_sos_usecase.dart';

class SosProvider extends ChangeNotifier {
  final SubmitSosUseCase _submitSosUseCase;
  final ISosRepository _repository;

  SosProvider({ISosRepository? repository})
      : _repository = repository ?? SosRepositoryImpl(),
        _submitSosUseCase = SubmitSosUseCase(repository ?? SosRepositoryImpl());

  int _selectedReasonIndex = 0;
  SosStatus _currentStatus = SosStatus.received;
  SosReportModel? _activeReport;

  int get selectedReasonIndex => _selectedReasonIndex;
  SosStatus get currentStatus => _currentStatus;
  SosReportModel? get activeReport => _activeReport;

  void selectReason(int index) {
    _selectedReasonIndex = index;
    notifyListeners();
  }

  Future<void> updateStatus(SosStatus status) async {
    _currentStatus = status;
    await _repository.updateSosStatus(status);
    notifyListeners();
  }

  Future<void> submitReport(String issueType) async {
    final result = await _submitSosUseCase.execute(issueType);
    if (result.isSuccess && result.data != null) {
      _activeReport = result.data;
      _currentStatus = result.data!.status;
    } else {
      _activeReport = SosReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'usr_fallback',
        issueType: issueType,
        status: SosStatus.received,
        createdAt: DateTime.now(),
      );
      _currentStatus = SosStatus.received;
    }
    notifyListeners();
  }
}
