import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/schedule_repository_impl.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';
import 'package:ubantu/domain/models/student_schedule_model.dart';
import 'package:ubantu/domain/repositories/schedule_repository.dart';
import 'package:ubantu/domain/usecases/book_schedule_usecase.dart';
import 'package:ubantu/domain/usecases/check_schedule_conflict_usecase.dart';

class ScheduleProvider extends ChangeNotifier {
  final IScheduleRepository _repository;
  final BookScheduleUseCase _bookScheduleUseCase;
  final CheckScheduleConflictUseCase _checkConflictUseCase;

  ScheduleProvider({
    IScheduleRepository? repository,
    CheckScheduleConflictUseCase? checkConflictUseCase,
  })  : _repository = repository ?? ScheduleRepositoryImpl(),
        _bookScheduleUseCase =
            BookScheduleUseCase(repository ?? ScheduleRepositoryImpl()),
        _checkConflictUseCase =
            checkConflictUseCase ?? const CheckScheduleConflictUseCase();

  List<SmartScheduleModel> _schedules = [];
  List<StudentScheduleModel> _studentSchedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SmartScheduleModel> get schedules => List.unmodifiable(_schedules);
  List<StudentScheduleModel> get studentSchedules =>
      List.unmodifiable(_studentSchedules);
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

  Future<void> loadStudentSchedules(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getStudentSchedules(userId);
    if (result.isSuccess) {
      _studentSchedules = result.data ?? [];
    } else {
      _errorMessage = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addStudentSchedule(StudentScheduleModel schedule) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.addStudentSchedule(schedule);
    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      _studentSchedules.add(result.data!);
      _studentSchedules.sort((a, b) {
        final dayDiff = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayDiff != 0) return dayDiff;
        return a.startMinutes.compareTo(b.startMinutes);
      });
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage ?? 'Gagal menambahkan jadwal kuliah';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudentSchedule(String scheduleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.deleteStudentSchedule(scheduleId);
    _isLoading = false;

    if (result.isSuccess) {
      _studentSchedules.removeWhere((s) => s.id == scheduleId);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage ?? 'Gagal menghapus jadwal kuliah';
      notifyListeners();
      return false;
    }
  }

  ScheduleConflictResult checkOrderConflict(ServiceOrderModel order) {
    return _checkConflictUseCase.checkOrder(
      order: order,
      schedules: _studentSchedules,
    );
  }

  ScheduleConflictResult checkTimeConflict(DateTime time) {
    return _checkConflictUseCase.execute(
      orderTime: time,
      schedules: _studentSchedules,
    );
  }
}
