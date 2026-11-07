import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/repositories/service_order_repository.dart';
import 'package:ubantu/ui/aktivitas/service_order_provider.dart';

class _MockOrderRepo implements IServiceOrderRepository {
  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async {
    return AppResult.success(order.copyWith(id: 'created_id'));
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async {
    return AppResult.success([]);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async {
    return AppResult.success([]);
  }

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(String orderId, MoveServiceStatus status) async {
    throw UnimplementedError();
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async {
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

  @override
  Future<AppResult<ServiceOrderModel>> fetchOrderById(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> updateOrderNegotiation(
    String orderId, {
    required PaymentMethodType paymentMethod,
    required int price,
    String? barterDescription,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('SupabaseStorageService Integrity & 5MB Limit Tests', () {
    late Directory tempDir;
    late File largeFile;
    late File smallFile;
    late File nonExistentFile;
    late SupabaseStorageService storageService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('storage_test_');
      largeFile = File('${tempDir.path}/large_image.jpg');
      final raf = await largeFile.open(mode: FileMode.write);
      await raf.truncate(SupabaseStorageService.maxFileSizeBytes + 1024);
      await raf.close();

      smallFile = File('${tempDir.path}/small_image.jpg');
      await smallFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

      nonExistentFile = File('${tempDir.path}/non_existent_file.jpg');
      storageService = SupabaseStorageService();
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('maxFileSizeBytes is exactly 5 MB', () {
      expect(SupabaseStorageService.maxFileSizeBytes, 5 * 1024 * 1024);
    });

    test('rejects files larger than 5 MB for all upload operations', () async {
      final resKtm = await storageService.uploadKtmPhoto(largeFile, 'user_123');
      expect(resKtm.isFailure, isTrue);
      expect(resKtm.isSuccess, isFalse);
      expect(resKtm.errorMessage, contains('5 MB'));

      final resAvatar = await storageService.uploadAvatar(largeFile, 'user_123');
      expect(resAvatar.isFailure, isTrue);
      expect(resAvatar.isSuccess, isFalse);
      expect(resAvatar.errorMessage, contains('5 MB'));

      final resOrder = await storageService.uploadOrderPhoto(largeFile, 'order');
      expect(resOrder.isFailure, isTrue);
      expect(resOrder.isSuccess, isFalse);
      expect(resOrder.errorMessage, contains('5 MB'));

      final resChat = await storageService.uploadChatAttachment(largeFile, 'room_123');
      expect(resChat.isFailure, isTrue);
      expect(resChat.isSuccess, isFalse);
      expect(resChat.errorMessage, contains('5 MB'));

      final resProof = await storageService.uploadCompletionProof(largeFile, 'order_123');
      expect(resProof.isFailure, isTrue);
      expect(resProof.isSuccess, isFalse);
      expect(resProof.errorMessage, contains('5 MB'));
    });

    test('rejects non-existent files for all upload operations', () async {
      final resKtm = await storageService.uploadKtmPhoto(nonExistentFile, 'user_123');
      expect(resKtm.isFailure, isTrue);
      expect(resKtm.isSuccess, isFalse);
      expect(resKtm.errorMessage, contains('File tidak ditemukan'));

      final resAvatar = await storageService.uploadAvatar(nonExistentFile, 'user_123');
      expect(resAvatar.isFailure, isTrue);
      expect(resAvatar.isSuccess, isFalse);
      expect(resAvatar.errorMessage, contains('File tidak ditemukan'));

      final resOrder = await storageService.uploadOrderPhoto(nonExistentFile, 'order');
      expect(resOrder.isFailure, isTrue);
      expect(resOrder.isSuccess, isFalse);
      expect(resOrder.errorMessage, contains('File tidak ditemukan'));

      final resChat = await storageService.uploadChatAttachment(nonExistentFile, 'room_123');
      expect(resChat.isFailure, isTrue);
      expect(resChat.isSuccess, isFalse);
      expect(resChat.errorMessage, contains('File tidak ditemukan'));

      final resProof = await storageService.uploadCompletionProof(nonExistentFile, 'order_123');
      expect(resProof.isFailure, isTrue);
      expect(resProof.isSuccess, isFalse);
      expect(resProof.errorMessage, contains('File tidak ditemukan'));
    });

    test('returns failure and never returns local path when Supabase is unavailable', () async {
      expect(storageService.isAvailable, isFalse);

      final resKtm = await storageService.uploadKtmPhoto(smallFile, 'user_123');
      expect(resKtm.isFailure, isTrue);
      expect(resKtm.isSuccess, isFalse);
      expect(resKtm.data, isNot(smallFile.path));
      expect(resKtm.errorMessage, contains('Layanan penyimpanan cloud belum terhubung'));

      final resAvatar = await storageService.uploadAvatar(smallFile, 'user_123');
      expect(resAvatar.isFailure, isTrue);
      expect(resAvatar.isSuccess, isFalse);
      expect(resAvatar.data, isNot(smallFile.path));
      expect(resAvatar.errorMessage, contains('Layanan penyimpanan cloud belum terhubung'));

      final resOrder = await storageService.uploadOrderPhoto(smallFile, 'order');
      expect(resOrder.isFailure, isTrue);
      expect(resOrder.isSuccess, isFalse);
      expect(resOrder.data, isNot(smallFile.path));
      expect(resOrder.errorMessage, contains('Layanan penyimpanan cloud belum terhubung'));

      final resChat = await storageService.uploadChatAttachment(smallFile, 'room_123');
      expect(resChat.isFailure, isTrue);
      expect(resChat.isSuccess, isFalse);
      expect(resChat.data, isNot(smallFile.path));
      expect(resChat.errorMessage, contains('Layanan penyimpanan cloud belum terhubung'));

      final resProof = await storageService.uploadCompletionProof(smallFile, 'order_123');
      expect(resProof.isFailure, isTrue);
      expect(resProof.isSuccess, isFalse);
      expect(resProof.data, isNot(smallFile.path));
      expect(resProof.errorMessage, contains('Layanan penyimpanan cloud belum terhubung'));
    });

    test('ServiceOrderProvider.submitOrder aborts and shows error when photo upload fails', () async {
      final repo = _MockOrderRepo();
      final provider = ServiceOrderProvider(
        repository: repo,
        storageService: storageService,
      );

      final order = ServiceOrderModel(
        id: '',
        requesterId: 'user_1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin Kos',
        locationDestination: 'Destination Kos',
        scheduledAt: DateTime.now(),
        itemDescription: 'Items',
        barterType: BarterType.makanan,
        barterDescription: 'Food',
        createdAt: DateTime.now(),
      );

      final success = await provider.submitOrder(
        order: order,
        barterPhotoPath: largeFile.path,
      );

      expect(success, isFalse);
      expect(provider.isSubmitting, isFalse);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('5 MB'));
      expect(provider.myOrders.isEmpty, isTrue);
    });

    test('Database migration SQL file exists and contains complete schema specification', () {
      final migration = File('supabase/migrations/20261106000000_ubantu_full_schema.sql');
      expect(migration.existsSync(), isTrue);

      final sql = migration.readAsStringSync();
      expect(sql, contains('public.profiles'));
      expect(sql, contains('faculty'));
      expect(sql, contains('bio'));
      expect(sql, contains('is_online'));
      expect(sql, contains('mitra_categories'));
      expect(sql, contains('mitra_vehicle_type'));
      expect(sql, contains('mitra_vehicle_plate'));

      expect(sql, contains('public.service_orders'));
      expect(sql, contains('is_female_only'));
      expect(sql, contains('receiver_name'));
      expect(sql, contains('receiver_phone'));
      expect(sql, contains('completion_photo_url'));
      expect(sql, contains('completed_at'));
      expect(sql, contains('barter_confirmed_by_customer'));

      expect(sql, contains('public.tasks'));
      expect(sql, contains('public.sos_reports'));
      expect(sql, contains('public.chat_rooms'));
      expect(sql, contains('public.chat_messages'));
      expect(sql, contains('public.notifications'));
      expect(sql, contains('public.ratings'));
      expect(sql, contains('public.loyalty_transactions'));
      expect(sql, contains('public.mitra_schedules'));
      expect(sql, contains('public.mitra_declined_orders'));

      expect(sql, contains('5242880'));
      expect(sql, contains('ktm_photos'));
      expect(sql, contains('avatars'));
      expect(sql, contains('order_photos'));
      expect(sql, contains('chat_attachments'));
      expect(sql, contains('order-proofs'));
      expect(sql, contains('supabase_realtime'));
    });
  });
}
