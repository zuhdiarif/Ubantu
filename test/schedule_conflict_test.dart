import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/ui/widgets/custom_badge.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/models/smart_schedule_model.dart';
import 'package:ubantu/data/models/student_schedule_model.dart';
import 'package:ubantu/data/repositories/schedule_repository.dart';
import 'package:ubantu/logic/check_schedule_conflict_usecase.dart';
import 'package:ubantu/ui/mitra/mitra_provider.dart';
import 'package:ubantu/ui/mitra/schedule_provider.dart';
import 'package:ubantu/ui/mitra/mitra_dashboard_view.dart';
import 'package:ubantu/ui/mitra/widgets/class_schedule_sheet.dart';

class MockScheduleRepository implements IScheduleRepository {
  final List<StudentScheduleModel> _slots = [];

  MockScheduleRepository([List<StudentScheduleModel>? initialSlots]) {
    if (initialSlots != null) {
      _slots.addAll(initialSlots);
    }
  }

  @override
  Future<AppResult<List<SmartScheduleModel>>> getSchedules(String userId) async {
    return AppResult.success([]);
  }

  @override
  Future<AppResult<SmartScheduleModel>> bookSchedule(SmartScheduleModel schedule) async {
    return AppResult.success(schedule);
  }

  @override
  Future<AppResult<List<StudentScheduleModel>>> getStudentSchedules(String userId) async {
    return AppResult.success(List.from(_slots));
  }

  @override
  Future<AppResult<StudentScheduleModel>> addStudentSchedule(StudentScheduleModel schedule) async {
    _slots.add(schedule);
    return AppResult.success(schedule);
  }

