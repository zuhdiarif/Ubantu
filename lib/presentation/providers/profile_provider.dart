import 'package:flutter/material.dart';
import 'package:ubantu/domain/models/profile_state_model.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileStateModel _profileStats = ProfileStateModel.initial();

  ProfileStateModel get profileStats => _profileStats;

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
