import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/models/rating_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';
import 'package:ubantu/domain/repositories/rating_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/domain/usecases/complete_order_with_proof_usecase.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_selesai_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_selesai_view.dart';
import 'package:ubantu/presentation/views/mitra/mitra_active_order_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_selesai_view.dart';

class _FakeOrderRepository implements IServiceOrderRepository {
  bool shouldUploadFail = false;
  ServiceOrderModel? lastOrder;

  _FakeOrderRepository([this.lastOrder]);

  @override
  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(
    String orderId,
    File photo,
  ) async {
    if (shouldUploadFail) {
      return AppResult.failure('Gagal upload bukti foto');
    }
    final updated = (lastOrder ??
            ServiceOrderModel(
              id: orderId,
              requesterId: 'user-1',
              category: ServiceCategory.pindahKos,
              status: MoveServiceStatus.inProgress,
              locationOrigin: 'Origin',
              locationDestination: 'Destination',
              scheduledAt: DateTime.now(),
              itemDescription: 'Barang',
              barterType: BarterType.makanan,
              barterDescription: 'Nasi Padang',
              createdAt: DateTime.now(),
            ))
        .copyWith(
      status: MoveServiceStatus.completed,
      completionPhotoUrl: photo.path,
      completedAt: DateTime.now(),
    );
    lastOrder = updated;
    return AppResult.success(updated);
  }

  @override
  Future<AppResult<ServiceOrderModel>> confirmBarter(String orderId) async {
    final updated = (lastOrder ??
            ServiceOrderModel(
              id: orderId,
              requesterId: 'user-1',
              category: ServiceCategory.pindahKos,
              status: MoveServiceStatus.completed,
              locationOrigin: 'Origin',
              locationDestination: 'Destination',
              scheduledAt: DateTime.now(),
              itemDescription: 'Barang',
              barterType: BarterType.makanan,
              barterDescription: 'Nasi Padang',
              createdAt: DateTime.now(),
            ))
        .copyWith(barterConfirmedByCustomer: true);
    lastOrder = updated;
    return AppResult.success(updated);
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async =>
      AppResult.failure('noop');

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async =>
      AppResult.success(order);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async =>
      AppResult.success(lastOrder != null ? [lastOrder!] : []);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async =>
      AppResult.success(lastOrder != null ? [lastOrder!] : []);

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(String orderId, MoveServiceStatus status) async {
    if (lastOrder != null) {
      lastOrder = lastOrder!.copyWith(status: status);
      return AppResult.success(lastOrder!);
    }
    return AppResult.failure('Order not found');
  }

  @override
  Stream<ServiceOrderModel?> watchOrder(String orderId) =>
      Stream.value(lastOrder);
}

class _FakeNotificationRepository implements INotificationRepository {
  final List<String> notifications = [];

  @override
  void addNotification(String title, String message, {String type = 'general'}) {
    notifications.add('$title: $message');
  }

  @override
  List<NotificationModel> getNotifications() => [];

  @override
  int getUnreadCount() => 0;

  @override
  void markAllAsRead() {}
}

class _FakeMitraRepository implements IMitraRepository {
  MitraProfileModel profile = const MitraProfileModel(
    id: 'mitra_test_1',
    userId: 'usr_mitra_1',
    name: 'Ahmad Mitra',
    faculty: 'FILKOM UB',
    phone: '081234567890',
    isOnline: true,
    isKtmVerified: true,
    rating: 4.9,
    totalReviews: 20,
    totalOrdersCompleted: 10,
    acceptanceRate: 98.0,
    totalBarterPoints: 100,
  );

  ServiceOrderModel? activeOrder;
  final List<ServiceOrderModel> completedOrders = [];
  final List<MitraEarningItemModel> earningsHistory = [];

  _FakeMitraRepository(this.activeOrder);

  @override
  Future<AppResult<bool>> acceptOrder(String orderId) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> declineOrder(String orderId) async => AppResult.success(true);

  @override
  Future<AppResult<ServiceOrderModel?>> getActiveOrder() async => AppResult.success(activeOrder);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getCompletedOrders() async => AppResult.success(completedOrders);

  @override
  Future<AppResult<List<MitraEarningItemModel>>> getEarningsHistory() async => AppResult.success(earningsHistory);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getIncomingOrders() async => AppResult.success([]);

  @override
  Future<AppResult<MitraProfileModel>> getMitraProfile() async => AppResult.success(profile);

  @override
  Future<AppResult<bool>> toggleOnlineStatus(bool isOnline) async => AppResult.success(isOnline);

