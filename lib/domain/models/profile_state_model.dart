class ProfileStateModel {
  final int completedTasksCount;
  final int totalHelpedCount;
  final double averageRating;
  final int volunteerPoints;

  const ProfileStateModel({
    required this.completedTasksCount,
    required this.totalHelpedCount,
    required this.averageRating,
    required this.volunteerPoints,
  });

  factory ProfileStateModel.initial() {
    return const ProfileStateModel(
      completedTasksCount: 12,
      totalHelpedCount: 8,
      averageRating: 4.9,
      volunteerPoints: 150,
    );
  }
}
