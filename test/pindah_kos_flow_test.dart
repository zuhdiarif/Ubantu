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
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_form_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_in_progress_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_selesai_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_view.dart';
import 'package:ubantu/presentation/views/pindah_kos/pindah_kos_waiting_view.dart';

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
      id: 'order-123',
      requesterId: order.requesterId,
      category: order.category,
      status: order.status,
      locationOrigin: order.locationOrigin,
      locationDestination: order.locationDestination,
      scheduledAt: order.scheduledAt,
      itemDescription: order.itemDescription,
      barterType: order.barterType,
      barterDescription: order.barterDescription,
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
    return AppResult.failure('Not found');
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
    return AppResult.failure('Not found');
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
      id: 'rating-1',
      reviewerName: 'Pengguna UB',
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

  testWidgets('PindahKosView renders header, banner promo and features', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const PindahKosView()));
    await tester.pump();

    expect(find.text('Pindah Kos'), findsOneWidget);
    expect(find.text('Bantu bareng, ringankan beban! '), findsOneWidget);
    expect(find.text('Fitur lainnya'), findsOneWidget);
    expect(find.text('Bersih kos'), findsOneWidget);
    expect(find.text('Antar jemput'), findsOneWidget);
    expect(find.text('Meminta Bantuan'), findsOneWidget);
  });

  testWidgets('PindahKosFormView renders form elements and vehicle options', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const PindahKosFormView()));
    await tester.pump();

    expect(find.text('Detail Permintaan'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.text('Pilih Kendaraan'), findsOneWidget);
    expect(find.text('Motor'), findsOneWidget);
    expect(find.text('Mobil Box Kecil'), findsOneWidget);
    expect(find.text('Mobil Box Sedang'), findsOneWidget);
    expect(find.text('Mobil Box Besar'), findsOneWidget);
    expect(find.text('Deskripsi Barang'), findsOneWidget);
    expect(find.text('Pilih Tanggal dan Waktu'), findsOneWidget);
    expect(find.text('Meminta Bantuan'), findsOneWidget);
  });

  testWidgets('PindahKosWaitingView renders waiting indicator and tips', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const PindahKosWaitingView()));
    await tester.pump();

    expect(find.text('Menunggu bantuan datang'), findsOneWidget);
    expect(find.text('Tips'), findsOneWidget);
    expect(
      find.text(
        'Pastikan lokasi dan detail barang sudah benar agar proses lebih cepat.',
      ),
      findsOneWidget,
    );
    expect(find.text('Batalkan Permintaan'), findsOneWidget);
  });

  testWidgets('PindahKosInProgressView renders helper card and status steps', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const PindahKosInProgressView()));
    await tester.pump();

    expect(find.text('Bantuan Berlangsung'), findsOneWidget);
    expect(find.text('Nasya'), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);
    expect(find.text('Status Bantuan'), findsOneWidget);
    expect(find.text('Menyetujui bantuan'), findsOneWidget);
    expect(find.text('Menuju lokasi'), findsOneWidget);
    expect(find.text('Tiba di lokasi'), findsOneWidget);
    expect(find.text('Saling membantu'), findsOneWidget);
    expect(find.text('Bantuan selesai'), findsOneWidget);
  });

  testWidgets('PindahKosSelesaiView renders thank you, star rating and submit button', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const PindahKosSelesaiView()));
    await tester.pump();

    expect(find.text('Terimakasih!'), findsOneWidget);
    expect(
      find.text(
        'Bantuan telah selesai.\nSemoga pengalamanmu menyenangkan.',
      ),
      findsOneWidget,
    );
    expect(find.text('Berikan ulasan'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
  });

  testWidgets('DebugFloatingMenu toggles modal and displays routes', (tester) async {
    bool backgroundTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () => backgroundTapped = true,
                  child: const Text('Background Button'),
                ),
              ),
              const Positioned.fill(
                child: DebugFloatingMenu(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(DebugFloatingMenu), findsOneWidget);
    await tester.tap(find.text('Background Button'));
    await tester.pump();
    expect(backgroundTapped, isTrue);

    await tester.tap(find.byIcon(Icons.alt_route_rounded));
    await tester.pump();

    expect(find.text('Navigasi Debug'), findsOneWidget);
    expect(find.text('Alur Pindah Kos (5 Layar)'), findsOneWidget);
    expect(find.text('1. Promo & Beranda'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();

    expect(find.text('Navigasi Debug'), findsNothing);
  });
}
