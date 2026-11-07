import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/utils/mock_data_factory.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/data/services/supabase_task_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/models/task_model.dart';
import 'package:ubantu/ui/home/task_provider.dart';

class FakeEmptyRemoteTaskService extends SupabaseTaskService {
  @override
  Future<AppResult<List<TaskModel>>> getTasks({String? excludeRequesterId}) async {
    return AppResult.success(const []);
  }
}

class FakePopulatedRemoteTaskService extends SupabaseTaskService {
  final List<TaskModel> tasks;

  FakePopulatedRemoteTaskService(this.tasks);

  @override
  Future<AppResult<List<TaskModel>>> getTasks({String? excludeRequesterId}) async {
    return AppResult.success(tasks);
  }
}

void main() {
  group('TaskModel & service_orders Unification Tests', () {
    test('TaskModel.fromJson parses service_orders payload properly', () {
      final scheduledTime = DateTime(2026, 8, 20, 14, 30);
      final json = <String, dynamic>{
        'id': 'so_123',
        'category': 'antarJemput',
        'status': 'waiting',
        'location_origin': 'Gerbang Veteran UB',
        'scheduled_at': scheduledTime.toIso8601String(),
        'item_description': 'Tebengan ke Stasiun',
        'barter_description': 'Kopi Kenangan',
        'is_female_only': true,
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, 'so_123');
      expect(task.category, ServiceCategory.antarJemput);
      expect(task.status, TaskStatus.pending);
      expect(task.isFemaleOnly, true);
      expect(task.title, 'Tebengan ke Stasiun');
      expect(task.location, 'Gerbang Veteran UB');
      expect(task.notes, 'Kopi Kenangan');
      expect(task.requesterName, 'Mahasiswa UB');
      expect(task.date, '20/08/2026');
      expect(task.time, '14:30 WIB');
    });

    test('TaskModel.fromJson falls back to category defaults when optional fields empty', () {
      final json = <String, dynamic>{
        'id': 'so_blank',
        'category': 'pindahKos',
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, 'so_blank');
      expect(task.category, ServiceCategory.pindahKos);
      expect(task.title, 'Bantuan Pindah Kos');
      expect(task.requesterName, 'Mahasiswa UB');
      expect(task.location, 'Universitas Brawijaya');
      expect(task.date, 'Hari ini');
      expect(task.time, '10:00 WIB');
      expect(task.notes, '');
      expect(task.status, TaskStatus.pending);
    });

    test('TaskModel.fromServiceOrder converts model losslessly', () {
      final scheduledAt = DateTime(2026, 9, 15, 10, 0);
      final order = ServiceOrderModel(
        id: 'so_456',
        requesterId: 'usr_1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Kos Griya UB',
        locationDestination: 'Kos Griya UB',
        scheduledAt: scheduledAt,
        itemDescription: 'Sapu dan pel lantai',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi padang ayam bakar',
        isFemaleOnly: true,
        receiverName: 'Rina Mahasiswa',
        createdAt: DateTime(2026, 9, 14, 8, 0),
      );

      final task = TaskModel.fromServiceOrder(order);

      expect(task.id, 'so_456');
      expect(task.category, ServiceCategory.bersihKos);
      expect(task.status, TaskStatus.pending);
      expect(task.title, 'Sapu dan pel lantai');
      expect(task.notes, 'Nasi padang ayam bakar');
      expect(task.location, 'Kos Griya UB');
      expect(task.requesterName, 'Rina Mahasiswa');
      expect(task.isFemaleOnly, true);
    });

    test('TaskModel.fromJson status mapping coverage', () {
      expect(TaskModel.fromJson({'status': 'waiting'}).status, TaskStatus.pending);
      expect(TaskModel.fromJson({'status': 'pending'}).status, TaskStatus.pending);
      expect(TaskModel.fromJson({'status': 'accepted'}).status, TaskStatus.inProgress);
      expect(TaskModel.fromJson({'status': 'inProgress'}).status, TaskStatus.inProgress);
      expect(TaskModel.fromJson({'status': 'completed'}).status, TaskStatus.completed);
      expect(TaskModel.fromJson({'status': 'cancelled'}).status, TaskStatus.cancelled);
      expect(TaskModel.fromJson({'status': 'dibatalkan'}).status, TaskStatus.cancelled);
    });
  });

  group('TaskRepositoryImpl Unification and Mock Fallback Elimination Tests', () {
    test('TaskRepositoryImpl returns empty list when remote is active and table is empty', () async {
      final repo = TaskRepositoryImpl(
        isRemoteActiveOverride: true,
        remoteService: FakeEmptyRemoteTaskService(),
      );

      final result = await repo.getTasks();

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data, isEmpty);
      expect(result.data?.length, isNot(MockDataFactory.mockTasks.length));
    });

    test('TaskRepositoryImpl returns remote tasks when remote is active and has items', () async {
      final customTask = const TaskModel(
        id: 'remote_1',
        title: 'Bantu Pindahan',
        requesterName: 'Budi',
        rating: 5.0,
        ratingCount: 10,
        category: ServiceCategory.pindahKos,
        location: 'Jl. Veteran',
        date: 'Hari ini',
        time: '12:00 WIB',
        notes: 'Bawa motor',
      );

      final repo = TaskRepositoryImpl(
        isRemoteActiveOverride: true,
        remoteService: FakePopulatedRemoteTaskService([customTask]),
      );

      final result = await repo.getTasks();

      expect(result.isSuccess, true);
      expect(result.data?.length, 1);
      expect(result.data?.first.id, 'remote_1');
    });

    test('TaskRepositoryImpl returns mock tasks when remote is inactive', () async {
      final repo = TaskRepositoryImpl(isRemoteActiveOverride: false);

      final result = await repo.getTasks();

      expect(result.isSuccess, true);
      expect(result.data?.isNotEmpty, true);
      expect(result.data?.length, MockDataFactory.mockTasks.length);
    });

    test('TaskProvider handles empty remote list correctly without falling back to mock tasks', () async {
      final repo = TaskRepositoryImpl(
        isRemoteActiveOverride: true,
        remoteService: FakeEmptyRemoteTaskService(),
      );
      final provider = TaskProvider(repository: repo);

      await provider.loadTasks();

      expect(provider.isLoading, false);
      expect(provider.tasks, isEmpty);
    });
  });
}
