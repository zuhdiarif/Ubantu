import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/models/user_model.dart';

class MockDataFactory {
  static UserModel get mockUser => const UserModel(
        id: 'usr_farel',
        fullName: 'Farel Brawijaya',
        email: 'farel@student.ub.ac.id',
        phoneNumber: '081234567890',
        nim: '245150200111001',
        verificationStatus: KtmVerificationStatus.verified,
      );

  static List<TaskModel> get mockTasks => [
        const TaskModel(
          id: 't1',
          title: 'Bersih Kos',
          requesterName: 'Rafi Ahmad',
          rating: 4.8,
          ratingCount: 32,
          category: ServiceCategory.bersihKos,
          location: 'Jl. Kaliurang Km 5, Yogyakarta',
          date: '2 Jun 2025',
          time: '10:00',
          notes: 'Bantu bersihkan kamar kos, alat disiapkan.',
        ),
        const TaskModel(
          id: 't2',
          title: 'Pindah Kos',
          requesterName: 'Dinda Putri',
          rating: 4.6,
          ratingCount: 18,
          category: ServiceCategory.pindahKos,
          location: 'Jl. Seturan No. 45, Yogyakarta',
          date: '3 Jun 2025',
          time: '14:00',
          notes: 'Angkut 3 dus barang pindahan kos.',
        ),
        const TaskModel(
          id: 't3',
          title: 'Antar Jemput',
          requesterName: 'Bima Pratama',
          rating: 4.9,
          ratingCount: 27,
          category: ServiceCategory.antarJemput,
          location: 'Jl. Gejayan No. 12, Yogyakarta',
          date: '4 Jun 2025',
          time: '09:00',
          notes: 'Jemput dari stasiun ke kos.',
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
          title: 'Verifikasi Berhasil',
          message: 'Identitas KTM Universitas Brawijaya telah terverifikasi.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
        ),
        NotificationModel(
          id: 'n2',
          title: 'Permintaan Diterima',
          message: 'Nasya menerima bantuan Bersih Kos kamu.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
        ),
      ];
}
