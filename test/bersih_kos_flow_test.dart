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
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_form_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_in_progress_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_selesai_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_view.dart';
import 'package:ubantu/presentation/views/bersih_kos/bersih_kos_waiting_view.dart';

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
      id: 'order-bersih-123',
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
      id: 'rating-1',
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

  testWidgets('BersihKosView renders header, banner promo, and features', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const BersihKosView()));
    await tester.pump();

    expect(find.text('Bersih Kos'), findsOneWidget);
    expect(find.text('Bantu bareng, ringankan beban!'), findsOneWidget);
    expect(find.text('Fitur lainnya'), findsOneWidget);
    expect(find.text('Pindah kos'), findsOneWidget);
    expect(find.text('Antar jemput'), findsOneWidget);
    expect(find.text('Meminta Bantuan'), findsOneWidget);
  });

  testWidgets('BersihKosFormView renders form elements, locations, and barter options', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const BersihKosFormView()));
    await tester.pump();

    expect(find.text('Detail Permintaan'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.text('Detail Pekerjaan'), findsOneWidget);
    expect(find.text('Foto Kondisi Kos (opsional)'), findsOneWidget);
    expect(find.text('Pilih Tanggal dan Waktu'), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);
    expect(find.text('Barang'), findsOneWidget);
    expect(find.text('Meminta Bantuan'), findsOneWidget);
  });

  testWidgets('BersihKosWaitingView renders waiting indicator and tips', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const BersihKosWaitingView()));
    await tester.pump();

    expect(find.text('Menunggu bantuan datang'), findsOneWidget);
    expect(find.text('Tips'), findsOneWidget);
    expect(find.text('Simulasi Bantuan Diterima'), findsOneWidget);
    expect(find.text('Batalkan Permintaan'), findsOneWidget);
  });

  testWidgets('BersihKosInProgressView renders helper card, status steps, and SOS button', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const BersihKosInProgressView()));
    await tester.pump();

    expect(find.text('Bantuan Berlangsung'), findsOneWidget);
    expect(find.text('Zuhdi Arif'), findsOneWidget);
    expect(find.text('Status Bantuan'), findsOneWidget);
    expect(find.text('Sedang membersihkan kos'), findsOneWidget);
    expect(find.text('Tombol Darurat (SOS)'), findsOneWidget);
    expect(find.text('Selesaikan Bantuan'), findsOneWidget);
  });

  testWidgets('BersihKosSelesaiView renders thank you, rating, and submit button', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const BersihKosSelesaiView()));
    await tester.pump();

    expect(find.text('Terimakasih!'), findsOneWidget);
    expect(find.text('+10 Poin UBantu Ditambahkan!'), findsOneWidget);
    expect(find.text('Berikan ulasan untuk helper'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
  });

  testWidgets('DebugFloatingMenu displays Alur Bersih Kos group', (tester) async {
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

    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pump();

    expect(find.text('Alur Bersih Kos (5 Layar)'), findsOneWidget);
    expect(find.text('1. Promo Bersih Kos'), findsOneWidget);
  });
}
