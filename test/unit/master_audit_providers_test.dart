import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class _FakeAuditAuthRepository implements IAuthRepository {
  UserModel? user;
  bool deleteAccountCalled = false;
  AppResult<UserModel>? signUpResult;

  @override
  UserModel? getCurrentUser() => user;

  @override
  bool didSignUpReturnSession() => false;

  @override
  Future<AppResult<UserModel>> login(String email, String password) async =>
      user != null ? AppResult.success(user!) : AppResult.failure('Not found');

  @override
  Future<AppResult<UserModel>> signUp(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    return signUpResult ??
        AppResult.failure('Pendaftaran gagal. Periksa data Anda.');
  }

  @override
  Future<AppResult<UserModel>> signUpFallback(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    return AppResult.failure('Fallback failed');
  }

  @override
  Future<AppResult<bool>> sendOtp(String email) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> resendSignupOtp(String email) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> sendPasswordResetOtp(String email) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> verifyOtp(String email, String token) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> verifyRecoveryOtp(String email, String token) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> updatePassword(String newPassword) async => AppResult.success(true);

  @override
  Future<AppResult<UserModel>> updateProfile(UserModel user) async {
    this.user = user;
    return AppResult.success(user);
  }

  @override
  Future<AppResult<bool>> signInWithGoogle() async => AppResult.success(true);

  @override
  Future<void> logout() async {
    user = null;
  }

  @override
  Future<AppResult<bool>> deleteAccount() async {
    deleteAccountCalled = true;
    user = null;
    return AppResult.success(true);
  }
}

class _FakeAuditOrderRepository implements IServiceOrderRepository {
  final List<ServiceOrderModel> activeOrders = [];
  final List<ServiceOrderModel> orderHistory = [];

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async =>
      AppResult.success(activeOrders);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async =>
      AppResult.success(orderHistory);

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async {
    final created = order.copyWith(id: 'ord_${DateTime.now().millisecondsSinceEpoch}');
    orderHistory.insert(0, created);
    return AppResult.success(created);
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async =>
      AppResult.failure('Not implemented');

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(String orderId, MoveServiceStatus status) async =>
      AppResult.failure('Not implemented');

  @override
  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(String orderId, dynamic photo) async =>
      AppResult.failure('Not implemented');

  @override
  Future<AppResult<ServiceOrderModel>> confirmBarter(String orderId) async =>
      AppResult.failure('Not implemented');

  @override
  Stream<ServiceOrderModel?> watchOrder(String orderId) => Stream.value(null);
}

class _FakeAuditMitraRepository implements IMitraRepository {
  List<ServiceOrderModel> incoming = [];
  bool acceptCalled = false;
  String? lastAcceptedId;

  @override
  Future<AppResult<MitraProfileModel>> getMitraProfile() async =>
      AppResult.success(const MitraProfileModel(
        id: 'mitra_audit_1',
        userId: 'usr_audit_mitra',
        name: 'Mitra Audit',
        faculty: 'FILKOM UB',
        phone: '08123456789',
      ));

  @override
  Future<AppResult<List<ServiceOrderModel>>> getIncomingOrders() async =>
      AppResult.success(incoming);

  @override
  Future<AppResult<ServiceOrderModel?>> getActiveOrder() async =>
      AppResult.success(null);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getCompletedOrders() async =>
      AppResult.success([]);

  @override
  Future<AppResult<List<MitraEarningItemModel>>> getEarningsHistory() async =>
      AppResult.success([]);

  @override
  Future<AppResult<bool>> toggleOnlineStatus(bool isOnline) async =>
      AppResult.success(true);

  @override
  Future<AppResult<bool>> updateServiceCategories(List<ServiceCategory> categories) async =>
      AppResult.success(true);

