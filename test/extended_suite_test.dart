import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubantu/core/utils/mock_data_factory.dart';
import 'package:ubantu/data/repositories/rating_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/rating_model.dart';
import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/usecases/search_tasks_usecase.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Extended Architectural Unit & Widget Tests', () {
    test('SearchTasksUseCase query matching title & location', () {
      final tasks = MockDataFactory.mockTasks;
      final useCase = SearchTasksUseCase();

      final resultsTitle = useCase.execute(
        tasks,
        const TaskFilterModel(searchQuery: 'Bersih'),
      );
      expect(resultsTitle.length, 2);

      final resultsLocation = useCase.execute(
        tasks,
        const TaskFilterModel(searchQuery: 'Malang'),
      );
      expect(resultsLocation.length, 7);
    });

    test('TaskFilterModel copyWith parameters', () {
      const filter = TaskFilterModel(category: ServiceCategory.bersihKos);
      final updated = filter.copyWith(
        searchQuery: 'Pindah',
        minRating: 4.5,
        status: TaskStatus.pending,
      );

      expect(updated.category, ServiceCategory.bersihKos);
      expect(updated.searchQuery, 'Pindah');
      expect(updated.minRating, 4.5);
      expect(updated.status, TaskStatus.pending);
    });

    test('TaskProvider search query state management', () async {
      final provider = TaskProvider();
      await provider.loadTasks();

      expect(provider.tasks.length, 7);

      provider.searchTasks('Bersih');
      expect(provider.tasks.length, 2);
      expect(provider.searchQuery, 'Bersih');

      provider.searchTasks('');
      expect(provider.tasks.length, 7);
    });

    test('RatingRepositoryImpl get & submit ratings', () async {
      final repo = RatingRepositoryImpl();

      final getResult = await repo.getRatings('usr_test');
      expect(getResult.isSuccess, true);
      expect(getResult.data?.length, 2);

      final submitResult = await repo.addRating('usr_test', 5.0, 'Sangat baik');
      expect(submitResult.isSuccess, true);
      expect(submitResult.data?.score, 5.0);
    });

    test('RatingProvider load & submit ulasan state', () async {
      final provider = RatingProvider();
      expect(provider.ratings.isEmpty, true);

      await provider.loadRatings('usr_test');
      expect(provider.ratings.length, 2);
      expect(provider.isLoading, false);

      final success = await provider.submitRating('usr_test', 5.0, 'Pelayanan memuaskan');
      expect(success, true);
      expect(provider.ratings.length, 3);
      expect(provider.ratings.first.reviewText, 'Pelayanan memuaskan');
    });

    test('RatingModel JSON conversion', () {
      final rating = RatingModel(
        id: 'r99',
        reviewerName: 'Rafi',
        score: 4.7,
        reviewText: 'Cepat tanggap',
        createdAt: DateTime.now(),
      );

      final json = rating.toJson();
      expect(json['reviewer_name'], 'Rafi');
      expect(json['score'], 4.7);

      final fromJson = RatingModel.fromJson(json);
      expect(fromJson.id, 'r99');
      expect(fromJson.score, 4.7);
    });
  });
}
