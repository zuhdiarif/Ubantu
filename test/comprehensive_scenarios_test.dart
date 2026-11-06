import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/core/errors/app_exceptions.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/utils/app_validators.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/network_repository_impl.dart';
import 'package:ubantu/data/repositories/rating_repository_impl.dart';
import 'package:ubantu/data/repositories/schedule_repository_impl.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/data/services/storage_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/domain/models/sos_timeline_step_model.dart';
import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';
import 'package:ubantu/domain/repositories/loyalty_repository.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/domain/repositories/sos_repository.dart';
import 'package:ubantu/domain/usecases/female_only_tasks_usecase.dart';
import 'package:ubantu/domain/usecases/filter_tasks_usecase.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/connectivity_provider.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';
import 'package:ubantu/presentation/providers/schedule_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';
import 'package:ubantu/presentation/views/chat/chat_room_view.dart';
import 'package:ubantu/presentation/views/sos_finish_dialog_view.dart';

class _FakeServiceOrderRepository implements IServiceOrderRepository {
  final List<ServiceOrderModel> orders = [];

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async {
    return AppResult.success(
      orders.where((o) => o.status == MoveServiceStatus.waiting).toList(),
    );
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async {
    return AppResult.success(List.from(orders));
  }

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async {
    final created = ServiceOrderModel(
      id: 'ord-${orders.length + 1}',
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
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final updated = orders[idx].copyWith(
        status: MoveServiceStatus.accepted,
        helperId: helperId,
      );
      orders[idx] = updated;
      return AppResult.success(updated);
    }
    return AppResult.failure('Order not found');
  }
}

class _FakeMitraRepository implements IMitraRepository {
  MitraProfileModel _profile = const MitraProfileModel(
    id: 'mitra_test_1',
    userId: 'usr_mitra_1',
    name: 'Rizky Brawijaya',
    faculty: 'Fakultas Teknik UB',
    phone: '081234567890',
    isOnline: true,
    isKtmVerified: true,
    rating: 4.9,
    totalReviews: 24,
    totalOrdersCompleted: 30,
    acceptanceRate: 96.0,
    totalBarterPoints: 150,
    selectedCategories: [ServiceCategory.pindahKos],
  );

  final List<ServiceOrderModel> _incoming = [
    ServiceOrderModel(
      id: 'ord_inc_1',
      requesterId: 'usr_req_1',
      category: ServiceCategory.pindahKos,
      status: MoveServiceStatus.waiting,
      locationOrigin: 'Kos Suhat',
      locationDestination: 'Kos MT Haryono',
      scheduledAt: DateTime.now(),
      itemDescription: 'Angkut 2 kardus buku',
      barterType: BarterType.makanan,
      barterDescription: 'Nasi Bebek Sinjay',
      createdAt: DateTime.now(),
    ),
  ];

  ServiceOrderModel? _active;
  final List<ServiceOrderModel> _completed = [];
  final List<MitraEarningItemModel> _earnings = [];

