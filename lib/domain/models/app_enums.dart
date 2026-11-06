import 'package:flutter/material.dart';

enum TaskStatus { pending, inProgress, completed, cancelled }

enum SosStatus { received, handling, completed }

enum ServiceCategory { bersihKos, pindahKos, antarJemput }

enum BarterType { makanan, barang, jasa, lainnya }

enum KtmVerificationStatus { unverified, pending, verified, rejected }

enum UserRole { customer, provider, admin }

enum UserGender { male, female, unspecified }

enum VehicleType { motor, mobil }

enum MoveServiceStatus {
  waiting,
  searching,
  terjadwal,
  accepted,
  negosiasi,
  menujuLokasi,
  tiba,
  dikerjakan,
  inProgress,
  dalamPengantaran,
  completed,
  cancelled,
  dibatalkan;

  String get label {
    switch (this) {
      case MoveServiceStatus.waiting:
        return 'Menunggu';
      case MoveServiceStatus.searching:
        return 'Mencari Helper';
      case MoveServiceStatus.terjadwal:
        return 'Terjadwal';
      case MoveServiceStatus.accepted:
        return 'Diterima';
      case MoveServiceStatus.negosiasi:
        return 'Negosiasi';
      case MoveServiceStatus.menujuLokasi:
        return 'Menuju Lokasi';
      case MoveServiceStatus.tiba:
        return 'Tiba';
      case MoveServiceStatus.dikerjakan:
        return 'Dikerjakan';
      case MoveServiceStatus.inProgress:
        return 'Berlangsung';
      case MoveServiceStatus.dalamPengantaran:
        return 'Dalam Pengantaran';
      case MoveServiceStatus.completed:
        return 'Selesai';
      case MoveServiceStatus.cancelled:
        return 'Batal';
      case MoveServiceStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  Color get badgeBgColor {
    switch (this) {
      case MoveServiceStatus.terjadwal:
        return const Color(0xFFE3F2FD);
      case MoveServiceStatus.menujuLokasi:
        return const Color(0xFFFFF3E0);
      case MoveServiceStatus.tiba:
        return const Color(0xFFE0F2F1);
      case MoveServiceStatus.dikerjakan:
      case MoveServiceStatus.inProgress:
        return const Color(0xFFE8F5E9);
      case MoveServiceStatus.dalamPengantaran:
        return const Color(0xFFF3E5F5);
      case MoveServiceStatus.negosiasi:
        return const Color(0xFFFFF8E1);
      case MoveServiceStatus.cancelled:
      case MoveServiceStatus.dibatalkan:
        return const Color(0xFFFFEBEE);
      case MoveServiceStatus.completed:
        return const Color(0xFFEEEEEE);
      case MoveServiceStatus.waiting:
      case MoveServiceStatus.searching:
        return const Color(0xFFE2F1D8);
      case MoveServiceStatus.accepted:
        return const Color(0xFFFFF3E0);
    }
  }

  Color get badgeTextColor {
    switch (this) {
      case MoveServiceStatus.terjadwal:
        return const Color(0xFF1565C0);
      case MoveServiceStatus.menujuLokasi:
        return const Color(0xFFE65100);
      case MoveServiceStatus.tiba:
        return const Color(0xFF00695C);
      case MoveServiceStatus.dikerjakan:
      case MoveServiceStatus.inProgress:
        return const Color(0xFF2E7D32);
      case MoveServiceStatus.dalamPengantaran:
        return const Color(0xFF6A1B9A);
      case MoveServiceStatus.negosiasi:
        return const Color(0xFFF57F17);
      case MoveServiceStatus.cancelled:
      case MoveServiceStatus.dibatalkan:
        return const Color(0xFFC62828);
      case MoveServiceStatus.completed:
        return const Color(0xFF616161);
      case MoveServiceStatus.waiting:
      case MoveServiceStatus.searching:
        return const Color(0xFF283626);
      case MoveServiceStatus.accepted:
        return const Color(0xFFE65100);
    }
  }

  bool get isFinal {
    return this == MoveServiceStatus.completed ||
        this == MoveServiceStatus.cancelled ||
        this == MoveServiceStatus.dibatalkan;
  }
}

typedef OrderStatus = MoveServiceStatus;
