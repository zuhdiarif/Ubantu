import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/debug_floating_menu.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/rating_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/rating_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_form_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_in_progress_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_selesai_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_view.dart';
import 'package:ubantu/presentation/views/antar_jemput/antar_jemput_waiting_view.dart';

class _MockServiceOrderRepository implements IServiceOrderRepository {
  final List<ServiceOrderModel> orders = [];

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async {
    return AppResult.success(orders);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async {
    return AppResult.success(orders);
  }

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async {
    final created = ServiceOrderModel(
      id: 'order-antar-123',
      requesterId: order.requesterId,
      category: order.category,
      status: order.status,
      locationOrigin: order.locationOrigin,
      locationDestination: order.locationDestination,
      scheduledAt: order.scheduledAt,
      itemDescription: order.itemDescription,
      barterType: order.barterType,
      barterDescription: order.barterDescription,
      barterPhotoUrl: order.barterPhotoUrl,
      vehicleType: order.vehicleType,
      weightKg: order.weightKg,
      createdAt: DateTime.now(),
    );
    orders.add(created);
    return AppResult.success(created);
  }

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final updated = orders[idx].copyWith(status: status);
      orders[idx] = updated;
      return AppResult.success(updated);
    }
    return AppResult.failure('Order not found');
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(
    String orderId,
    String helperId,
  ) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final updated = orders[idx].copyWith(
        helperId: helperId,
        status: MoveServiceStatus.accepted,
      );
      orders[idx] = updated;
      return AppResult.success(updated);
    }
    return AppResult.failure('Order not found');
  }
}

class _MockRatingRepository implements IRatingRepository {
  final List<RatingModel> ratings = [];

  @override
  Future<AppResult<List<RatingModel>>> getRatings(String targetUserId) async {
    return AppResult.success(ratings);
  }

  @override
  Future<AppResult<RatingModel>> addRating(
    String targetUserId,
    double score,
    String reviewText,
  ) async {
    final rating = RatingModel(
      id: 'rating-antar-1',
      reviewerName: 'Mahasiswa UB',
      score: score,
      reviewText: reviewText,
      createdAt: DateTime.now(),
    );
    ratings.add(rating);
    return AppResult.success(rating);
  }
}

void main() {
  late _MockServiceOrderRepository mockOrderRepo;
  late _MockRatingRepository mockRatingRepo;
  late ServiceOrderProvider serviceOrderProvider;
  late RatingProvider ratingProvider;

  setUp(() {
    mockOrderRepo = _MockServiceOrderRepository();
    mockRatingRepo = _MockRatingRepository();
    serviceOrderProvider = ServiceOrderProvider(repository: mockOrderRepo);
    ratingProvider = RatingProvider(repository: mockRatingRepo);
  });

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ServiceOrderProvider>.value(
          value: serviceOrderProvider,
        ),
        ChangeNotifierProvider<RatingProvider>.value(
          value: ratingProvider,
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('AntarJemputView renders header, banner promo, and features', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AntarJemputView()));
    await tester.pumpAndSettle();

    expect(find.text('Antar Jemput'), findsOneWidget);
    expect(find.text('Fitur lainnya'), findsOneWidget);
    expect(find.text('Pindah kos'), findsOneWidget);
    expect(find.text('Bersih kos'), findsOneWidget);
    expect(find.text('Keunggulan Antar Jemput UBantu'), findsOneWidget);
    expect(find.text('Meminta Bantuan'), findsOneWidget);
  });

  testWidgets('AntarJemputFormView renders form elements, mode, vehicle, and barter', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AntarJemputFormView()));
    await tester.pumpAndSettle();

    expect(find.text('Detail Permintaan'), findsOneWidget);
    expect(find.text('Kirim Barang'), findsOneWidget);
    expect(find.text('Tebengan / Orang'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.text('Pilihan Kendaraan'), findsOneWidget);
    expect(find.text('Motor'), findsOneWidget);
    expect(find.text('Mobil'), findsOneWidget);
    expect(find.text('Kategori Berat Barang'), findsOneWidget);
    expect(find.text('Pilih Tanggal dan Waktu'), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);
    expect(find.text('Barang'), findsWidgets);
    expect(find.text('Meminta Bantuan'), findsOneWidget);

    await tester.tap(find.text('Tebengan / Orang'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan Penjemputan'), findsOneWidget);
  });

  testWidgets('AntarJemputWaitingView renders waiting indicator and tips', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AntarJemputWaitingView()));
    await tester.pump();

    expect(find.text('Mencari Helper'), findsOneWidget);
    expect(find.text('Menghubungkan ke Helper...'), findsOneWidget);
    expect(find.text('Ringkasan Antar Jemput'), findsOneWidget);
    expect(find.text('Tips Keamanan Mahasiswa'), findsOneWidget);
    expect(find.text('Batalkan Permintaan'), findsOneWidget);
  });

  testWidgets('AntarJemputInProgressView renders helper card, steps, and SOS button', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AntarJemputInProgressView()));
    await tester.pump();

    expect(find.text('Bantuan Berlangsung'), findsOneWidget);
    expect(find.text('Ahmad Rizky'), findsOneWidget);
    expect(find.text('KTM UB'), findsOneWidget);
    expect(find.text('Rincian Pengantaran'), findsOneWidget);
    expect(find.text('Status Pengantaran'), findsOneWidget);
    expect(find.text('Tombol Darurat (SOS)'), findsOneWidget);
    expect(find.text('Konfirmasi Selesai & Beri Ulasan'), findsOneWidget);
  });

  testWidgets('AntarJemputSelesaiView renders thank you, rating, and submit button', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AntarJemputSelesaiView()));
    await tester.pumpAndSettle();

    expect(find.text('Bantuan Selesai'), findsOneWidget);
    expect(find.text('Pengantaran Selesai!'), findsOneWidget);
    expect(find.text('+10 Poin Barter UBantu'), findsOneWidget);
    expect(find.text('Beri Penilaian untuk Ahmad Rizky'), findsOneWidget);
    expect(find.text('Kirim Ulasan & Selesai'), findsOneWidget);
  });

  testWidgets('DebugFloatingMenu displays Alur Antar Jemput group', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DebugFloatingMenu(),
              ),
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
      find.text('Alur Antar Jemput (5 Layar)'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Alur Antar Jemput (5 Layar)'), findsOneWidget);
    expect(find.text('1. Promo Antar Jemput'), findsOneWidget);
  });
}
