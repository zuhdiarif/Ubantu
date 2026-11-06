import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/domain/models/profile_state_model.dart';
import 'package:ubantu/domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final IProfileRepository _repository;
  ProfileStateModel _profileStats = ProfileStateModel.initial();

  ProfileProvider({IProfileRepository? repository})
      : _repository = repository ?? ServiceLocator.instance.profileRepository;

  IProfileRepository get repository => _repository;

  ProfileStateModel get profileStats => _profileStats;

  void resetSession() {
    _profileStats = ProfileStateModel.initial();
    notifyListeners();
  }

  void incrementCompletedTask() {
    _profileStats = ProfileStateModel(
      completedTasksCount: _profileStats.completedTasksCount + 1,
      totalHelpedCount: _profileStats.totalHelpedCount,
      averageRating: _profileStats.averageRating,
      volunteerPoints: _profileStats.volunteerPoints + 10,
    );
    notifyListeners();
  }
}