  @override
  Future<AppResult<MitraProfileModel>> getMitraProfile() async {
    return AppResult.success(_profile);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getIncomingOrders() async {
    return AppResult.success(List.from(_incoming));
  }

  @override
  Future<AppResult<ServiceOrderModel?>> getActiveOrder() async {
    return AppResult.success(_active);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getCompletedOrders() async {
    return AppResult.success(List.from(_completed));
  }

  @override
  Future<AppResult<List<MitraEarningItemModel>>> getEarningsHistory() async {
    return AppResult.success(List.from(_earnings));
  }

  @override
  Future<AppResult<bool>> toggleOnlineStatus(bool isOnline) async {
    _profile = _profile.copyWith(isOnline: isOnline);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> updateServiceCategories(List<ServiceCategory> categories) async {
    _profile = _profile.copyWith(selectedCategories: categories);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> acceptOrder(String orderId) async {
    final idx = _incoming.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _active = _incoming.removeAt(idx).copyWith(
        status: MoveServiceStatus.accepted,
        helperId: _profile.userId,
      );
      return AppResult.success(true);
    }
    return AppResult.failure('Order not found');
  }

  @override
  Future<AppResult<bool>> declineOrder(String orderId) async {
    _incoming.removeWhere((o) => o.id == orderId);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> updateOrderStatus(String orderId, MoveServiceStatus status) async {
    if (_active != null && _active!.id == orderId) {
      _active = _active!.copyWith(status: status);
      if (status == MoveServiceStatus.completed) {
        _completed.add(_active!);
        _earnings.add(MitraEarningItemModel(
          id: 'earn_${DateTime.now().millisecondsSinceEpoch}',
          orderId: _active!.id,
          orderNumber: 'UB-ORD-TEST',
          serviceTitle: _active!.itemDescription,
          date: DateTime.now(),
          barterDescription: _active!.barterDescription,
          pointsEarned: 10,
          customerName: 'Pemesan UB',
        ));
        _profile = _profile.copyWith(
          totalOrdersCompleted: _profile.totalOrdersCompleted + 1,
          totalBarterPoints: _profile.totalBarterPoints + 10,
        );
        _active = null;
      }
      return AppResult.success(true);
    }
    return AppResult.failure('Active order not matched');
  }
}

class _FakeChatRepository implements IChatRepository {
  final List<ChatRoomModel> _rooms = [
    ChatRoomModel(
      id: 'room_scen_1',
      orderId: 'ord_scen_1',
      orderNumber: '#UB2026111',
      serviceTitle: 'Antar Berkas',
      serviceStatus: 'SEDANG BERLANGSUNG',
      otherUserName: 'Farhan UB',
      otherUserFaculty: 'Fakultas Pertanian UB',
      lastMessage: 'Halo kak, barang sudah siap',
      lastMessageTime: DateTime.now(),
      unreadCount: 2,
      isActive: true,
      itemSummary: 'Berkas Skripsi',
      pickupLocation: 'Gedung Rektorat UB',
      destinationLocation: 'Kost Kerto',
      totalPrice: 'Barter Makanan',
    ),
  ];

  final Map<String, List<ChatMessageModel>> _messages = {
    'room_scen_1': [
      ChatMessageModel(
        id: 'msg_1',
        roomId: 'room_scen_1',
        senderId: 'other_user',
        senderName: 'Farhan UB',
        message: 'Halo kak, barang sudah siap',
        isMe: false,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  };

  @override
  Future<AppResult<List<ChatRoomModel>>> getChatRooms() async {
    return AppResult.success(List.from(_rooms));
  }

  @override
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId) async {
    final room = _rooms.where((r) => r.orderId == orderId || r.id == orderId).firstOrNull;
    return AppResult.success(room);
  }

  @override
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId) async {
    return AppResult.success(List.from(_messages[roomId] ?? []));
  }

  @override
  Future<AppResult<ChatMessageModel>> sendMessage(
    String roomId,
    String message, {
    String? attachmentUrl,
  }) async {
    final msg = ChatMessageModel(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'usr_me',
      senderName: 'Saya',
      message: message,
      isMe: true,
      isRead: true,
      createdAt: DateTime.now(),
      attachmentUrl: attachmentUrl,
    );
    _messages.putIfAbsent(roomId, () => []).add(msg);
    final idx = _rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      _rooms[idx] = _rooms[idx].copyWith(
        lastMessage: message,
        lastMessageTime: msg.createdAt,
      );
    }
    return AppResult.success(msg);
  }

  @override
  Future<AppResult<bool>> markMessagesAsRead(String roomId) async {
    final idx = _rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      _rooms[idx] = _rooms[idx].copyWith(unreadCount: 0);
    }
    final msgs = _messages[roomId];
    if (msgs != null) {
      for (int i = 0; i < msgs.length; i++) {
        msgs[i] = msgs[i].copyWith(isRead: true);
      }
    }
    return AppResult.success(true);
  }
}

class _FakeSosRepository implements ISosRepository {
  SosStatus currentStatus = SosStatus.received;
  SosReportModel? lastReport;

  @override
  Future<AppResult<SosReportModel>> submitSosReport(String issueType) async {
    final report = SosReportModel(
      id: 'sos_123',
      userId: 'usr_tester',
      issueType: issueType,
      status: SosStatus.received,
      createdAt: DateTime.now(),
    );
    lastReport = report;
    currentStatus = SosStatus.received;
    return AppResult.success(report);
  }

  @override
  Future<void> updateSosStatus(SosStatus status) async {
    currentStatus = status;
  }
}

class _FakeLoyaltyRepository implements ILoyaltyRepository {
  RewardPointsModel points = const RewardPointsModel(
    userId: 'usr_tester',
    totalPoints: 120,
    availableVouchers: 1,
    claimedVoucherCodes: ['GRATIS1X_INIT'],
  );

  @override
  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId) async {
    return AppResult.success(points);
  }

  @override
  Future<AppResult<RewardPointsModel>> claimVoucher(String userId, int pointsRequired) async {
    if (points.totalPoints < pointsRequired) {
      return AppResult.failure('Poin kamu tidak mencukupi untuk klaim voucher ini');
    }
    points = RewardPointsModel(
      userId: userId,
      totalPoints: points.totalPoints - pointsRequired,
      availableVouchers: points.availableVouchers + 1,
      claimedVoucherCodes: [
        ...points.claimedVoucherCodes,
        'GRATIS1X_${DateTime.now().millisecondsSinceEpoch}',
      ],
    );
    return AppResult.success(points);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Comprehensive Scenario Tests Suite', () {
    group('Skenario A: Siklus Autentikasi & Verifikasi Mahasiswa', () {
      test('Validasi email non-UB vs email UB dan format regex', () {
        expect(AppValidators.validateEmail(''), 'Email tidak boleh kosong');
        expect(AppValidators.validateEmail('invalid-email-format'), 'Format email tidak valid');
        expect(AppValidators.validateEmail('user@gmail.com'), isNull);

        expect(AppConfig.isUbEmail('user@gmail.com'), false);
        expect(AppConfig.isUbEmail('tester@student.ub.ac.id'), true);
        expect(AppConfig.isUbEmail('bima.aditya@student.ub.ac.id'), true);
        expect(AppConfig.isUbEmail('user@yahoo.com'), false);
      });

      test('Validasi format NIM mahasiswa UB', () {
        expect(AppValidators.validateNim(null), 'NIM tidak boleh kosong');
        expect(AppValidators.validateNim(''), 'NIM tidak boleh kosong');
        expect(AppValidators.validateNim('12345'), 'NIM mahasiswa tidak valid');
        expect(AppValidators.validateNim('245150200111001'), isNull);
        expect(AppValidators.validateNim('215150200111045'), isNull);
      });

      test('Alur verifikasi KTM dan mutasi status verifikasi', () {
        final regProvider = RegistrationProvider();
        expect(regProvider.ktmStatus, KtmVerificationStatus.unverified);

        regProvider.setKtmData(
          nim: '245150200111001',
          photoPath: '/storage/emulated/0/Download/ktm_brawijaya.jpg',
        );

        expect(regProvider.nim, '245150200111001');
        expect(regProvider.ktmPhotoPath, '/storage/emulated/0/Download/ktm_brawijaya.jpg');
        expect(regProvider.ktmStatus, KtmVerificationStatus.pending);

        regProvider.updateKtmStatus(KtmVerificationStatus.verified);
        expect(regProvider.ktmStatus, KtmVerificationStatus.verified);
      });

      test('Alur OTP 6-digit verifikasi berhasil vs gagal', () async {
        final regProvider = RegistrationProvider();
        regProvider.setAccountDetails(
          fullName: 'Bima Satria',
          email: 'bima@student.ub.ac.id',
          phone: '081234567890',
          password: 'Password123',
        );

        final sendSuccess = await regProvider.sendOtp();
        expect(sendSuccess, true);

        final failResult = await regProvider.verifyOtp('12');
        expect(failResult, false);
        expect(regProvider.otpError, isNotNull);

        final okResult = await regProvider.verifyOtp('123456');
        expect(okResult, true);
      });

      test('Fallback login dan perutean registrasi berdasarkan domain email', () async {
        final authRepo = AuthRepositoryImpl();
        final loginRes = await authRepo.login('bima@student.ub.ac.id', 'Password123');
        expect(loginRes.isSuccess, true);
        expect(loginRes.data, isNotNull);
        expect(loginRes.data?.email, 'bima@student.ub.ac.id');

        final regProviderUb = RegistrationProvider(repository: authRepo);
        regProviderUb.setAccountDetails(
          fullName: 'Mahasiswa UB',
          email: 'bima@student.ub.ac.id',
          phone: '081234567890',
          password: 'Password123',
        );
        expect(regProviderUb.isUbEmail, true);
        final nextUb = await regProviderUb.signUp();
        expect(nextUb, RegistrationNextStep.ktmVerification);

        final regProviderNonUb = RegistrationProvider(repository: authRepo);
        regProviderNonUb.setAccountDetails(
          fullName: 'Umum Tester',
          email: 'umum@gmail.com',
          phone: '081234567890',
          password: 'Password123',
        );
        expect(regProviderNonUb.isUbEmail, false);
        final nextNonUb = await regProviderNonUb.signUp();
        expect(nextNonUb, RegistrationNextStep.otpVerification);
      });
    });

    group('Skenario B: Siklus Layanan Pindah Kos, Bersih Kos & Antar Jemput', () {
      test('Validasi form, berat muatan, armada, dan barter Pindah Kos', () async {
        final repo = _FakeServiceOrderRepository();
        final provider = ServiceOrderProvider(repository: repo);

        final scheduledDate = DateTime.now().add(const Duration(days: 2));
        final created = await provider.createPindahKosOrder(
          locationOrigin: 'Kos Griya Brawijaya, Jl. MT Haryono',
          locationDestination: 'Kos Asri, Jl. Sigura-gura',
          vehicleType: VehicleType.mobil,
          weightKg: 45.5,
          itemDescription: 'Kasur lipat, lemari plastik, 3 kardus',
          scheduledAt: scheduledDate,
          barterType: BarterType.makanan,
          barterDescription: 'Nasi Bebek Sinjay + Es Jeruk',
          photoUrl: 'https://ubantu.storage/barter_1.jpg',
        );

        expect(created, true);
        expect(provider.myOrders.length, 1);
        final order = provider.myOrders.first;
        expect(order.category, ServiceCategory.pindahKos);
        expect(order.vehicleType, VehicleType.mobil);
        expect(order.weightKg, 45.5);
        expect(order.barterType, BarterType.makanan);
        expect(order.status, MoveServiceStatus.waiting);
      });

      test('Pembuatan pesanan Bersih Kos dengan spesifikasi pekerjaan', () async {
        final repo = _FakeServiceOrderRepository();
        final provider = ServiceOrderProvider(repository: repo);

        final scheduledDate = DateTime.now().add(const Duration(hours: 5));
        final created = await provider.createBersihKosOrder(
          locationKos: 'Kos Putri Melati, Jl. Kerto Raharjo',
          jobDetail: 'Sapu, pel, dan bersihkan kamar mandi 3x4 meter',
          scheduledAt: scheduledDate,
          barterType: BarterType.barang,
          barterDescription: 'Kipas angin meja mini',
        );

        expect(created, true);
        final order = provider.myOrders.first;
        expect(order.category, ServiceCategory.bersihKos);
        expect(order.itemDescription.contains('Sapu, pel'), true);
        expect(order.barterType, BarterType.barang);
      });

      test('Pembuatan pesanan Antar Jemput dengan armada motor', () async {
        final repo = _FakeServiceOrderRepository();
        final provider = ServiceOrderProvider(repository: repo);

        final scheduledDate = DateTime.now().add(const Duration(hours: 3));
        final created = await provider.createAntarJemputOrder(
          locationOrigin: 'Gerbang Veteran UB',
          locationDestination: 'Stasiun Kota Baru Malang',
          itemDescription: 'Tebengan motor bawa 1 ransel dan 1 tas jinjing',
          scheduledAt: scheduledDate,
          barterType: BarterType.jasa,
          barterDescription: 'Bantu install ulang laptop Windows',
          vehicleType: VehicleType.motor,
          weightKg: 10.0,
        );

        expect(created, true);
        final order = provider.myOrders.first;
        expect(order.category, ServiceCategory.antarJemput);
        expect(order.vehicleType, VehicleType.motor);
        expect(order.barterType, BarterType.jasa);
      });

      test('Handling pembatalan order (MoveServiceStatus.cancelled)', () async {
        final repo = _FakeServiceOrderRepository();
        final provider = ServiceOrderProvider(repository: repo);

        await provider.createPindahKosOrder(
          locationOrigin: 'Kos Lama',
          locationDestination: 'Kos Baru',
          vehicleType: VehicleType.motor,
          weightKg: 15.0,
          itemDescription: 'Kardus pakaian',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          barterType: BarterType.lainnya,
          barterDescription: 'Poin Barter',
        );

        final orderId = provider.myOrders.first.id;
        final cancelSuccess = await provider.updateStatus(orderId, MoveServiceStatus.cancelled);
        expect(cancelSuccess, true);

        final updatedOrder = provider.getOrderById(orderId);
        expect(updatedOrder?.status, MoveServiceStatus.cancelled);
      });
    });

    group('Skenario C: Subsistem Mitra (Penyedia Bantuan)', () {
      test('Registrasi multi-kategori layanan mitra', () async {
        final repo = _FakeMitraRepository();
        final provider = MitraProvider(repository: repo);
        await provider.loadMitraData();

        expect(provider.profile?.selectedCategories.length, 1);

        await provider.updateCategories([
          ServiceCategory.pindahKos,
          ServiceCategory.bersihKos,
          ServiceCategory.antarJemput,
        ]);

        expect(provider.profile?.selectedCategories.length, 3);
        expect(provider.profile?.selectedCategories.contains(ServiceCategory.bersihKos), true);
      });

      test('Toggle status online/offline mitra', () async {
        final repo = _FakeMitraRepository();
        final provider = MitraProvider(repository: repo);
        await provider.loadMitraData();
        expect(provider.isOnline, true);

        await provider.toggleOnlineStatus(false);
        expect(provider.isOnline, false);

        await provider.toggleOnlineStatus(true);
        expect(provider.isOnline, true);
      });

      test('Penerimaan dan penolakan pesanan masuk oleh mitra', () async {
        final repo = _FakeMitraRepository();
        final provider = MitraProvider(repository: repo);
        await provider.loadMitraData();

        expect(provider.incomingOrders.length, 1);
        final incomingId = provider.incomingOrders.first.id;

        final acceptOk = await provider.acceptOrder(incomingId);
        expect(acceptOk, true);
        expect(provider.activeOrder, isNotNull);
        expect(provider.activeOrder?.id, incomingId);
        expect(provider.incomingOrders.isEmpty, true);

        final declineResult = await provider.declineOrder('non_existing_id');
        expect(declineResult, true);
      });

      test('Siklus 5 tahapan pelaksanaan pesanan mitra (accepted -> inProgress -> completed)', () async {
        final repo = _FakeMitraRepository();
        final provider = MitraProvider(repository: repo);
        await provider.loadMitraData();
        await provider.acceptOrder(provider.incomingOrders.first.id);

        expect(provider.activeOrder?.status, MoveServiceStatus.accepted);

        final step1 = await provider.advanceActiveOrderStatus();
        expect(step1, true);
        expect(provider.activeOrder?.status, MoveServiceStatus.inProgress);

        final step2 = await provider.advanceActiveOrderStatus();
        expect(step2, true);
        expect(provider.activeOrder, isNull);
        expect(provider.completedOrders.length, 1);
      });

      test('Kalkulasi dompet barter & metrik performa mitra', () async {
        final repo = _FakeMitraRepository();
        final provider = MitraProvider(repository: repo);
        await provider.loadMitraData();

        final initialPoints = provider.profile?.totalBarterPoints ?? 0;
        final initialOrders = provider.profile?.totalOrdersCompleted ?? 0;

        await provider.acceptOrder(provider.incomingOrders.first.id);
        await provider.advanceActiveOrderStatus();
        await provider.advanceActiveOrderStatus();

        expect(provider.profile?.totalBarterPoints, initialPoints + 10);
        expect(provider.profile?.totalOrdersCompleted, initialOrders + 1);
        expect(provider.earningsHistory.isNotEmpty, true);
        expect(provider.profile!.acceptanceRate >= 90.0, true);
      });
    });

    group('Skenario D: Subsistem Chat & Komunikasi', () {
      test('Pengiriman pesan teks real-time di room chat', () async {
        final repo = _FakeChatRepository();
        final provider = ChatProvider(repository: repo);
        await provider.loadRooms();

        expect(provider.rooms.isNotEmpty, true);
        final room = provider.rooms.first;
        provider.setActiveRoom(room);

        final sent = await provider.sendMessage(room.id, 'Halo Farhan, saya sudah tiba di lobi');
        expect(sent, true);
        expect(provider.activeMessages.any((m) => m.message.contains('lobi')), true);
        expect(provider.rooms.first.lastMessage.contains('lobi'), true);
      });

      test('Penanganan pengiriman pesan dengan lampiran URL media', () async {
        final repo = _FakeChatRepository();
        final provider = ChatProvider(repository: repo);
        await provider.loadRooms();
        final room = provider.rooms.first;

        final sent = await provider.sendMessage(
          room.id,
          'Berikut foto lokasi jemput',
          attachmentUrl: 'https://ubantu.storage/lokasi_jemput.jpg',
        );

        expect(sent, true);
        final lastMsg = provider.activeMessages.last;
        expect(lastMsg.attachmentUrl, 'https://ubantu.storage/lokasi_jemput.jpg');
        expect(lastMsg.message, 'Berikut foto lokasi jemput');
      });

      test('Sinkronisasi unread count dan mutasi mark as read', () async {
        final repo = _FakeChatRepository();
        final provider = ChatProvider(repository: repo);
        await provider.loadRooms();

        expect(provider.totalUnreadCount, 2);
        expect(provider.hasUnreadMessages, true);

        await provider.markAsRead(provider.rooms.first.id);
        expect(provider.rooms.first.unreadCount, 0);
        expect(provider.totalUnreadCount, 0);
        expect(provider.hasUnreadMessages, false);
      });

      testWidgets('Pencegahan keyboard overflow dengan scrolling layout di ChatRoomView', (tester) async {
        final repo = _FakeChatRepository();
        final provider = ChatProvider(repository: repo);
        await provider.loadRooms();
        final room = provider.rooms.first;

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<ChatProvider>.value(value: provider),
                ChangeNotifierProvider<SosProvider>(create: (_) => SosProvider()),
                ChangeNotifierProvider<RatingProvider>(create: (_) => RatingProvider()),
              ],
              child: ChatRoomView(initialRoom: room),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('chat_room_text_field')), findsOneWidget);

        await tester.enterText(find.byKey(const ValueKey('chat_room_text_field')), 'Tes pesan keyboard');
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      test('Inisialisasi submit rating dan ulasan pesanan di akhir chat', () async {
        final ratingRepo = RatingRepositoryImpl();
        final ratingProvider = RatingProvider(repository: ratingRepo);

        final submitSuccess = await ratingProvider.submitRating(
          'mitra_user_1',
          5.0,
          'Layanan sangat cepat, ramah dan terpercaya!',
        );

        expect(submitSuccess, true);
        expect(ratingProvider.ratings.isNotEmpty, true);
        expect(ratingProvider.ratings.first.score, 5.0);
        expect(ratingProvider.ratings.first.reviewText.contains('terpercaya'), true);
      });
    });

    group('Skenario E: Subsistem SOS Darurat', () {
      test('Klasifikasi tipe insiden dan seleksi alasan darurat', () {
        final sosProvider = SosProvider();
        expect(sosProvider.selectedReasonIndex, 0);

        sosProvider.selectReason(1);
        expect(sosProvider.selectedReasonIndex, 1);

        sosProvider.selectReason(2);
        expect(sosProvider.selectedReasonIndex, 2);
      });

      test('Pembuatan dan serialisasi payload darurat SosReportModel', () async {
        final repo = _FakeSosRepository();
        final provider = SosProvider(repository: repo);

        await provider.submitReport('Merasa tidak aman di area kos');
        expect(provider.currentStatus, SosStatus.received);
        expect(repo.lastReport, isNotNull);
        expect(repo.lastReport?.issueType, 'Merasa tidak aman di area kos');

        final json = repo.lastReport!.toJson();
        expect(json['issue_type'], 'Merasa tidak aman di area kos');
        expect(json['status'], 'received');

        final parsed = SosReportModel.fromJson(json);
        expect(parsed.issueType, 'Merasa tidak aman di area kos');
        expect(parsed.status, SosStatus.received);
      });

      test('Timeline tracking respons tahapan satpam/keamanan UB', () async {
        final repo = _FakeSosRepository();
        final provider = SosProvider(repository: repo);

        await provider.updateStatus(SosStatus.received);
        expect(provider.currentStatus, SosStatus.received);

        await provider.updateStatus(SosStatus.handling);
        expect(provider.currentStatus, SosStatus.handling);

        await provider.updateStatus(SosStatus.completed);
        expect(provider.currentStatus, SosStatus.completed);

        final step = SosTimelineStepModel(
          title: 'Petugas Menuju Lokasi',
          description: 'Satpam UB sedang meluncur',
          timestamp: '14.15 WIB',
          isCompleted: true,
          isActive: true,
        );
        expect(step.title, 'Petugas Menuju Lokasi');
        expect(step.isCompleted, true);
      });

      testWidgets('Rendering dialog penyelesaian SOS (SosFinishDialogView)', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SosFinishDialogView(),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Penyelesaian SOS'), findsOneWidget);
        expect(find.text('Apakah laporan sudah selesai?'), findsOneWidget);
        expect(find.text('Selesai'), findsOneWidget);
        expect(find.text('Lapor Kembali'), findsOneWidget);
      });
    });