  @override
  Future<AppResult<bool>> deleteStudentSchedule(String scheduleId) async {
    _slots.removeWhere((s) => s.id == scheduleId);
    return AppResult.success(true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CheckScheduleConflictUseCase Unit Tests', () {
    const useCase = CheckScheduleConflictUseCase();

    final testSchedules = [
      const StudentScheduleModel(
        id: 's1',
        userId: 'm1',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        courseName: 'Pemrograman Mobile',
      ),
      const StudentScheduleModel(
        id: 's2',
        userId: 'm1',
        dayOfWeek: 1,
        startTime: '13:00',
        endTime: '15:00',
        courseName: 'Basis Data',
      ),
      const StudentScheduleModel(
        id: 's3',
        userId: 'm1',
        dayOfWeek: 3,
        startTime: '09:00',
        endTime: '11:00',
        courseName: 'Jaringan Komputer',
      ),
    ];

    test('returns safe when order day has no scheduled classes (day mismatch boundary)', () {
      final tuesdayOrder = DateTime(2026, 11, 10, 8, 30);
      expect(tuesdayOrder.weekday, 2);

      final result = useCase.execute(
        orderTime: tuesdayOrder,
        schedules: testSchedules,
      );

      expect(result.status, ScheduleConflictStatus.safe);
      expect(result.label, 'Aman dari Jam Kuliah');
      expect(result.badgeType, BadgeType.success);
      expect(result.conflictingSchedule, isNull);
    });

    test('returns safe when order is far from any class (safe boundary > 60 min)', () {
      final earlyMondayOrder = DateTime(2026, 11, 9, 6, 0);
      expect(earlyMondayOrder.weekday, 1);
      final resultEarly = useCase.execute(
        orderTime: earlyMondayOrder,
        schedules: testSchedules,
      );
      expect(resultEarly.status, ScheduleConflictStatus.safe);
      expect(resultEarly.label, 'Aman dari Jam Kuliah');
      expect(resultEarly.badgeType, BadgeType.success);

      final edgeSafeBefore = DateTime(2026, 11, 9, 6, 59);
      final resultEdgeBefore = useCase.execute(
        orderTime: edgeSafeBefore,
        schedules: testSchedules,
      );
      expect(resultEdgeBefore.status, ScheduleConflictStatus.safe);

      final edgeSafeAfter = DateTime(2026, 11, 9, 11, 1);
      final resultEdgeAfter = useCase.execute(
        orderTime: edgeSafeAfter,
        schedules: testSchedules,
      );
      expect(resultEdgeAfter.status, ScheduleConflictStatus.safe);

      final lateMondayOrder = DateTime(2026, 11, 9, 17, 0);
      final resultLate = useCase.execute(
        orderTime: lateMondayOrder,
        schedules: testSchedules,
      );
      expect(resultLate.status, ScheduleConflictStatus.safe);
    });

    test('returns near when class starts or ends within 60 min (near boundary)', () {
      final exactly60MinBefore = DateTime(2026, 11, 9, 7, 0);
      expect(exactly60MinBefore.weekday, 1);
      final res60Before = useCase.execute(
        orderTime: exactly60MinBefore,
        schedules: testSchedules,
      );
      expect(res60Before.status, ScheduleConflictStatus.near);
      expect(res60Before.label, 'Dekat Jam Kuliah');
      expect(res60Before.badgeType, BadgeType.warning);

      final thirtyMinBefore = DateTime(2026, 11, 9, 7, 30);
      final res30Before = useCase.execute(
        orderTime: thirtyMinBefore,
        schedules: testSchedules,
      );
      expect(res30Before.status, ScheduleConflictStatus.near);

      final oneMinBefore = DateTime(2026, 11, 9, 7, 59);
      final res1Before = useCase.execute(
        orderTime: oneMinBefore,
        schedules: testSchedules,
      );
      expect(res1Before.status, ScheduleConflictStatus.near);

      final classEndBoundary = DateTime(2026, 11, 9, 10, 0);
      final resEnd = useCase.execute(
        orderTime: classEndBoundary,
        schedules: testSchedules,
      );
      expect(resEnd.status, ScheduleConflictStatus.near);

      final thirtyMinAfter = DateTime(2026, 11, 9, 10, 30);
      final res30After = useCase.execute(
        orderTime: thirtyMinAfter,
        schedules: testSchedules,
      );
      expect(res30After.status, ScheduleConflictStatus.near);

      final exactly60MinAfter = DateTime(2026, 11, 9, 11, 0);
      final res60After = useCase.execute(
        orderTime: exactly60MinAfter,
        schedules: testSchedules,
      );
      expect(res60After.status, ScheduleConflictStatus.near);
    });

    test('returns conflict when order overlaps an ongoing class (overlap boundary)', () {
      final classStartExact = DateTime(2026, 11, 9, 8, 0);
      expect(classStartExact.weekday, 1);
      final resStart = useCase.execute(
        orderTime: classStartExact,
        schedules: testSchedules,
      );
      expect(resStart.status, ScheduleConflictStatus.conflict);
      expect(resStart.label, 'Bentrok Jam Kuliah');
      expect(resStart.badgeType, BadgeType.danger);
      expect(resStart.conflictingSchedule?.courseName, 'Pemrograman Mobile');

      final middleOfClass = DateTime(2026, 11, 9, 9, 15);
      final resMiddle = useCase.execute(
        orderTime: middleOfClass,
        schedules: testSchedules,
      );
      expect(resMiddle.status, ScheduleConflictStatus.conflict);

      final justBeforeEnd = DateTime(2026, 11, 9, 9, 59);
      final resJustBeforeEnd = useCase.execute(
        orderTime: justBeforeEnd,
        schedules: testSchedules,
      );
      expect(resJustBeforeEnd.status, ScheduleConflictStatus.conflict);
    });

    test('checkOrder delegates properly to execute using order scheduledAt', () {
      final order = ServiceOrderModel(
        id: 'o_test',
        requesterId: 'u1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Kec. Lowokwaru',
        locationDestination: 'Jl. Veteran Malang',
        scheduledAt: DateTime(2026, 11, 9, 8, 30),
        itemDescription: 'Bantu bersihkan kamar kos',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi goreng',
        createdAt: DateTime(2026, 11, 9, 7, 0),
      );

      final res = useCase.checkOrder(
        order: order,
        schedules: testSchedules,
      );

      expect(res.status, ScheduleConflictStatus.conflict);
      expect(res.label, 'Bentrok Jam Kuliah');
    });
  });

