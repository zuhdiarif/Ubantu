import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/views/bantuan_detail_view.dart';

class FakeServiceOrderRepositoryForViewsTest implements IServiceOrderRepository {
  List<ServiceOrderModel> myOrdersToReturn = [];

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async {
    return AppResult.success(myOrdersToReturn);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async {
    return AppResult.success([]);
  }

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async {
    return AppResult.success(order);
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async {
    throw UnimplementedError();
  }

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(String orderId, MoveServiceStatus status) async {
    throw UnimplementedError();
  }

  @override
  Stream<ServiceOrderModel?> watchOrder(String orderId) {
    return const Stream.empty();
  }

  @override
  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(String orderId, File photo) async {
    throw UnimplementedError();
  }

  @override
  Future<AppResult<ServiceOrderModel>> confirmBarter(String orderId) async {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AktivitasView Status Filtering and Badging Tests', () {
    test('filters active vs history orders correctly including cancelled and dibatalkan', () {
      final now = DateTime.now();
      final orders = [
        ServiceOrderModel(
          id: 'ord-1',
          requesterId: 'user-1',
          category: ServiceCategory.pindahKos,
          status: MoveServiceStatus.waiting,
          locationOrigin: 'Origin 1',
          locationDestination: 'Dest 1',
          scheduledAt: now,
          itemDescription: 'Desc 1',
          barterType: BarterType.makanan,
          barterDescription: 'Food 1',
          createdAt: now,
        ),
        ServiceOrderModel(
          id: 'ord-2',
          requesterId: 'user-1',
          category: ServiceCategory.bersihKos,
          status: MoveServiceStatus.accepted,
          locationOrigin: 'Origin 2',
          locationDestination: 'Dest 2',
          scheduledAt: now,
          itemDescription: 'Desc 2',
          barterType: BarterType.jasa,
          barterDescription: 'Barter 2',
          createdAt: now,
        ),
        ServiceOrderModel(
          id: 'ord-3',
          requesterId: 'user-1',
          category: ServiceCategory.antarJemput,
          status: MoveServiceStatus.inProgress,
          locationOrigin: 'Origin 3',
          locationDestination: 'Dest 3',
          scheduledAt: now,
          itemDescription: 'Desc 3',
          barterType: BarterType.barang,
          barterDescription: 'Item 3',
          createdAt: now,
        ),
        ServiceOrderModel(
          id: 'ord-4',
          requesterId: 'user-1',
          category: ServiceCategory.pindahKos,
          status: MoveServiceStatus.completed,
          locationOrigin: 'Origin 4',
          locationDestination: 'Dest 4',
          scheduledAt: now,
          itemDescription: 'Desc 4',
          barterType: BarterType.makanan,
          barterDescription: 'Food 4',
          createdAt: now,
        ),
        ServiceOrderModel(
          id: 'ord-5',
          requesterId: 'user-1',
          category: ServiceCategory.bersihKos,
          status: MoveServiceStatus.cancelled,
          locationOrigin: 'Origin 5',
          locationDestination: 'Dest 5',
          scheduledAt: now,
          itemDescription: 'Desc 5',
          barterType: BarterType.jasa,
          barterDescription: 'Barter 5',
          createdAt: now,
        ),
        ServiceOrderModel(
          id: 'ord-6',
          requesterId: 'user-1',
          category: ServiceCategory.antarJemput,
          status: MoveServiceStatus.dibatalkan,
          locationOrigin: 'Origin 6',
          locationDestination: 'Dest 6',
          scheduledAt: now,
          itemDescription: 'Desc 6',
          barterType: BarterType.lainnya,
          barterDescription: 'Other 6',
          createdAt: now,
        ),
      ];

      final activeOrders = orders
          .where((o) =>
              o.status != MoveServiceStatus.completed &&
              o.status != MoveServiceStatus.cancelled &&
              o.status != MoveServiceStatus.dibatalkan)
          .toList();

      final historyOrders = orders
          .where((o) =>
              o.status == MoveServiceStatus.completed ||
              o.status == MoveServiceStatus.cancelled ||
              o.status == MoveServiceStatus.dibatalkan)
          .toList();

      expect(activeOrders.length, equals(3));
      expect(activeOrders.map((o) => o.id), containsAll(['ord-1', 'ord-2', 'ord-3']));

      expect(historyOrders.length, equals(3));
      expect(historyOrders.map((o) => o.id), containsAll(['ord-4', 'ord-5', 'ord-6']));
    });

    test('cancelled and dibatalkan statuses map to Dibatalkan label and red badge', () {
      final cancelledStatus = MoveServiceStatus.cancelled;
      final dibatalkanStatus = MoveServiceStatus.dibatalkan;

      final isCancelled1 = cancelledStatus == MoveServiceStatus.cancelled ||
          cancelledStatus == MoveServiceStatus.dibatalkan;
      final statusText1 = isCancelled1 ? 'Dibatalkan' : cancelledStatus.label;
      expect(statusText1, equals('Dibatalkan'));
      expect(cancelledStatus.badgeBgColor, equals(const Color(0xFFFFEBEE)));
      expect(cancelledStatus.badgeTextColor, equals(const Color(0xFFC62828)));

      final isCancelled2 = dibatalkanStatus == MoveServiceStatus.cancelled ||
          dibatalkanStatus == MoveServiceStatus.dibatalkan;
      final statusText2 = isCancelled2 ? 'Dibatalkan' : dibatalkanStatus.label;
      expect(statusText2, equals('Dibatalkan'));
      expect(dibatalkanStatus.badgeBgColor, equals(const Color(0xFFFFEBEE)));
      expect(dibatalkanStatus.badgeTextColor, equals(const Color(0xFFC62828)));
    });
  });

  group('BantuanDetailView Dynamic Helper Widget Tests', () {
    late FakeServiceOrderRepositoryForViewsTest fakeRepo;
    late ServiceOrderProvider provider;

    setUp(() {
      fakeRepo = FakeServiceOrderRepositoryForViewsTest();
      provider = ServiceOrderProvider(repository: fakeRepo);
    });

    testWidgets('shows Menunggu Mitra UB and empty placeholder when order status is waiting', (tester) async {
      final waitingOrder = ServiceOrderModel(
        id: 'ord-wait-1',
        requesterId: 'user-req-1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Kos Veteran Malang',
        locationDestination: 'Kos Sigura-gura Malang',
        scheduledAt: DateTime(2026, 7, 20, 9, 0),
        itemDescription: 'Pindahan kos barang 2 kardus',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi padang',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ServiceOrderProvider>.value(
            value: provider,
            child: BantuanDetailView(order: waitingOrder),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Menunggu Mitra UB'), findsOneWidget);
      expect(find.text('Belum ada mitra yang mengambil pesanan'), findsOneWidget);
      expect(find.text('Mitra Penolong UB'), findsNothing);
      expect(find.text('4.8 (23)'), findsNothing);
      expect(find.text('Nasya'), findsNothing);
    });

    testWidgets('shows dynamic helper name and 5.0 rating when helper is assigned', (tester) async {
      final assignedOrder = ServiceOrderModel(
        id: 'ord-assign-1',
        requesterId: 'user-req-1',
        helperId: 'helper-user-42',
        helperName: 'Budi Santoso',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.accepted,
        locationOrigin: 'Kos Kertoraharjo',
        locationDestination: 'Kos Kertoraharjo',
        scheduledAt: DateTime(2026, 7, 21, 14, 0),
        itemDescription: 'Bersihkan kamar',
        barterType: BarterType.jasa,
        barterDescription: 'Bantu tugas',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ServiceOrderProvider>.value(
            value: provider,
            child: BantuanDetailView(order: assignedOrder),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Mitra Penolong UB'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('Menunggu Mitra UB'), findsNothing);
      expect(find.text('Belum ada mitra yang mengambil pesanan'), findsNothing);
      expect(find.text('Nasya'), findsNothing);
    });

    test('setActiveOrder updates provider activeOrder and notifies listeners', () {
      final sampleOrder = ServiceOrderModel(
        id: 'ord-sel-1',
        requesterId: 'user-req-1',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Gerbang UB',
        locationDestination: 'Stasiun Kota Baru',
        scheduledAt: DateTime.now(),
        itemDescription: 'Antar motor',
        barterType: BarterType.makanan,
        barterDescription: 'Roti bakar',
        createdAt: DateTime.now(),
      );

      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setActiveOrder(sampleOrder);

      expect(provider.activeOrder?.id, equals('ord-sel-1'));
      expect(notified, isTrue);

      provider.clearActiveOrder();
      expect(provider.activeOrder, isNull);
    });
  });
}
