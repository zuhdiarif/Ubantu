import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/data/models/chat_room_model.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/chat/chat_provider.dart';
import 'package:ubantu/ui/mitra/mitra_provider.dart';
import 'package:ubantu/ui/notification/notification_provider.dart';
import 'package:ubantu/ui/mitra/rating_provider.dart';
import 'package:ubantu/ui/sos/sos_provider.dart';
import 'package:ubantu/ui/chat/chat_room_view.dart';
import 'package:ubantu/ui/mitra/mitra_dashboard_view.dart';
import 'package:ubantu/ui/notification/notification_view.dart';
import 'package:ubantu/ui/profile/profil_view.dart';

void main() {
  group('Squad C PRD Items Tests', () {
    test('PRD-10a: UserModel handles faculty and bio fields', () {
      const user = UserModel(
        id: 'usr_c1',
        fullName: 'Mahasiswa FILKOM',
        email: 'filkom@student.ub.ac.id',
        phoneNumber: '081234567890',
        nim: '245150200111001',
        faculty: 'FILKOM / Teknik Informatika',
        bio: 'Suka coding Flutter dan bantu sesama.',
      );

      expect(user.faculty, 'FILKOM / Teknik Informatika');
      expect(user.bio, 'Suka coding Flutter dan bantu sesama.');

      final json = user.toJson();
      expect(json['faculty'], 'FILKOM / Teknik Informatika');
      expect(json['bio'], 'Suka coding Flutter dan bantu sesama.');

      final fromJson = UserModel.fromJson(json);
      expect(fromJson.faculty, 'FILKOM / Teknik Informatika');
      expect(fromJson.bio, 'Suka coding Flutter dan bantu sesama.');

      final copied = user.copyWith(faculty: 'FEB / Manajemen', bio: 'Update bio');
      expect(copied.faculty, 'FEB / Manajemen');
      expect(copied.bio, 'Update bio');
    });

    test('PRD-8a: NotificationProvider supports Transaksi and Bantuan filters', () {
      final provider = NotificationProvider();
      provider.addNotification('Order Masuk', 'Ada order baru', type: 'order');
      provider.addNotification('Transfer Berhasil', 'Poin ditambahkan', type: 'transaksi');
      provider.addNotification('SOS Kampus', 'Bantuan darurat', type: 'sos');

      provider.setFilter('Transaksi');
      expect(provider.filteredNotifications.any((n) => n.type == 'transaksi'), true);
      expect(provider.filteredNotifications.any((n) => n.type == 'order'), false);

      provider.setFilter('Bantuan');
      expect(provider.filteredNotifications.any((n) => n.type == 'sos'), true);
      expect(provider.filteredNotifications.any((n) => n.type == 'transaksi'), false);
    });

    testWidgets('PRD-8a: NotificationView renders all required filter tabs', (tester) async {
      final provider = NotificationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<NotificationProvider>.value(
            value: provider,
            child: const NotificationView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pesanan'), findsOneWidget);
      expect(find.text('Transaksi'), findsOneWidget);
      expect(find.text('Bantuan'), findsOneWidget);
      expect(find.text('KTM'), findsOneWidget);
      expect(find.text('Pesan'), findsOneWidget);
    });

    testWidgets('PRD-9b: MitraDashboardView renders Tolak button in order card', (tester) async {
      final repository = MitraRepositoryImpl();
      final provider = MitraProvider(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MitraProvider>.value(
            value: provider,
            child: const MitraDashboardView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Tolak'), findsWidgets);
      expect(find.text('Kelola / Lanjutkan Bantuan'), findsWidgets);
    });

    testWidgets('PRD-10b: ProfilView renders 4 additional menu options and displays bio/faculty', (tester) async {
      final auth = AuthProvider();
      auth.updateUser(const UserModel(
        id: 'usr_profil_test',
        fullName: 'Budi Santoso',
        email: 'budi@student.ub.ac.id',
        phoneNumber: '081234567890',
        nim: '245150200111002',
        faculty: 'Fakultas Ilmu Komputer',
        bio: 'Mahasiswa semester 6 penggiat sosial.',
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: auth,
            child: const Scaffold(body: ProfilView()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Fakultas Ilmu Komputer'), findsOneWidget);
      expect(find.text('Mahasiswa semester 6 penggiat sosial.'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Riwayat Bantuan'), findsOneWidget);
      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Bantuan & Pusat Informasi (FAQ)'), findsOneWidget);
    });

    testWidgets('PRD-7a: ChatRoomView renders Ubah button on active order card', (tester) async {
      final chatProvider = ChatProvider();
      final activeRoom = ChatRoomModel(
        id: 'room_prd7a',
        orderId: 'ord_prd7a',
        orderNumber: '#UB778899',
        serviceTitle: 'Antar Jemput',
        serviceStatus: 'SEDANG BERLANGSUNG',
        otherUserName: 'Mitra Hero',
        lastMessage: 'Halo',
        lastMessageTime: DateTime.now(),
        itemSummary: 'Antar berkas skripsi',
        pickupLocation: 'Gerbang Veteran',
        destinationLocation: 'Gedung FILKOM C',
        totalPrice: 'Es Teh Manis',
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
              ChangeNotifierProvider<RatingProvider>(create: (_) => RatingProvider()),
              ChangeNotifierProvider<SosProvider>(create: (_) => SosProvider()),
            ],
            child: Scaffold(
              body: ChatRoomView(initialRoom: activeRoom),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ubah'), findsWidgets);
    });
  });
}