  group('ScheduleProvider Add, Delete & Conflict Tests', () {
    test('loadStudentSchedules loads data from repository', () async {
      final initialSlots = [
        const StudentScheduleModel(
          id: 'init_1',
          userId: 'usr_1',
          dayOfWeek: 1,
          startTime: '08:00',
          endTime: '09:40',
        ),
      ];
      final repo = MockScheduleRepository(initialSlots);
      final provider = ScheduleProvider(repository: repo);

      await provider.loadStudentSchedules('usr_1');

      expect(provider.studentSchedules.length, 1);
      expect(provider.studentSchedules.first.id, 'init_1');
    });

    test('addStudentSchedule adds slot and keeps list sorted', () async {
      final repo = MockScheduleRepository();
      final provider = ScheduleProvider(repository: repo);

      final slotWed = const StudentScheduleModel(
        id: 'slot_wed',
        userId: 'usr_1',
        dayOfWeek: 3,
        startTime: '10:00',
        endTime: '11:40',
      );
      final slotMon = const StudentScheduleModel(
        id: 'slot_mon',
        userId: 'usr_1',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '09:40',
      );

      final resWed = await provider.addStudentSchedule(slotWed);
      final resMon = await provider.addStudentSchedule(slotMon);

      expect(resWed, isTrue);
      expect(resMon, isTrue);
      expect(provider.studentSchedules.length, 2);
      expect(provider.studentSchedules.first.dayOfWeek, 1);
      expect(provider.studentSchedules.last.dayOfWeek, 3);
    });

    test('deleteStudentSchedule removes slot from list and repository', () async {
      final slot = const StudentScheduleModel(
        id: 'to_delete',
        userId: 'usr_1',
        dayOfWeek: 2,
        startTime: '13:00',
        endTime: '15:00',
      );
      final repo = MockScheduleRepository([slot]);
      final provider = ScheduleProvider(repository: repo);
      await provider.loadStudentSchedules('usr_1');
      expect(provider.studentSchedules.length, 1);

      final success = await provider.deleteStudentSchedule('to_delete');

      expect(success, isTrue);
      expect(provider.studentSchedules.isEmpty, isTrue);
    });

    test('checkOrderConflict computes conflict from current student schedules', () async {
      final mondayClass = const StudentScheduleModel(
        id: 'c1',
        userId: 'm1',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
      );
      final repo = MockScheduleRepository([mondayClass]);
      final provider = ScheduleProvider(repository: repo);
      await provider.loadStudentSchedules('m1');

      final orderConflict = ServiceOrderModel(
        id: 'ord_c',
        requesterId: 'u1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime(2026, 11, 9, 9, 0),
        itemDescription: 'Test',
        barterType: BarterType.makanan,
        barterDescription: 'Food',
        createdAt: DateTime(2026, 11, 9, 7, 0),
      );

      final orderSafe = ServiceOrderModel(
        id: 'ord_s',
        requesterId: 'u1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime(2026, 11, 10, 9, 0),
        itemDescription: 'Test',
        barterType: BarterType.makanan,
        barterDescription: 'Food',
        createdAt: DateTime(2026, 11, 10, 7, 0),
      );

      final resConflict = provider.checkOrderConflict(orderConflict);
      final resSafe = provider.checkOrderConflict(orderSafe);

      expect(resConflict.status, ScheduleConflictStatus.conflict);
      expect(resConflict.label, 'Bentrok Jam Kuliah');
      expect(resSafe.status, ScheduleConflictStatus.safe);
      expect(resSafe.label, 'Aman dari Jam Kuliah');
    });
  });

