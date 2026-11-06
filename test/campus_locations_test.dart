import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/utils/campus_locations.dart';

void main() {
  group('CampusLocations.resolve Unit Tests', () {
    test('resolves null, empty, or unknown to null', () {
      expect(CampusLocations.resolve(null), isNull);
      expect(CampusLocations.resolve(''), isNull);
      expect(CampusLocations.resolve('   '), isNull);
      expect(CampusLocations.resolve('Jakarta Selatan'), isNull);
      expect(CampusLocations.resolve('Surabaya Gubeng'), isNull);
    });

    test('resolves UB keywords case-insensitively', () {
      expect(CampusLocations.resolve('Gerbang Utama UB'), equals(CampusLocations.ub));
      expect(CampusLocations.resolve('Universitas Brawijaya'), equals(CampusLocations.ub));
      expect(CampusLocations.resolve('Gedung Filkom UB'), equals(CampusLocations.ub));
      expect(CampusLocations.resolve('Fakultas Teknik FT UB'), equals(CampusLocations.ub));
      expect(CampusLocations.resolve('Jl. Veteran No. 8 Malang'), equals(CampusLocations.ub));
    });

    test('resolves Polinema keywords', () {
      expect(CampusLocations.resolve('Polinema'), equals(CampusLocations.polinema));
      expect(CampusLocations.resolve('Politeknik Negeri Malang'), equals(CampusLocations.polinema));
    });

    test('resolves UM keywords', () {
      expect(CampusLocations.resolve('UM'), equals(CampusLocations.um));
      expect(CampusLocations.resolve('Universitas Negeri Malang'), equals(CampusLocations.um));
    });

    test('resolves Suhat keywords', () {
      expect(CampusLocations.resolve('Jl. Soekarno Hatta'), equals(CampusLocations.suhat));
      expect(CampusLocations.resolve('Kopi Suhat'), equals(CampusLocations.suhat));
    });

    test('resolves neighborhood areas in Malang', () {
      expect(CampusLocations.resolve('Kos Dinoyo Asri'), equals(CampusLocations.dinoyo));
      expect(CampusLocations.resolve('Sumbersari gang 5'), equals(CampusLocations.sumbersari));
      expect(CampusLocations.resolve('Ketawanggede UB'), equals(CampusLocations.ketawanggede));
      expect(CampusLocations.resolve('Jl. Kerto Raharjo'), equals(CampusLocations.kerto));
      expect(CampusLocations.resolve('Jl. MT Haryono No 12'), equals(CampusLocations.mtHaryono));
      expect(CampusLocations.resolve('Jl. Watugong Malang'), equals(CampusLocations.watugong));
      expect(CampusLocations.resolve('Tlogomas Barat'), equals(CampusLocations.tlogomas));
    });

    test('resolves landmark areas', () {
      expect(CampusLocations.resolve('Matos'), equals(CampusLocations.matos));
      expect(CampusLocations.resolve('Malang Town Square'), equals(CampusLocations.matos));
      expect(CampusLocations.resolve('Stasiun Malang Kota Baru'), equals(CampusLocations.stasiunMalang));
    });

    test('verifies coordinates are valid LatLng values in Malang', () {
      expect(CampusLocations.defaultCenter.latitude, closeTo(-7.95, 0.1));
      expect(CampusLocations.defaultCenter.longitude, closeTo(112.61, 0.1));
    });
  });
}
