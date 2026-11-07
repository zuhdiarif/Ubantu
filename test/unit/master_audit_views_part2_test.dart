import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/ui/antar_jemput/antar_jemput_form_view.dart';
import 'package:ubantu/ui/sos/sos_form_view.dart';

void main() {
  group('AntarJemputMode Validation Tests (Item 3K)', () {
    test('AntarJemputMode.tebengan only requires pickup and dropoff', () {
      final valid = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.tebengan,
        pickup: 'Gerbang Veteran UB',
        dropoff: 'Stasiun Malang Kota Baru',
        receiverName: '',
        receiverPhone: '',
      );
      expect(valid, isTrue);

      final validWithNulls = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.tebengan,
        pickup: 'Filkom UB',
        dropoff: 'Suhat',
      );
      expect(validWithNulls, isTrue);

      final invalidPickup = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.tebengan,
        pickup: '   ',
        dropoff: 'Suhat',
      );
      expect(invalidPickup, isFalse);

      final invalidDropoff = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.tebengan,
        pickup: 'Filkom UB',
        dropoff: '',
      );
      expect(invalidDropoff, isFalse);
    });

    test('AntarJemputMode.barang strictly requires receiver name and valid phone', () {
      final invalidWithoutReceiver = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.barang,
        pickup: 'Gedung Rektorat UB',
        dropoff: 'Kos Putri Watumujur',
        receiverName: '',
        receiverPhone: '08123456789',
      );
      expect(invalidWithoutReceiver, isFalse);

      final invalidWithoutPhone = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.barang,
        pickup: 'Gedung Rektorat UB',
        dropoff: 'Kos Putri Watumujur',
        receiverName: 'Siti Rahma',
        receiverPhone: '',
      );
      expect(invalidWithoutPhone, isFalse);

      final invalidShortPhone = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.barang,
        pickup: 'Gedung Rektorat UB',
        dropoff: 'Kos Putri Watumujur',
        receiverName: 'Siti Rahma',
        receiverPhone: '0812',
      );
      expect(invalidShortPhone, isFalse);

      final validBarang = AntarJemputFormView.validateStep0(
        mode: AntarJemputMode.barang,
        pickup: 'Gedung Rektorat UB',
        dropoff: 'Kos Putri Watumujur',
        receiverName: 'Siti Rahma',
        receiverPhone: '0812-3456-7890',
      );
      expect(validBarang, isTrue);
    });
  });

  group('SosStatus Timeline State Progression Tests (Item 3J)', () {
    Map<String, dynamic> evaluateTimeline(SosStatus status) {
      final isResolved = status == SosStatus.completed || status.name == 'resolved';
      return {
        'step1': {
          'isDone': true,
          'isCurrent': status == SosStatus.received,
        },
        'step2': {
          'isDone': status == SosStatus.handling || isResolved,
          'isCurrent': status == SosStatus.handling,
        },
        'step3': {
          'isDone': isResolved,
          'isCurrent': isResolved,
        },
      };
    }

    test('SosStatus.received activates step 1 only', () {
      final timeline = evaluateTimeline(SosStatus.received);
      expect(timeline['step1']!['isDone'], isTrue);
      expect(timeline['step1']!['isCurrent'], isTrue);
      expect(timeline['step2']!['isDone'], isFalse);
      expect(timeline['step2']!['isCurrent'], isFalse);
      expect(timeline['step3']!['isDone'], isFalse);
      expect(timeline['step3']!['isCurrent'], isFalse);
    });

    test('SosStatus.handling activates step 2 and marks step 1 done', () {
      final timeline = evaluateTimeline(SosStatus.handling);
      expect(timeline['step1']!['isDone'], isTrue);
      expect(timeline['step1']!['isCurrent'], isFalse);
      expect(timeline['step2']!['isDone'], isTrue);
      expect(timeline['step2']!['isCurrent'], isTrue);
      expect(timeline['step3']!['isDone'], isFalse);
      expect(timeline['step3']!['isCurrent'], isFalse);
    });

    test('SosStatus.completed activates step 3 and marks all previous steps done', () {
      final timeline = evaluateTimeline(SosStatus.completed);
      expect(timeline['step1']!['isDone'], isTrue);
      expect(timeline['step1']!['isCurrent'], isFalse);
      expect(timeline['step2']!['isDone'], isTrue);
      expect(timeline['step2']!['isCurrent'], isFalse);
      expect(timeline['step3']!['isDone'], isTrue);
      expect(timeline['step3']!['isCurrent'], isTrue);
    });
  });

  group('SosEmergencyType Category Mapping Tests (Item 3J)', () {
    SosEmergencyType mapCategory(String category) {
      if (category == 'Medis / Kecelakaan') return SosEmergencyType.medis;
      if (category == 'Ancaman Keamanan') return SosEmergencyType.keamanan;
      if (category == 'Kendaraan Mogok Malam') return SosEmergencyType.kecelakaan;
      return SosEmergencyType.lainnya;
    }

    test('Maps categories to correct SosEmergencyType', () {
      expect(mapCategory('Medis / Kecelakaan'), equals(SosEmergencyType.medis));
      expect(mapCategory('Ancaman Keamanan'), equals(SosEmergencyType.keamanan));
      expect(mapCategory('Kendaraan Mogok Malam'), equals(SosEmergencyType.kecelakaan));
      expect(mapCategory('Kondisi Darurat Lainnya'), equals(SosEmergencyType.lainnya));
      expect(mapCategory('Unknown Category'), equals(SosEmergencyType.lainnya));
    });
  });
}
