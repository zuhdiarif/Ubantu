import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';
import 'package:ubantu/domain/usecases/get_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/search_tasks_usecase.dart';

class TaskProvider extends ChangeNotifier {
  final GetTasksUseCase _getTasksUseCase;
  final SearchTasksUseCase _searchTasksUseCase;

  TaskProvider({ITaskRepository? repository})
      : _getTasksUseCase = GetTasksUseCase(repository ?? TaskRepositoryImpl()),
        _searchTasksUseCase = SearchTasksUseCase();

  List<TaskModel> _allTasks = [];
  List<TaskModel> _filteredTasks = [];
  bool _isLoading = false;
  int _selectedModeIndex = 0;
  String _searchQuery = '';

  List<TaskModel> get tasks => List.unmodifiable(_filteredTasks.isNotEmpty || _searchQuery.isNotEmpty ? _filteredTasks : _allTasks);
  bool get isLoading => _isLoading;
  int get selectedModeIndex => _selectedModeIndex;
  String get searchQuery => _searchQuery;

  void switchMode(int index) {
    _selectedModeIndex = index;
    notifyListeners();
  }

  void searchTasks(String query) {
    _searchQuery = query;
    _filteredTasks = _searchTasksUseCase.execute(
      _allTasks,
      TaskFilterModel(searchQuery: query),
    );
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getTasksUseCase.execute();
    if (result.isSuccess) {
      _allTasks = result.data ?? [];
      if (_searchQuery.isNotEmpty) {
        _filteredTasks = _searchTasksUseCase.execute(
          _allTasks,
          TaskFilterModel(searchQuery: _searchQuery),
        );
      } else {
        _filteredTasks = List.from(_allTasks);
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