  @override
  Future<AppResult<bool>> updateOrderStatus(String orderId, MoveServiceStatus status) async {
    if (activeOrder != null) {
      if (status == MoveServiceStatus.completed) {
        activeOrder = null;
      } else {
        activeOrder = activeOrder!.copyWith(status: status);
      }
      return AppResult.success(true);
    }
    return AppResult.failure('Order not found');
  }

  @override
  Future<AppResult<bool>> updateServiceCategories(List<ServiceCategory> categories) async =>
      AppResult.success(true);
}

class _FakeRatingRepository implements IRatingRepository {
  @override
  Future<AppResult<List<RatingModel>>> getRatings(String targetUserId) async =>
      AppResult.success([]);

  @override
  Future<AppResult<RatingModel>> addRating(
    String targetUserId,
    double score,
    String reviewText,
  ) async {
    return AppResult.success(
      RatingModel(
        id: 'rating-1',
        reviewerName: 'Mahasiswa UB',
        score: score,
        reviewText: reviewText,
        createdAt: DateTime.now(),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceOrderModel Serialization Tests', () {
    test('serializes and deserializes completionPhotoUrl, completedAt, barterConfirmedByCustomer', () {
      final now = DateTime.now();
      final model = ServiceOrderModel(
        id: 'ord-test-proof',
        requesterId: 'req-1',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.completed,
        locationOrigin: 'Origin A',
        locationDestination: 'Destination B',
        scheduledAt: now,
        itemDescription: 'Helm SNI',
        barterType: BarterType.makanan,
        barterDescription: 'Es Teh Manis',
        completionPhotoUrl: 'test_proof.jpg',
        completedAt: now,
        barterConfirmedByCustomer: true,
        createdAt: now,
      );

      final json = model.toJson();
      expect(json['completion_photo_url'], 'test_proof.jpg');
      expect(json['completed_at'], now.toIso8601String());
      expect(json['barter_confirmed_by_customer'], true);

      final parsed = ServiceOrderModel.fromJson(json);
      expect(parsed.id, 'ord-test-proof');
      expect(parsed.completionPhotoUrl, 'test_proof.jpg');
      expect(parsed.completedAt?.toIso8601String(), now.toIso8601String());
      expect(parsed.barterConfirmedByCustomer, true);
    });

    test('copyWith properly updates proof fields', () {
      final now = DateTime.now();
      final original = ServiceOrderModel(
        id: 'ord-original',
        requesterId: 'req-1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: now,
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Makanan',
        createdAt: now,
      );

      final updated = original.copyWith(
        status: MoveServiceStatus.completed,
        completionPhotoUrl: 'proof-path.jpg',
        completedAt: now,
        barterConfirmedByCustomer: true,
      );

      expect(updated.status, MoveServiceStatus.completed);
      expect(updated.completionPhotoUrl, 'proof-path.jpg');
      expect(updated.completedAt, now);
      expect(updated.barterConfirmedByCustomer, true);
    });
  });

  group('CompleteOrderWithProofUseCase Unit Tests', () {
    test('upload ok -> status updated to completed, photo url and completedAt set', () async {
      final order = ServiceOrderModel(
        id: 'ord-101',
        requesterId: 'req-1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Kos Griya',
        locationDestination: 'Kos Griya',
        scheduledAt: DateTime.now(),
        itemDescription: 'Bersih kamar',
        barterType: BarterType.makanan,
        barterDescription: 'Geprek',
        createdAt: DateTime.now(),
      );

      final repo = _FakeOrderRepository(order);
      final useCase = CompleteOrderWithProofUseCase(repo);

      final photoFile = File('test_proof.jpg');
      final result = await useCase.execute('ord-101', photoFile);

      expect(result.isSuccess, isTrue);
      expect(result.data?.status, MoveServiceStatus.completed);
      expect(result.data?.completionPhotoUrl, 'test_proof.jpg');
      expect(result.data?.completedAt, isNotNull);
      expect(repo.lastOrder?.status, MoveServiceStatus.completed);
    });

    test('upload fails -> no status change, returns failure', () async {
      final order = ServiceOrderModel(
        id: 'ord-102',
        requesterId: 'req-1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Kos Griya',
        locationDestination: 'Kos Griya',
        scheduledAt: DateTime.now(),
        itemDescription: 'Bersih kamar',
        barterType: BarterType.makanan,
        barterDescription: 'Geprek',
        createdAt: DateTime.now(),
      );

      final repo = _FakeOrderRepository(order)..shouldUploadFail = true;
      final useCase = CompleteOrderWithProofUseCase(repo);

      final photoFile = File('test_proof.jpg');
      final result = await useCase.execute('ord-102', photoFile);

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Gagal upload bukti foto'));
      expect(repo.lastOrder?.status, MoveServiceStatus.inProgress);
    });
  });

  group('ServiceOrderProvider State Management Tests', () {
    test('completeOrderWithProof successfully completes order and notifies', () async {
      final order = ServiceOrderModel(
        id: 'ord-prov-1',
        requesterId: 'req-1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Barter',
        createdAt: DateTime.now(),
      );

      final repo = _FakeOrderRepository(order);
      final notificationRepo = _FakeNotificationRepository();
      final provider = ServiceOrderProvider(
        repository: repo,
        notificationRepository: notificationRepo,
      );

      await provider.loadMyOrders('req-1');
      expect(provider.activeOrder?.status, MoveServiceStatus.inProgress);

      final success = await provider.completeOrderWithProof('ord-prov-1', File('test_proof.jpg'));
      expect(success, isTrue);
      expect(provider.activeOrder?.status, MoveServiceStatus.completed);
      expect(provider.activeOrder?.completionPhotoUrl, 'test_proof.jpg');
      expect(notificationRepo.notifications.any((n) => n.contains('Pesanan Bantuan Selesai')), isTrue);
    });

    test('confirmBarter updates barterConfirmedByCustomer and notifies', () async {
      final order = ServiceOrderModel(
        id: 'ord-prov-2',
        requesterId: 'req-1',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.completed,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Barter',
        createdAt: DateTime.now(),
      );

      final repo = _FakeOrderRepository(order);
      final provider = ServiceOrderProvider(repository: repo);

      await provider.loadMyOrders('req-1');
      expect(provider.activeOrder?.barterConfirmedByCustomer, isFalse);

      final success = await provider.confirmBarter('ord-prov-2');
      expect(success, isTrue);
      expect(provider.activeOrder?.barterConfirmedByCustomer, isTrue);
    });
  });

  group('MitraProvider State Management Tests', () {
    test('completeActiveOrderWithProof moves activeOrder to completed and awards points', () async {
      final activeOrder = ServiceOrderModel(
        id: 'ord-mitra-proof-1',
        requesterId: 'req-1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Kos Griya UB',
        locationDestination: 'Kos Permata',
        scheduledAt: DateTime.now(),
        itemDescription: '3 Kardus',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi Padang',
        createdAt: DateTime.now(),
      );

      final mitraRepo = _FakeMitraRepository(activeOrder);
      final orderRepo = _FakeOrderRepository(activeOrder);
      final notificationRepo = _FakeNotificationRepository();
      final useCase = CompleteOrderWithProofUseCase(orderRepo);

      final provider = MitraProvider(
        repository: mitraRepo,
        notificationRepository: notificationRepo,
        completeOrderWithProofUseCase: useCase,
      );

      provider.setActiveOrder(activeOrder);
      expect(provider.activeOrder, isNotNull);

      mitraRepo.activeOrder = null;
      mitraRepo.completedOrders.add(activeOrder.copyWith(
        status: MoveServiceStatus.completed,
        completionPhotoUrl: 'test_proof.jpg',
      ));
      mitraRepo.earningsHistory.add(MitraEarningItemModel(
        id: 'earn-1',
        orderId: activeOrder.id,
        orderNumber: 'UB-1234',
        serviceTitle: 'Layanan Pindah Kos',
        date: DateTime.now(),
        barterDescription: 'Nasi Padang',
        pointsEarned: 10,
        customerName: 'Mahasiswa UB',
      ));
      mitraRepo.profile = mitraRepo.profile.copyWith(
        totalOrdersCompleted: mitraRepo.profile.totalOrdersCompleted + 1,
        totalBarterPoints: mitraRepo.profile.totalBarterPoints + 10,
      );
      final success = await provider.completeActiveOrderWithProof(File('test_proof.jpg'));
      expect(success, isTrue);
      expect(provider.activeOrder, isNull);
      expect(provider.completedOrders.length, 1);
      expect(provider.completedOrders.first.completionPhotoUrl, 'test_proof.jpg');
      expect(provider.earningsHistory.length, 1);
      expect(provider.profile?.totalOrdersCompleted, 11);
      expect(provider.profile?.totalBarterPoints, 110);
    });
  });

  group('MitraActiveOrderView Proof BottomSheet Widget Tests', () {
    testWidgets('Tapping Selesai opens bottomsheet and button is disabled without photo', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final activeOrder = ServiceOrderModel(
        id: 'ord-active-widget',
        requesterId: 'req-1',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi Kuning',
        createdAt: DateTime.now(),
      );

      final mitraRepo = _FakeMitraRepository(activeOrder);
      final orderRepo = _FakeOrderRepository(activeOrder);
      final provider = MitraProvider(
        repository: mitraRepo,
        completeOrderWithProofUseCase: CompleteOrderWithProofUseCase(orderRepo),
      );
      provider.setActiveOrder(activeOrder);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MitraProvider>.value(
            value: provider,
            child: const MitraActiveOrderView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selesaikan Bantuan & Terima Barter'), findsOneWidget);
      await tester.tap(find.text('Selesaikan Bantuan & Terima Barter'));
      await tester.pumpAndSettle();

      expect(find.text('Bukti Foto Selesai'), findsOneWidget);
      expect(find.text('Ambil Foto'), findsOneWidget);
      expect(find.text('Pilih dari Galeri'), findsOneWidget);

      final kirimBtn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Kirim & Selesaikan'),
      );
      expect(kirimBtn.onPressed, isNull);
    });
  });