    group('Skenario F: Filter Khusus Mahasiswi (Women-Only Safe Space)', () {
      final sampleTasks = [
        const TaskModel(
          id: 'task_female_1',
          title: 'Bantu Bersih Kamar Kos Putri',
          requesterName: 'Siti Aminah',
          rating: 4.9,
          ratingCount: 15,
          category: ServiceCategory.bersihKos,
          location: 'Kerto Asri, Malang',
          date: 'Besok',
          time: '09.00',
          notes: 'Kos khusus putri',
          isFemaleOnly: true,
        ),
        const TaskModel(
          id: 'task_general_1',
          title: 'Angkut Lemari Kos Putra',
          requesterName: 'Doni',
          rating: 4.6,
          ratingCount: 8,
          category: ServiceCategory.pindahKos,
          location: 'Watugong, Malang',
          date: 'Besok',
          time: '13.00',
          notes: 'Muatan berat',
          isFemaleOnly: false,
        ),
      ];

      test('Penyaringan task khusus wanita via FemaleOnlyTasksUseCase', () {
        final useCase = FemaleOnlyTasksUseCase();
        final result = useCase.execute(sampleTasks);

        expect(result.length, 1);
        expect(result.first.id, 'task_female_1');
        expect(result.first.isFemaleOnly, true);
      });

      test('Penyaringan via FilterTasksUseCase dan TaskFilterModel', () {
        final useCase = FilterTasksUseCase();
        final filtered = useCase.execute(
          sampleTasks,
          const TaskFilterModel(isFemaleOnly: true),
        );

        expect(filtered.length, 1);
        expect(filtered.first.id, 'task_female_1');

        final allTasks = useCase.execute(
          sampleTasks,
          const TaskFilterModel(isFemaleOnly: false),
        );
        expect(allTasks.length, 2);
      });

      test('Integrasi toggle filter wanita pada state TaskProvider', () async {
        final taskProvider = TaskProvider();
        await taskProvider.loadTasks();

        final totalInitial = taskProvider.tasks.length;
        expect(totalInitial > 0, true);

        taskProvider.toggleFemaleOnlyFilter();
        expect(taskProvider.isFemaleOnlyFilter, true);

        for (final t in taskProvider.tasks) {
          expect(t.isFemaleOnly, true);
        }

        taskProvider.toggleFemaleOnlyFilter();
        expect(taskProvider.isFemaleOnlyFilter, false);
      });
    });