  @override
  Future<AppResult<bool>> acceptOrder(String orderId) async {
    acceptCalled = true;
    lastAcceptedId = orderId;
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> declineOrder(String orderId) async =>
      AppResult.success(true);

  @override
  Future<AppResult<bool>> updateOrderStatus(String orderId, MoveServiceStatus status) async =>
      AppResult.success(true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Squad S1 Master Audit Tests', () {
    test('RegistrationProvider.signUp returns failed on validation/auth error and verifyOtp keeps ktmStatus unverified', () async {
      final fakeAuth = _FakeAuditAuthRepository();
      fakeAuth.signUpResult = AppResult.failure('Email sudah terdaftar', errorCode: 'user_already_exists');

      final regProvider = RegistrationProvider(repository: fakeAuth);
      regProvider.setAccountDetails(
        fullName: 'Budi Test',
        email: 'budi@student.ub.ac.id',
        phone: '081234567890',
        password: 'password123',
      );

      final nextStep = await regProvider.signUp();
      expect(nextStep, RegistrationNextStep.failed);
      expect(regProvider.signUpError, 'Email sudah terdaftar');
      expect(regProvider.ktmStatus, KtmVerificationStatus.unverified);

      final verifySuccess = await regProvider.verifyOtp('123456');
      expect(verifySuccess, isTrue);
      expect(regProvider.ktmStatus, KtmVerificationStatus.unverified);
    });

    test('ServiceOrderProvider.activeOrder does not return completed orders and submitOrder does not pollute public activeOrders', () async {
      final fakeOrderRepo = _FakeAuditOrderRepository();
      final provider = ServiceOrderProvider(repository: fakeOrderRepo);

      final publicWaitingOrder = ServiceOrderModel(
        id: 'ord_public_1',
        requesterId: 'other_user_id',
        requesterName: 'Other User',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Gerbang UB',
        locationDestination: 'Suhat',
        scheduledAt: DateTime.now(),
        itemDescription: 'Antar berkas skripsi',
        barterType: BarterType.jasa,
        barterDescription: 'Bantu ketik jurnal',
        createdAt: DateTime.now(),
      );

      await fakeOrderRepo.createOrder(publicWaitingOrder);
      await provider.loadActiveOrders();

      expect(provider.activeOrder, isNull);

      final completedUserOrder = ServiceOrderModel(
        id: 'ord_user_done',
        requesterId: 'my_user_id',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.completed,
        locationOrigin: 'Kos A',
        locationDestination: 'Kos B',
        scheduledAt: DateTime.now(),
        itemDescription: 'Pindahan kosan 2 koper',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi Goreng',
        createdAt: DateTime.now(),
      );

      fakeOrderRepo.orderHistory.clear();
      fakeOrderRepo.orderHistory.add(completedUserOrder);
      await provider.loadMyOrders('my_user_id');

      expect(provider.activeOrder, isNull);

      final newOrder = ServiceOrderModel(
        id: '',
        requesterId: 'my_user_id',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Fakultas Teknik',
        locationDestination: 'Asrama UB',
        scheduledAt: DateTime.now(),
        itemDescription: 'Tebengan pulang kuliah',
        barterType: BarterType.makanan,
        barterDescription: 'Roti O',
        createdAt: DateTime.now(),
      );

      final submitSuccess = await provider.submitOrder(order: newOrder);
      expect(submitSuccess, isTrue);
      expect(provider.activeOrder, isNotNull);
      expect(provider.activeOrder?.locationOrigin, 'Fakultas Teknik');
      expect(provider.activeOrders.any((o) => o.locationOrigin == 'Fakultas Teknik'), isFalse);
    });

    test('MitraProvider blocks male users from seeing or accepting isFemaleOnly orders', () async {
      final fakeAuth = _FakeAuditAuthRepository();
      fakeAuth.user = const UserModel(
        id: 'usr_male_mitra',
        fullName: 'Doni Driver',
        email: 'doni@ub.ac.id',
        phoneNumber: '08111111111',
        nim: '215150200111001',
        gender: UserGender.male,
      );

      ServiceLocator.resetForTesting(authRepository: fakeAuth);

      final fakeMitraRepo = _FakeAuditMitraRepository();
      fakeMitraRepo.incoming = [
        ServiceOrderModel(
          id: 'ord_regular',
          requesterId: 'usr_req_1',
          category: ServiceCategory.antarJemput,
          status: MoveServiceStatus.waiting,
          locationOrigin: 'Matos',
          locationDestination: 'UB',
          scheduledAt: DateTime.now(),
          itemDescription: 'Antar jemput biasa',
          barterType: BarterType.jasa,
          barterDescription: 'Bantu print',
          isFemaleOnly: false,
          createdAt: DateTime.now(),
        ),
        ServiceOrderModel(
          id: 'ord_female_only',
          requesterId: 'usr_req_2',
          category: ServiceCategory.antarJemput,
          status: MoveServiceStatus.waiting,
          locationOrigin: 'Kantin Filkom',
          locationDestination: 'Kos Melati',
          scheduledAt: DateTime.now(),
          itemDescription: 'Antar khusus mahasiswi',
          barterType: BarterType.makanan,
          barterDescription: 'Minuman boba',
          isFemaleOnly: true,
          createdAt: DateTime.now(),
        ),
      ];

      final provider = MitraProvider(repository: fakeMitraRepo);
      await provider.loadMitraData();

      expect(provider.incomingOrders.length, 1);
      expect(provider.incomingOrders.first.id, 'ord_regular');
      expect(provider.incomingOrders.any((o) => o.isFemaleOnly), isFalse);

      final acceptBlocked = await provider.acceptOrder('ord_female_only');
      expect(acceptBlocked, isFalse);
      expect(provider.errorMessage, contains('khusus perempuan'));
      expect(fakeMitraRepo.acceptCalled, isFalse);

      fakeAuth.user = const UserModel(
        id: 'usr_female_mitra',
        fullName: 'Siti Driver',
        email: 'siti@ub.ac.id',
        phoneNumber: '08222222222',
        nim: '215150200111002',
        gender: UserGender.female,
      );

      final femaleIncoming = provider.incomingOrders;
      expect(femaleIncoming.length, 2);
      expect(femaleIncoming.any((o) => o.id == 'ord_female_only'), isTrue);
    });

    test('AuthProvider.deleteAccount clears current user and session caches', () async {
      final fakeAuth = _FakeAuditAuthRepository();
      fakeAuth.user = const UserModel(
        id: 'usr_delete_me',
        fullName: 'Hapus Saya',
        email: 'hapus@ub.ac.id',
        phoneNumber: '08333333333',
        nim: '215150200111003',
      );

      final authProvider = AuthProvider(repository: fakeAuth);
      authProvider.updateUser(fakeAuth.user!);

      expect(authProvider.currentUser, isNotNull);

      final deleteResult = await authProvider.deleteAccount();
      expect(deleteResult.isSuccess, isTrue);
      expect(authProvider.currentUser, isNull);
      expect(fakeAuth.deleteAccountCalled, isTrue);
    });
  });
}
