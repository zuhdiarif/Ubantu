import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';
import 'package:ubantu/domain/usecases/get_tasks_usecase.dart';

class TaskProvider extends ChangeNotifier {
  final GetTasksUseCase _getTasksUseCase;

  TaskProvider({ITaskRepository? repository})
      : _getTasksUseCase = GetTasksUseCase(repository ?? TaskRepositoryImpl());

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  int _selectedModeIndex = 0;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  int get selectedModeIndex => _selectedModeIndex;

  void switchMode(int index) {
    _selectedModeIndex = index;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getTasksUseCase.execute();
    if (result.isSuccess) {
      _tasks = result.data ?? [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
