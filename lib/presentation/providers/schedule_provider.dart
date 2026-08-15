import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/schedule_repository_impl.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';
import 'package:ubantu/domain/repositories/schedule_repository.dart';
import 'package:ubantu/domain/usecases/book_schedule_usecase.dart';

class ScheduleProvider extends ChangeNotifier {
  final IScheduleRepository _repository;
  final BookScheduleUseCase _bookScheduleUseCase;

  ScheduleProvider({IScheduleRepository? repository})
      : _repository = repository ?? ScheduleRepositoryImpl(),
        _bookScheduleUseCase = BookScheduleUseCase(repository ?? ScheduleRepositoryImpl());

  List<SmartScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SmartScheduleModel> get schedules => List.unmodifiable(_schedules);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSchedules(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getSchedules(userId);
    if (result.isSuccess) {
      _schedules = result.data ?? [];
    } else {
      _errorMessage = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> bookSchedule(SmartScheduleModel schedule) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _bookScheduleUseCase.execute(schedule);
    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      _schedules.add(result.data!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage ?? 'Gagal membuat pemesanan jadwal';
      notifyListeners();
      return false;
    }
  }
}