    group('Skenario G: Ketahanan & Error Handling', () {
      test('Deteksi dan propagasi status offline jaringan', () {
        final networkRepo = NetworkRepositoryImpl();
        final connectivityProvider = ConnectivityProvider(repository: networkRepo);

        connectivityProvider.updateConnectionStatus(false);
        expect(connectivityProvider.isOnline, false);

        connectivityProvider.updateConnectionStatus(true);
        expect(connectivityProvider.isOnline, true);
      });

      test('Fallback caching lokal StorageService untuk persistensi offline', () async {
        final storage = StorageService();

        await storage.saveAuthToken('bearer_mock_token_12345');
        await storage.saveUserId('usr_persisted_local');
        await storage.setOnboardingCompleted(true);

        final token = await storage.getAuthToken();
        final userId = await storage.getUserId();
        final onboardingDone = await storage.isOnboardingCompleted();

        expect(token, 'bearer_mock_token_12345');
        expect(userId, 'usr_persisted_local');
        expect(onboardingDone, true);

        await storage.clear();
        expect(await storage.getAuthToken(), isNull);
      });

      test('Pencegahan unhandled exceptions via AppResult dan AppExceptions', () async {
        const netEx = NetworkException('Koneksi internet terputus', 'ERR_NET_01');
        const authEx = AuthException('Sesi kadaluarsa, silakan login ulang', code: 'ERR_AUTH_02');
        const srvEx = ServerException('Server internal error', code: 'ERR_500');

        final failResult = AppResult<String>.failure(netEx.message);
        expect(failResult.isSuccess, false);
        expect(failResult.errorMessage, 'Koneksi internet terputus');

        final mockTaskService = MockTaskService();
        final tasksRes = await mockTaskService.getTasks();
        expect(tasksRes.isSuccess, true);
        expect(tasksRes.data?.isNotEmpty, true);

        expect(authEx.toString().contains('kadaluarsa'), true);
        expect(srvEx.toString().contains('internal error'), true);
        expect(srvEx.code, 'ERR_500');
      });
    });

