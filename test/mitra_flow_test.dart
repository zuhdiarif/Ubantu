import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/debug_floating_menu.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/usecases/accept_mitra_order_usecase.dart';
import 'package:ubantu/domain/usecases/decline_mitra_order_usecase.dart';
import 'package:ubantu/domain/usecases/get_incoming_orders_usecase.dart';
import 'package:ubantu/domain/usecases/get_mitra_profile_usecase.dart';
import 'package:ubantu/domain/usecases/toggle_mitra_status_usecase.dart';
import 'package:ubantu/domain/usecases/update_mitra_order_status_usecase.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/views/mitra/mitra_active_order_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_category_registration_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_dashboard_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_earnings_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_performance_view.dart';

void main() {
  group('Mitra Domain Models Tests', () {
    test('MitraProfileModel json conversion and copyWith', () {
      const model = MitraProfileModel(
        id: 'mitra_1',
        userId: 'usr_1',
        name: 'Ahmad Fauzi',
        faculty: 'Filkom UB',
        phone: '081234567890',
        rating: 4.9,
        totalReviews: 38,
        totalOrdersCompleted: 42,
        acceptanceRate: 98.0,
        totalBarterPoints: 180,
      );

      final json = model.toJson();
      expect(json['id'], 'mitra_1');
      expect(json['name'], 'Ahmad Fauzi');
      expect(json['total_barter_points'], 180);

      final fromJson = MitraProfileModel.fromJson(json);
      expect(fromJson.id, 'mitra_1');
      expect(fromJson.name, 'Ahmad Fauzi');
      expect(fromJson.rating, 4.9);

      final updated = model.copyWith(isOnline: false, totalBarterPoints: 200);
      expect(updated.isOnline, false);
      expect(updated.totalBarterPoints, 200);
      expect(updated.name, 'Ahmad Fauzi');
    });

    test('MitraEarningItemModel json conversion and copyWith', () {
      final now = DateTime.now();
      final earning = MitraEarningItemModel(
        id: 'earn_1',
        orderId: 'ord_1',
        orderNumber: 'UB-ORD-1234',
        serviceTitle: 'Bantu Pindah Kos',
        date: now,
        barterDescription: 'Nasi Goreng Spesial',
        pointsEarned: 10,
        customerName: 'Bima Aditya',
      );

      final json = earning.toJson();
      expect(json['id'], 'earn_1');
      expect(json['order_number'], 'UB-ORD-1234');
      expect(json['points_earned'], 10);

      final fromJson = MitraEarningItemModel.fromJson(json);
      expect(fromJson.id, 'earn_1');
      expect(fromJson.barterDescription, 'Nasi Goreng Spesial');
      expect(fromJson.customerName, 'Bima Aditya');

      final updated = earning.copyWith(pointsEarned: 20);
      expect(updated.pointsEarned, 20);
      expect(updated.orderNumber, 'UB-ORD-1234');
    });
  });

  group('Mitra Repository & UseCases Tests', () {
    late MitraRepositoryImpl repository;

    setUp(() {
      repository = MitraRepositoryImpl();
    });

    test('MitraRepository profile and toggle status', () async {
      final profileResult = await repository.getMitraProfile();
      expect(profileResult.isSuccess, true);
      expect(profileResult.data?.name, contains('Ahmad Fauzi'));

      final toggleResult = await repository.toggleOnlineStatus(false);
      expect(toggleResult.isSuccess, true);
      expect(toggleResult.data, false);

      final updateCategory = await repository.updateServiceCategories([
        ServiceCategory.pindahKos,
      ]);
      expect(updateCategory.isSuccess, true);
    });

    test('MitraRepository orders lifecycle (get, accept, update, complete)',
        () async {
      final incoming = await repository.getIncomingOrders();
      expect(incoming.isSuccess, true);
      expect(incoming.data?.isNotEmpty, true);

      final firstOrder = incoming.data!.first;
      final acceptRes = await repository.acceptOrder(firstOrder.id);
      expect(acceptRes.isSuccess, true);

      final activeRes = await repository.getActiveOrder();
      expect(activeRes.isSuccess, true);
      expect(activeRes.data?.id, firstOrder.id);
      expect(activeRes.data?.status, MoveServiceStatus.accepted);

      final advanceRes = await repository.updateOrderStatus(
        firstOrder.id,
        MoveServiceStatus.inProgress,
      );
      expect(advanceRes.isSuccess, true);

      final activeAfterAdvance = await repository.getActiveOrder();
      expect(activeAfterAdvance.data?.status, MoveServiceStatus.inProgress);

      final completeRes = await repository.updateOrderStatus(
        firstOrder.id,
        MoveServiceStatus.completed,
      );
      expect(completeRes.isSuccess, true);

      final activeAfterComplete = await repository.getActiveOrder();
      expect(activeAfterComplete.data, isNull);

      final completedOrders = await repository.getCompletedOrders();
      expect(completedOrders.data?.length, 1);

      final earnings = await repository.getEarningsHistory();
      expect(earnings.data?.length, 4);
    });

    test('MitraRepository decline order', () async {
      final incoming = await repository.getIncomingOrders();
      final initialCount = incoming.data!.length;
      final firstId = incoming.data!.first.id;

      final declineRes = await repository.declineOrder(firstId);
      expect(declineRes.isSuccess, true);

      final afterDecline = await repository.getIncomingOrders();
      expect(afterDecline.data!.length, initialCount - 1);
    });

    test('UseCases execution tests', () async {
      final getProfileUC = GetMitraProfileUseCase(repository);
      final profile = await getProfileUC.execute();
      expect(profile.isSuccess, true);

      final toggleUC = ToggleMitraStatusUseCase(repository);
      final toggle = await toggleUC.execute(true);
      expect(toggle.isSuccess, true);

      final getIncomingUC = GetIncomingOrdersUseCase(repository);
      final orders = await getIncomingUC.execute();
      expect(orders.isSuccess, true);

      final acceptUC = AcceptMitraOrderUseCase(repository);
      final orderId = orders.data!.first.id;
      final accept = await acceptUC.execute(orderId);
      expect(accept.isSuccess, true);

      final updateStatusUC = UpdateMitraOrderStatusUseCase(repository);
      final update = await updateStatusUC.execute(
        orderId,
        MoveServiceStatus.inProgress,
      );
      expect(update.isSuccess, true);

      final declineUC = DeclineMitraOrderUseCase(repository);
      final decline = await declineUC.execute('non_existent_id');
      expect(decline.isSuccess, true);
    });
  });

  group('MitraProvider State Management Tests', () {
    late MitraRepositoryImpl repository;
    late MitraProvider provider;

    setUp(() {
      repository = MitraRepositoryImpl();
      provider = MitraProvider(repository: repository);
    });

    test('provider loads data and manages online toggle', () async {
      await provider.loadMitraData();
      expect(provider.profile, isNotNull);
      expect(provider.incomingOrders.isNotEmpty, true);
      expect(provider.earningsHistory.isNotEmpty, true);
      expect(provider.isOnline, true);

      await provider.toggleOnlineStatus(false);
      expect(provider.isOnline, false);

      await provider.updateCategories([ServiceCategory.bersihKos]);
      expect(provider.profile?.selectedCategories.length, 1);
    });

    test('provider order workflow (accept, advance, decline)', () async {
      await provider.loadMitraData();
      final targetId = provider.incomingOrders.first.id;

      final acceptSuccess = await provider.acceptOrder(targetId);
      expect(acceptSuccess, true);
      expect(provider.activeOrder?.id, targetId);
      expect(provider.activeOrder?.status, MoveServiceStatus.accepted);

      final advance1 = await provider.advanceActiveOrderStatus();
      expect(advance1, true);
      expect(provider.activeOrder?.status, MoveServiceStatus.inProgress);

      final advance2 = await provider.advanceActiveOrderStatus();
      expect(advance2, true);
      expect(provider.activeOrder, isNull);
      expect(provider.completedOrders.length, 1);
      expect(provider.profile?.totalBarterPoints, 190);
    });
  });

  group('Mitra Views Widget Tests', () {
    testWidgets('MitraDashboardView renders profile, toggle, stats, and orders',
        (tester) async {
      final repository = MitraRepositoryImpl();
      final provider = MitraProvider(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MitraProvider>.value(
            value: provider,
            child: const MitraDashboardView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dashboard Mitra UB'), findsOneWidget);
      expect(find.textContaining('Ahmad Fauzi'), findsOneWidget);
      expect(find.text('KTM OK'), findsOneWidget);
      expect(find.textContaining('Status: Online'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Poin Barter'), findsOneWidget);
      expect(find.text('Order Masuk'), findsOneWidget);
      expect(find.text('Kelola / Lanjutkan Bantuan'), findsWidgets);
      expect(find.text('Menu Fitur Mitra'), findsOneWidget);
      expect(find.text('Dompet & Rekap Barter'), findsOneWidget);
    });

    testWidgets('MitraActiveOrderView renders active order stepper and actions',
        (tester) async {
      final repository = MitraRepositoryImpl();
      final provider = MitraProvider(repository: repository);
      await provider.loadMitraData();
      await provider.acceptOrder(provider.incomingOrders.first.id);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MitraProvider>.value(
            value: provider,
            child: const MitraActiveOrderView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kelola Order Aktif'), findsOneWidget);
      expect(find.text('Tahapan Pelaksanaan'), findsOneWidget);
      expect(find.text('Pemesan Layanan'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Detail Tugas & Rute'), findsOneWidget);
      expect(find.text('Kesepakatan Imbalan Barter'), findsOneWidget);
      expect(find.text('Mulai Menuju Lokasi'), findsOneWidget);
    });

    testWidgets('MitraEarningsView renders wallet card, filters, and history',
        (tester) async {
      final repository = MitraRepositoryImpl();
      final provider = MitraProvider(repository: repository);
      await provider.loadMitraData();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MitraProvider>.value(
            value: provider,
            child: const MitraEarningsView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dompet & Rekap Barter'), findsOneWidget);
      expect(find.text('Saldo Poin Barter UB'), findsOneWidget);
      expect(find.text('180'), findsOneWidget);
      expect(find.text('Harian'), findsOneWidget);
      expect(find.text('Mingguan'), findsOneWidget);
      expect(find.text('Rincian Transaksi Barter'), findsOneWidget);
      expect(find.text('+10 Poin'), findsWidgets);
    });

    testWidgets('MitraPerformanceView renders rating hero, metrics, and reviews',
        (tester) async {
      final repository = MitraRepositoryImpl();
      final provider = MitraProvider(repository: repository);
      await provider.loadMitraData();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MitraProvider>.value(
            value: provider,
            child: const MitraPerformanceView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Performa & Ulasan Mitra'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('/ 5.0'), findsOneWidget);
      expect(find.text('5 Bintang'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Penyelesaian'), findsOneWidget);
      expect(find.text('Ulasan Mahasiswa UB'), findsOneWidget);
      expect(find.text('Bima Aditya'), findsOneWidget);
    });

    testWidgets(
        'MitraCategoryRegistrationView renders KTM banner, checkboxes, and vehicle',
        (tester) async {
      final repository = MitraRepositoryImpl();
      final provider = MitraProvider(repository: repository);
      await provider.loadMitraData();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MitraProvider>.value(
            value: provider,
            child: const MitraCategoryRegistrationView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kategori & Kendaraan Mitra'), findsOneWidget);
      expect(find.text('KTM Mahasiswa UB Terverifikasi'), findsOneWidget);
      expect(find.text('Pindah Kos Mahasiswa'), findsOneWidget);
      expect(find.text('Bersih Kamar Kos'), findsOneWidget);
      expect(find.text('Antar Jemput / Tebengan'), findsOneWidget);
      expect(find.text('Informasi Kendaraan'), findsOneWidget);
      expect(find.text('Sepeda Motor'), findsOneWidget);
      expect(find.text('Simpan Pengaturan'), findsOneWidget);
    });

    testWidgets('DebugFloatingMenu displays Fitur Mitra group with all routes',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                DebugFloatingMenu(),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.alt_route_rounded));
      await tester.pump();

      expect(find.text('Navigasi Debug'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Fitur Mitra (Helper Mode)'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Fitur Mitra (Helper Mode)'), findsOneWidget);
      expect(find.text('1. Dashboard Mitra UB'), findsOneWidget);
      expect(find.text('2. Kelola Order Aktif'), findsOneWidget);
      expect(find.text('3. Dompet & Rekap Barter'), findsOneWidget);
      expect(find.text('4. Performa & Ulasan'), findsOneWidget);
      expect(find.text('5. Kategori & Kendaraan'), findsOneWidget);
    });
  });
}
