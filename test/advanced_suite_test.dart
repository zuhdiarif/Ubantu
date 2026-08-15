import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubantu/data/repositories/loyalty_repository_impl.dart';
import 'package:ubantu/data/repositories/schedule_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';
import 'package:ubantu/domain/models/task_model.dart';

import 'package:ubantu/domain/usecases/book_schedule_usecase.dart';
import 'package:ubantu/domain/usecases/claim_reward_usecase.dart';
import 'package:ubantu/domain/usecases/emergency_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/female_only_tasks_usecase.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/schedule_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Advanced Architectural & Domain Models Tests', () {
    test('FemaleOnlyTasksUseCase filter test', () {
      final tasks = [
        const TaskModel(
          id: '1',
          title: 'Bersih Kos Cewek',
          requesterName: 'Anisa',
          rating: 4.8,
          ratingCount: 12,
          category: ServiceCategory.bersihKos,
          location: 'Malang',
          date: '17 Aug',
          time: '10:00',
          notes: 'Kos putri',
          isFemaleOnly: true,
        ),
        const TaskModel(
          id: '2',
          title: 'Angkut Barang',
          requesterName: 'Budi',
          rating: 4.5,
          ratingCount: 8,
          category: ServiceCategory.pindahKos,
          location: 'Malang',
          date: '17 Aug',
          time: '12:00',
          notes: 'Pindahan',
          isFemaleOnly: false,
        ),
      ];

      final useCase = FemaleOnlyTasksUseCase();
      final filtered = useCase.execute(tasks);
      expect(filtered.length, 1);
      expect(filtered.first.isFemaleOnly, true);
    });

    test('EmergencyTasksUseCase filter test', () {
      final tasks = [
        const TaskModel(
          id: '1',
          title: 'Kunci Tertinggal Darurat',
          requesterName: 'Dinda',
          rating: 4.9,
          ratingCount: 20,
          category: ServiceCategory.antarJemput,
          location: 'Malang',
          date: '17 Aug',
          time: '14:00',
          notes: 'Darurat',
          isEmergency: true,
        ),
      ];

      final useCase = EmergencyTasksUseCase();
      final filtered = useCase.execute(tasks);
      expect(filtered.length, 1);
      expect(filtered.first.isEmergency, true);
    });

    test('RewardPointsModel JSON serialization', () {
      final model = const RewardPointsModel(
        userId: 'usr_100',
        totalPoints: 250,
        availableVouchers: 2,
        claimedVoucherCodes: ['GRATIS1X_01'],
      );

      final json = model.toJson();
      expect(json['user_id'], 'usr_100');
      expect(json['total_points'], 250);

      final fromJson = RewardPointsModel.fromJson(json);
      expect(fromJson.totalPoints, 250);
      expect(fromJson.availableVouchers, 2);
    });

    test('SmartScheduleModel JSON serialization', () {
      final schedule = SmartScheduleModel(
        id: 'sch_10',
        userId: 'usr_100',
        taskId: 't1',
        taskTitle: 'Jasa Bersih Kos',
        scheduledTime: DateTime.now(),
        category: ServiceCategory.bersihKos,
        isReminderEnabled: true,
      );

      final json = schedule.toJson();
      expect(json['task_title'], 'Jasa Bersih Kos');

      final fromJson = SmartScheduleModel.fromJson(json);
      expect(fromJson.id, 'sch_10');
      expect(fromJson.category, ServiceCategory.bersihKos);
    });

    test('LoyaltyRepositoryImpl & ClaimRewardUseCase execution', () async {
      final repo = LoyaltyRepositoryImpl();
      final useCase = ClaimRewardUseCase(repo);

      final getResult = await repo.getLoyaltyPoints('usr_tester');
      expect(getResult.isSuccess, true);
      expect(getResult.data?.totalPoints, 120);

      final claimResult = await useCase.execute('usr_tester', 100);
      expect(claimResult.isSuccess, true);
      expect(claimResult.data?.availableVouchers, 2);
    });

    test('ScheduleRepositoryImpl & BookScheduleUseCase execution', () async {
      final repo = ScheduleRepositoryImpl();
      final useCase = BookScheduleUseCase(repo);

      final getResult = await repo.getSchedules('usr_tester');
      expect(getResult.isSuccess, true);
      expect(getResult.data?.length, 2);

      final newSchedule = SmartScheduleModel(
        id: 'sch_99',
        userId: 'usr_tester',
        taskId: 't99',
        taskTitle: 'Pindah Kos',
        scheduledTime: DateTime.now().add(const Duration(days: 3)),
        category: ServiceCategory.pindahKos,
      );

      final bookResult = await useCase.execute(newSchedule);
      expect(bookResult.isSuccess, true);
      expect(bookResult.data?.id, 'sch_99');
    });

    test('LoyaltyProvider state management load & claim', () async {
      final provider = LoyaltyProvider();
      await provider.loadLoyaltyPoints('usr_tester');

      expect(provider.totalPoints, 120);
      expect(provider.availableVouchers, 1);

      final claimed = await provider.claimVoucher('usr_tester', 100);
      expect(claimed, true);
      expect(provider.availableVouchers, 2);
    });

    test('ScheduleProvider state management load & book', () async {
      final provider = ScheduleProvider();
      await provider.loadSchedules('usr_tester');

      expect(provider.schedules.length, 2);

      final newSchedule = SmartScheduleModel(
        id: 'sch_new',
        userId: 'usr_tester',
        taskId: 't_new',
        taskTitle: 'Antar Barang',
        scheduledTime: DateTime.now(),
        category: ServiceCategory.antarJemput,
      );

      final booked = await provider.bookSchedule(newSchedule);
      expect(booked, true);
      expect(provider.schedules.length, 3);
    });
  });
}