  group('Mitra Dashboard & Class Schedule Sheet Widget Tests', () {
    testWidgets('renders Atur Jadwal Kuliah button and conflict badge on order card', (tester) async {
      final mondayClass = const StudentScheduleModel(
        id: 'sc_1',
        userId: 'mock_mitra',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        courseName: 'Pemrograman Mobile',
      );
      final scheduleRepo = MockScheduleRepository([mondayClass]);
      final scheduleProvider = ScheduleProvider(repository: scheduleRepo);
      await scheduleProvider.loadStudentSchedules('mock_mitra');

      final mitraRepo = MitraRepositoryImpl();
      final mitraProvider = MitraProvider(repository: mitraRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ScheduleProvider>.value(value: scheduleProvider),
              ChangeNotifierProvider<MitraProvider>.value(value: mitraProvider),
            ],
            child: const MitraDashboardView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Atur Jadwal Kuliah'), findsWidgets);
      expect(find.byIcon(Icons.calendar_month), findsWidgets);

      expect(find.byType(CustomBadge), findsWidgets);
      expect(
        find.text('Aman dari Jam Kuliah'),
        findsWidgets,
      );
    });

    testWidgets('clicking Atur Jadwal Kuliah button opens ClassScheduleSheet', (tester) async {
      final mondayClass = const StudentScheduleModel(
        id: 'sc_1',
        userId: 'mock_mitra',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        courseName: 'Pemrograman Mobile',
      );
      final scheduleRepo = MockScheduleRepository([mondayClass]);
      final scheduleProvider = ScheduleProvider(repository: scheduleRepo);
      await scheduleProvider.loadStudentSchedules('mock_mitra');

      final mitraRepo = MitraRepositoryImpl();
      final mitraProvider = MitraProvider(repository: mitraRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ScheduleProvider>.value(value: scheduleProvider),
              ChangeNotifierProvider<MitraProvider>.value(value: mitraProvider),
            ],
            child: const MitraDashboardView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final button = find.widgetWithText(OutlinedButton, 'Atur Jadwal Kuliah');
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ClassScheduleSheet), findsOneWidget);
      expect(find.text('Jadwal Kuliah Mitra'), findsOneWidget);
      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.text('08:00 - 10:00'), findsOneWidget);
      expect(find.text('Tambah Jadwal Kuliah'), findsOneWidget);
    });

    testWidgets('ClassScheduleSheet validates end time and slot overlap', (tester) async {
      final initialSlot = const StudentScheduleModel(
        id: 'slot_existing',
        userId: 'mock_mitra',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        courseName: 'Pemrograman Web',
      );
      final scheduleRepo = MockScheduleRepository([initialSlot]);
      final scheduleProvider = ScheduleProvider(repository: scheduleRepo);
      await scheduleProvider.loadStudentSchedules('mock_mitra');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ScheduleProvider>.value(
              value: scheduleProvider,
              child: const ClassScheduleSheet(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Pemrograman Web'), findsOneWidget);
      expect(find.text('08:00 - 10:00'), findsOneWidget);

      await tester.tap(find.text('Tambah Jadwal Kuliah'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('save_slot_btn')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('save_slot_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Jadwal bentrok dengan jam kuliah yang sudah ada'), findsOneWidget);
    });

    testWidgets('ClassScheduleSheet allows deleting an existing slot', (tester) async {
      final initialSlot = const StudentScheduleModel(
        id: 'slot_to_delete',
        userId: 'mock_mitra',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        courseName: 'Kecerdasan Buatan',
      );
      final scheduleRepo = MockScheduleRepository([initialSlot]);
      final scheduleProvider = ScheduleProvider(repository: scheduleRepo);
      await scheduleProvider.loadStudentSchedules('mock_mitra');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ScheduleProvider>.value(
              value: scheduleProvider,
              child: const ClassScheduleSheet(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Kecerdasan Buatan'), findsOneWidget);

      final deleteBtn = find.byKey(const ValueKey('delete_slot_to_delete'));
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Kecerdasan Buatan'), findsNothing);
      expect(find.text('Jadwal kuliah berhasil dihapus'), findsOneWidget);
    });
  });
}
