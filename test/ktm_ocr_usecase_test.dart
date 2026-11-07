import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/text_recognition_service.dart';
import 'package:ubantu/logic/extract_ktm_data_usecase.dart';

class _FakeTextRecognitionService implements ITextRecognitionService {
  AppResult<String> result;

  _FakeTextRecognitionService(this.result);

  @override
  Future<AppResult<String>> recognizeText(String imagePath) async {
    return result;
  }
}

void main() {
  group('ExtractKtmDataUseCase Unit Tests', () {
    test('extracts 15-digit UB NIM and verifies looksLikeKtm from realistic KTM text', () async {
      const sampleText = '''
KEMENTERIAN PENDIDIKAN, KEBUDAYAAN, RISET, DAN TEKNOLOGI
UNIVERSITAS BRAWIJAYA
KARTU TANDA MAHASISWA
NIM : 225150201111001
Nama : MUHAMMAD ZUHDI
Fakultas Ilmu Komputer
Program Studi Teknik Informatika
''';

      final service = _FakeTextRecognitionService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);

      final result = await useCase.execute('/dummy/path/ktm.jpg');

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.looksLikeKtm, isTrue);
      expect(result.data!.nim, equals('225150201111001'));
      expect(result.data!.name, equals('MUHAMMAD ZUHDI'));
    });

    test('extracts and normalizes spaced digit sequence near NIM keyword', () async {
      const sampleText = '''
UNIVERSITAS BRAWIJAYA
KARTU TANDA MAHASISWA
Nama: Siti Aminah
NIM: 225 150 201 111 001
''';

      final service = _FakeTextRecognitionService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);

      final result = await useCase.execute('/dummy/path/ktm.jpg');

      expect(result.isSuccess, isTrue);
      expect(result.data!.looksLikeKtm, isTrue);
      expect(result.data!.nim, equals('225150201111001'));
    });

    test('extracts and normalizes dotted digit sequence near No. Mahasiswa keyword', () async {
      const sampleText = '''
KTM MAHASISWA
UNIVERSITAS BRAWIJAYA
No. Mahasiswa : 2351.5020.7111.054
Nama : Ahmad Dahlan
''';

      final service = _FakeTextRecognitionService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);

      final result = await useCase.execute('/dummy/path/ktm.jpg');

      expect(result.isSuccess, isTrue);
      expect(result.data!.looksLikeKtm, isTrue);
      expect(result.data!.nim, equals('235150207111054'));
    });

    test('extracts NIM when keyword and digits are on separate lines', () async {
      const sampleText = '''
UNIVERSITAS BRAWIJAYA
KTM
NIM
215150200111023
Nama
Budi Santoso
''';

      final service = _FakeTextRecognitionService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);

      final result = await useCase.execute('/dummy/path/ktm.jpg');

      expect(result.isSuccess, isTrue);
      expect(result.data!.looksLikeKtm, isTrue);
      expect(result.data!.nim, equals('215150200111023'));
    });

    test('identifies non-KTM text and marks looksLikeKtm as false', () async {
      const sampleText = '''
WARUNG KOPI SUDIRMAN
Jl. Veteran No. 12 Malang
Struk Pembayaran
Total: Rp 35.000
No Transaksi: 987654321012
Terima Kasih Telah Berkunjung
''';

      final service = _FakeTextRecognitionService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);

      final result = await useCase.execute('/dummy/path/receipt.jpg');

      expect(result.isSuccess, isTrue);
      expect(result.data!.looksLikeKtm, isFalse);
    });

    test('returns null NIM when KTM text has no valid digit sequence', () async {
      const sampleText = '''
UNIVERSITAS BRAWIJAYA
KARTU TANDA MAHASISWA
Nama: Mahasiswa Anonim
Fakultas Pertanian
''';

      final service = _FakeTextRecognitionService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);

      final result = await useCase.execute('/dummy/path/ktm_no_nim.jpg');

      expect(result.isSuccess, isTrue);
      expect(result.data!.looksLikeKtm, isTrue);
      expect(result.data!.nim, isNull);
    });

    test('handles OCR service failure gracefully', () async {
      final service = _FakeTextRecognitionService(
        AppResult.failure('Gagal memproses gambar'),
      );
      final useCase = ExtractKtmDataUseCase(service);

      final result = await useCase.execute('/dummy/corrupted.jpg');

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Gagal memproses'));
    });
  });
}