  group('Customer Selesai Views Widget Tests', () {
    Widget buildSelesaiView({
      required Widget child,
      required ServiceOrderModel activeOrder,
    }) {
      final orderRepo = _FakeOrderRepository(activeOrder);
      final orderProvider = ServiceOrderProvider(repository: orderRepo);
      orderProvider.loadMyOrders(activeOrder.requesterId);
      final ratingProvider = RatingProvider(repository: _FakeRatingRepository());

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ServiceOrderProvider>.value(value: orderProvider),
          ChangeNotifierProvider<RatingProvider>.value(value: ratingProvider),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('AntarJemputSelesaiView renders proof photo card when photoUrl is present', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final activeOrder = ServiceOrderModel(
        id: 'ord-selesai-1',
        requesterId: 'req-1',
        helperId: 'helper-1',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.completed,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Item',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi Uduk',
        completionPhotoUrl: 'test_proof.jpg',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildSelesaiView(
          child: const AntarJemputSelesaiView(),
          activeOrder: activeOrder,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bukti Penyelesaian dari Mitra'), findsOneWidget);
      expect(find.text('Konfirmasi Penerimaan Imbalan / Barter'), findsOneWidget);
      expect(find.text('Sudah Diterima Mitra'), findsOneWidget);

      await tester.tap(find.text('Sudah Diterima Mitra'));
      await tester.pumpAndSettle();

      expect(find.text('Imbalan sudah dikonfirmasi telah diterima'), findsOneWidget);
    });

    testWidgets('BersihKosSelesaiView renders proof photo card and barter confirmation', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final activeOrder = ServiceOrderModel(
        id: 'ord-selesai-2',
        requesterId: 'req-1',
        helperId: 'helper-1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.completed,
        locationOrigin: 'Kos',
        locationDestination: 'Kos',
        scheduledAt: DateTime.now(),
        itemDescription: 'Kamar',
        barterType: BarterType.makanan,
        barterDescription: 'Sate Ayam',
        completionPhotoUrl: 'test_proof.jpg',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildSelesaiView(
          child: const BersihKosSelesaiView(),
          activeOrder: activeOrder,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bukti Penyelesaian dari Mitra'), findsOneWidget);
      expect(find.text('Konfirmasi Penerimaan Imbalan / Barter'), findsOneWidget);
      expect(find.text('Sudah Diterima Mitra'), findsOneWidget);
    });

    testWidgets('PindahKosSelesaiView renders proof photo card and barter confirmation', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final activeOrder = ServiceOrderModel(
        id: 'ord-selesai-3',
        requesterId: 'req-1',
        helperId: 'helper-1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.completed,
        locationOrigin: 'Kos Asal',
        locationDestination: 'Kos Baru',
        scheduledAt: DateTime.now(),
        itemDescription: 'Kasur & Meja',
        barterType: BarterType.makanan,
        barterDescription: 'Martabak',
        completionPhotoUrl: 'test_proof.jpg',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildSelesaiView(
          child: const PindahKosSelesaiView(),
          activeOrder: activeOrder,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bukti Penyelesaian dari Mitra'), findsOneWidget);
      expect(find.text('Konfirmasi Penerimaan Imbalan / Barter'), findsOneWidget);
      expect(find.text('Sudah Diterima Mitra'), findsOneWidget);
    });
  });
}
