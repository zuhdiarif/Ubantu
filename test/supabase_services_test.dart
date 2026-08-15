import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubantu/core/errors/app_exceptions.dart';
import 'package:ubantu/data/repositories/barter_repository_impl.dart';
import 'package:ubantu/data/repositories/profile_repository_impl.dart';
import 'package:ubantu/data/services/storage_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/usecases/get_barter_items_usecase.dart';
import 'package:ubantu/domain/usecases/get_profile_usecase.dart';
import 'package:ubantu/domain/usecases/update_profile_usecase.dart';
import 'package:ubantu/presentation/providers/barter_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Supabase Services & Extended MVVM Clean Architecture Tests', () {
    test('BarterItemModel serialization & deserialization', () {
      final model = const BarterItemModel(
        id: 'b10',
        title: 'Tukar Buku',
        description: 'Tukar komik dengan novel',
        type: BarterType.barang,
        iconAsset: 'book_rounded',
      );

      final json = model.toJson();
      expect(json['title'], 'Tukar Buku');
      expect(json['type'], 'barang');

      final fromJson = BarterItemModel.fromJson(json);
      expect(fromJson.id, 'b10');
      expect(fromJson.type, BarterType.barang);
    });

    test('NotificationModel serialization & deserialization', () {
      final now = DateTime.now();
      final notification = NotificationModel(
        id: 'n1',
        userId: 'u1',
        title: 'Pesanan Diterima',
        message: 'Tugas bersih kos telah diterima.',
        isRead: false,
        createdAt: now,
      );

      final json = notification.toJson();
      expect(json['title'], 'Pesanan Diterima');
      expect(json['is_read'], false);

      final fromJson = NotificationModel.fromJson(json);
      expect(fromJson.id, 'n1');
      expect(fromJson.isRead, false);
    });

    test('AppExceptions hierarchy & toString output', () {
      const netEx = NetworkException();
      expect(netEx.toString(), contains('Koneksi terputus'));

      const authEx = AuthException('Password salah', code: 'invalid_credentials');
      expect(authEx.toString(), 'Password salah');
      expect(authEx.code, 'invalid_credentials');

      const serverEx = ServerException('Internal Error 500');
      expect(serverEx.toString(), 'Internal Error 500');
    });

    test('ProfileRepositoryImpl & UseCases execution', () async {
      final repo = ProfileRepositoryImpl();
      final getUseCase = GetProfileUseCase(repo);
      final updateUseCase = UpdateProfileUseCase(repo);

      final getResult = await getUseCase.execute('usr_test');
      expect(getResult.isSuccess, true);
      expect(getResult.data?.id, 'usr_test');

      final userToUpdate = getResult.data!.copyWith(fullName: 'Updated Name');
      final updateResult = await updateUseCase.execute(userToUpdate);
      expect(updateResult.isSuccess, true);
      expect(updateResult.data?.fullName, 'Updated Name');
    });

    test('BarterRepositoryImpl & GetBarterItemsUseCase', () async {
      final repo = BarterRepositoryImpl();
      final useCase = GetBarterItemsUseCase(repo);

      final result = await useCase.execute();
      expect(result.isSuccess, true);
      expect(result.data?.length, 2);
    });

    test('BarterProvider state management loadBarterItems', () async {
      final provider = BarterProvider();
      expect(provider.items.isEmpty, true);

      await provider.loadBarterItems();
      expect(provider.items.length, 2);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('StorageService keys & onboarding status', () async {
      final service = StorageService();

      final keyUser = await service.getUserId();
      expect(keyUser, isNull);
    });
  });
}
