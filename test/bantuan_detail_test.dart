import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/views/bantuan_detail_view.dart';

class MockOrderRepo implements IServiceOrderRepository {
  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async =>
      AppResult.success([]);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async =>
      AppResult.success([]);

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async =>
      AppResult.success(order);

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    return AppResult.success(
      ServiceOrderModel(
        id: orderId,
        requesterId: 'test',
        category: ServiceCategory.bersihKos,
        status: status,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Desc',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async {
    return AppResult.success(
      ServiceOrderModel(
        id: orderId,
        requesterId: 'test',
        helperId: helperId,
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.accepted,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Desc',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi',
        createdAt: DateTime.now(),
      ),
    );
  }
}

void main() {
  testWidgets('BantuanDetailView renders officer info, detail bantuan, and action buttons', (tester) async {
    final order = ServiceOrderModel(
      id: 'order-123',
      requesterId: 'user-1',
      category: ServiceCategory.bersihKos,
      status: MoveServiceStatus.inProgress,
      locationOrigin: 'Jl. Veteran, Malang',
      locationDestination: 'Stasiun Malang Kota Baru',
      scheduledAt: DateTime(2026, 7, 20, 9, 0),
      itemDescription: 'Bantu bersihkan kamar kos, alat sudah disiapkan',
      barterType: BarterType.makanan,
      barterDescription: 'Nasi Padang',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ServiceOrderProvider(repository: MockOrderRepo()),
          ),
        ],
        child: MaterialApp(
          home: BantuanDetailView(order: order),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Detail Petugas'), findsOneWidget);
    expect(find.text('Status: Aktif'), findsOneWidget);
    expect(find.text('Informasi Petugas'), findsOneWidget);
    expect(find.text('Nasya'), findsOneWidget);
    expect(find.text('4.8 (23)'), findsOneWidget);
    expect(find.text('Detail Bantuan'), findsOneWidget);
    expect(find.text('Bersih kos'), findsOneWidget);
    expect(find.text('Jl. Veteran, Malang'), findsOneWidget);
    expect(find.text('20 Juli 2026'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('PETA'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Bantuan SOS'), findsOneWidget);
  });
}