    group('Skenario H: Loyalty Points & Penjadwalan Cerdas', () {
      test('Pengambilan poin loyalty dan klaim voucher berhasil', () async {
        final loyaltyRepo = _FakeLoyaltyRepository();
        final loyaltyProvider = LoyaltyProvider(repository: loyaltyRepo);

        await loyaltyProvider.loadLoyaltyPoints('usr_tester');
        expect(loyaltyProvider.totalPoints, 120);
        expect(loyaltyProvider.availableVouchers, 1);

        final claimSuccess = await loyaltyProvider.claimVoucher('usr_tester', 50);
        expect(claimSuccess, true);
        expect(loyaltyProvider.totalPoints, 70);
        expect(loyaltyProvider.availableVouchers, 2);
      });

      test('Validasi proteksi saldo poin menolak klaim jika tidak mencukupi', () async {
        final loyaltyRepo = _FakeLoyaltyRepository();
        final loyaltyProvider = LoyaltyProvider(repository: loyaltyRepo);

        await loyaltyProvider.loadLoyaltyPoints('usr_tester');
        final claimExceeded = await loyaltyProvider.claimVoucher('usr_tester', 9999);

        expect(claimExceeded, false);
        expect(loyaltyProvider.errorMessage?.contains('tidak mencukupi'), true);
        expect(loyaltyProvider.totalPoints, 120);
      });

      test('Pembuatan jadwal pemesanan berkala via ScheduleProvider', () async {
        final scheduleRepo = ScheduleRepositoryImpl();
        final scheduleProvider = ScheduleProvider(repository: scheduleRepo);

        await scheduleProvider.loadSchedules('usr_tester');
        final initialCount = scheduleProvider.schedules.length;

        final schedule = SmartScheduleModel(
          id: 'sched_new_1',
          userId: 'usr_tester',
          taskId: 'task_rutin_1',
          taskTitle: 'Bersih Kamar Kos Rutin Akhir Pekan',
          scheduledTime: DateTime.now().add(const Duration(days: 3)),
          category: ServiceCategory.bersihKos,
        );

        final booked = await scheduleProvider.bookSchedule(schedule);
        expect(booked, true);
        expect(scheduleProvider.schedules.length, initialCount + 1);
        expect(scheduleProvider.schedules.last.taskTitle.contains('Rutin'), true);
      });
    });
  });
}
