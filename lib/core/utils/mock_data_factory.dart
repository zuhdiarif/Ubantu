import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/models/user_model.dart';

class MockDataFactory {
  static UserModel get mockUser => const UserModel(
        id: 'usr_tester',
        fullName: 'Mahasiswa Tester UB',
        email: 'tester@student.ub.ac.id',
        phoneNumber: '081234567890',
        nim: '245150200111001',
        verificationStatus: KtmVerificationStatus.verified,
      );

  static List<TaskModel> get mockTasks => [
        const TaskModel(
          id: 't1',
          title: 'Jasa Bersih Kamar Kos',
          requesterName: 'Mahasiswa Tester UB',
          rating: 4.9,
          ratingCount: 38,
          category: ServiceCategory.bersihKos,
          location: 'Jl. Simpang Gajayana No. 15, Malang',
          date: '16 Aug 2026',
          time: '10:00',
          notes: 'Bantu bersihkan kamar kos.',
        ),
        const TaskModel(
          id: 't2',
          title: 'Jasa Angkut Pindah Kos',
          requesterName: 'Ahmad Farel',
          rating: 4.8,
          ratingCount: 24,
          category: ServiceCategory.pindahKos,
          location: 'Jl. MT Haryono Gg 8, Malang',
          date: '17 Aug 2026',
          time: '13:30',
          notes: 'Angkut barang pindahan.',
        ),
        const TaskModel(
          id: 't3',
          title: 'Antar Paket & Barang Fleksibel',
          requesterName: 'Dinda Putri',
          rating: 5.0,
          ratingCount: 42,
          category: ServiceCategory.antarJemput,
          location: 'Jl. Veteran Malang (Gedung Filkom)',
          date: '18 Aug 2026',
          time: '09:00',
          notes: 'Jemput dari gedung kampus.',
          isFemaleOnly: true,
        ),
        const TaskModel(
          id: 't4',
          title: 'Bersihkan Kamar & Karpet Kos',
          requesterName: 'Bintang Pratama',
          rating: 4.9,
          ratingCount: 52,
          category: ServiceCategory.bersihKos,
          location: 'Jl. Bendungan Sutami No. 24, Malang',
          date: '17 Aug 2026',
          time: '08:30',
          notes: 'Sedot debu karpet kos.',
        ),
        const TaskModel(
          id: 't5',
          title: 'Angkut Kardus Pindahan Kos Cewek',
          requesterName: 'Anisa Rahmawati',
          rating: 4.8,
          ratingCount: 31,
          category: ServiceCategory.pindahKos,
          location: 'Jl. Watugede Gg 2, Malang',
          date: '17 Aug 2026',
          time: '11:00',
          notes: 'Bantu angkut dus pindahan.',
          isFemaleOnly: true,
        ),
        const TaskModel(
          id: 't6',
          title: 'Pesan Antar Makanan & Print Tugas',
          requesterName: 'Farhan Kurniawan',
          rating: 5.0,
          ratingCount: 64,
          category: ServiceCategory.antarJemput,
          location: 'Jl. Borobudur No. 88, Malang',
          date: '18 Aug 2026',
          time: '15:00',
          notes: 'Bantu print tugas dan antar makanan.',
        ),
        const TaskModel(
          id: 't7',
          title: 'Jemput Stasiun Malang Kota Baru',
          requesterName: 'Rizky Aditya',
          rating: 4.9,
          ratingCount: 45,
          category: ServiceCategory.antarJemput,
          location: 'Stasiun Kota Baru Malang',
          date: '19 Aug 2026',
          time: '20:15',
          notes: 'Antar dari stasiun ke kos.',
        ),
      ];

  static List<BarterItemModel> get mockBarters => [
        const BarterItemModel(
          id: 'b1',
          title: 'Makanan',
          description: 'Tukar dengan makanan',
          type: BarterType.makanan,
          iconAsset: 'fastfood_rounded',
        ),
        const BarterItemModel(
          id: 'b2',
          title: 'Barang',
          description: 'Tukar dengan barang',
          type: BarterType.barang,
          iconAsset: 'card_giftcard_rounded',
        ),
      ];

  static List<NotificationModel> get mockNotifications => [
        NotificationModel(
          id: 'n1',
          userId: 'usr_tester',
          title: 'Verifikasi Berhasil',
          message: 'Identitas KTM Universitas Brawijaya telah terverifikasi.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
        ),
        NotificationModel(
          id: 'n2',
          userId: 'usr_tester',
          title: 'Selamat Datang di UBantu!',
          message: 'Platform saling bantu antar mahasiswa UB. Selamat menggunakan layanan.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
        ),
      ];
}
