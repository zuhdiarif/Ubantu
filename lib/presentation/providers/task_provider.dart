import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';
import 'package:ubantu/domain/usecases/filter_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/get_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/search_tasks_usecase.dart';

class TaskProvider extends ChangeNotifier {
  final GetTasksUseCase _getTasksUseCase;
  final SearchTasksUseCase _searchTasksUseCase;
  final FilterTasksUseCase _filterTasksUseCase;

  TaskProvider({ITaskRepository? repository})
      : _getTasksUseCase = GetTasksUseCase(repository ?? TaskRepositoryImpl()),
        _searchTasksUseCase = SearchTasksUseCase(),
        _filterTasksUseCase = FilterTasksUseCase();

  List<TaskModel> _allTasks = [];
  List<TaskModel> _filteredTasks = [];
  bool _isLoading = false;
  int _selectedModeIndex = 0;
  String _searchQuery = '';
  bool _isFemaleOnlyFilter = false;

  List<TaskModel> get tasks => List.unmodifiable(_filteredTasks.isNotEmpty || _searchQuery.isNotEmpty || _isFemaleOnlyFilter ? _filteredTasks : _allTasks);
  bool get isLoading => _isLoading;
  int get selectedModeIndex => _selectedModeIndex;
  String get searchQuery => _searchQuery;
  bool get isFemaleOnlyFilter => _isFemaleOnlyFilter;

  void switchMode(int index) {
    _selectedModeIndex = index;
    notifyListeners();
  }

  void toggleFemaleOnlyFilter() {
    _isFemaleOnlyFilter = !_isFemaleOnlyFilter;
    _applyFilters();
    notifyListeners();
  }

  void setFemaleOnlyFilter(bool value) {
    if (_isFemaleOnlyFilter != value) {
      _isFemaleOnlyFilter = value;
      _applyFilters();
      notifyListeners();
    }
  }

  void searchTasks(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<TaskModel> result = _allTasks;
    if (_searchQuery.isNotEmpty) {
      result = _searchTasksUseCase.execute(
        result,
        TaskFilterModel(searchQuery: _searchQuery),
      );
    }
    if (_isFemaleOnlyFilter) {
      result = _filterTasksUseCase.execute(
        result,
        const TaskFilterModel(isFemaleOnly: true),
      );
    }
    _filteredTasks = result;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getTasksUseCase.execute();
    if (result.isSuccess) {
      _allTasks = result.data ?? [];
      _applyFilters();
    }

    _isLoading = false;
    notifyListeners();
  }
}
