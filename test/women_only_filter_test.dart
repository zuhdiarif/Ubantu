import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/usecases/filter_tasks_usecase.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';
import 'package:ubantu/presentation/views/home_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_dashboard_view.dart';

void main() {
  group('Women-Only Filter Domain & UseCase Tests', () {
    test('TaskFilterModel holds and updates isFemaleOnly', () {
      const filter = TaskFilterModel(isFemaleOnly: true);
      expect(filter.isFemaleOnly, true);

      final updated = filter.copyWith(isFemaleOnly: false);
      expect(updated.isFemaleOnly, false);
    });

    test('FilterTasksUseCase correctly filters isFemaleOnly tasks', () {
      final useCase = FilterTasksUseCase();
      final tasks = <TaskModel>[
        const TaskModel(
          id: 't1',
          title: 'Bantu Pindah',
          requesterName: 'Andi',
          rating: 4.8,
          ratingCount: 12,
          category: ServiceCategory.pindahKos,
          location: 'Kerto',
          date: 'Hari ini',
          time: '14:00',
          notes: 'Koper',
          isFemaleOnly: false,
        ),
        const TaskModel(
          id: 't2',
          title: 'Kamar Mahasiswi',
          requesterName: 'Siti',
          rating: 4.9,
          ratingCount: 8,
          category: ServiceCategory.bersihKos,
          location: 'Sigura-gura',
          date: 'Besok',
          time: '10:00',
          notes: 'Kamar mandi & kamar',
          isFemaleOnly: true,
        ),
      ];

      final filtered = useCase.execute(tasks, const TaskFilterModel(isFemaleOnly: true));
      expect(filtered.length, 1);
      expect(filtered.first.id, 't2');
      expect(filtered.first.isFemaleOnly, true);
    });

    test('ServiceOrderModel serializes and deserializes isFemaleOnly', () {
      final now = DateTime.now();
      final order = ServiceOrderModel(
        id: 'ord_test',
        requesterId: 'usr_test',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Jl. Kerto',
        locationDestination: 'Jl. Sumbersari',
        scheduledAt: now,
        itemDescription: 'Koper dan buku',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi Padang',
        createdAt: now,
        isFemaleOnly: true,
      );

      final json = order.toJson();
      expect(json['is_female_only'], true);

      final fromJson = ServiceOrderModel.fromJson(json);
      expect(fromJson.isFemaleOnly, true);
      expect(fromJson.id, 'ord_test');

      final copied = order.copyWith(isFemaleOnly: false);
      expect(copied.isFemaleOnly, false);
    });

    test('TaskProvider toggles female only filter', () async {
      final provider = TaskProvider(repository: ServiceLocator.instance.taskRepository);

      await provider.loadTasks();
      expect(provider.isFemaleOnlyFilter, false);

      provider.toggleFemaleOnlyFilter();
      expect(provider.isFemaleOnlyFilter, true);
      expect(provider.tasks.every((t) => t.isFemaleOnly), true);

      provider.toggleFemaleOnlyFilter();
      expect(provider.isFemaleOnlyFilter, false);
    });
  });

  group('Women-Only Filter UI Widgets Tests', () {
    testWidgets('HomeView renders Women-Only FilterChip and toggles', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authProvider = AuthProvider(repository: ServiceLocator.instance.authRepository);
      final taskProvider = TaskProvider(repository: ServiceLocator.instance.taskRepository);
      final serviceOrderProvider = ServiceOrderProvider(repository: ServiceLocator.instance.serviceOrderRepository);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: serviceOrderProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Membantu'));
      await tester.pumpAndSettle();

      final chipFinder = find.text('Women-Only');
      expect(chipFinder, findsOneWidget);

      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      expect(taskProvider.isFemaleOnlyFilter, true);
    });

    testWidgets('MitraDashboardView renders Khusus Mahasiswi chip and toggles filter', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final mitraProvider = MitraProvider(repository: ServiceLocator.instance.mitraRepository);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: mitraProvider),
          ],
          child: const MaterialApp(
            home: MitraDashboardView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final chipFinder = find.text('Khusus Mahasiswi');
      expect(chipFinder, findsOneWidget);

      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      expect(find.text('Khusus Mahasiswi'), findsOneWidget);
    });
  });
}
