import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/utils/mock_data_factory.dart';
import 'package:ubantu/data/repositories/barter_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/usecases/filter_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/get_barter_items_usecase.dart';

void main() {
  group('New Domain UseCases Unit Tests', () {
    test('FilterTasksUseCase filter by category', () {
      final tasks = MockDataFactory.mockTasks;
      final useCase = FilterTasksUseCase();

      final filtered = useCase.execute(
        tasks,
        const TaskFilterModel(category: ServiceCategory.bersihKos),
      );

      expect(filtered.length, 2);
      expect(filtered.first.category, ServiceCategory.bersihKos);
    });

    test('GetBarterItemsUseCase fetching available barters', () async {
      final useCase = GetBarterItemsUseCase(BarterRepositoryImpl());
      final result = await useCase.execute();

      expect(result.isSuccess, true);
      expect(result.data?.length, 2);
    });
  });
}
