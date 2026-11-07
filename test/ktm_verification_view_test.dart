import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/data/repositories/text_recognition_service.dart';
import 'package:ubantu/logic/extract_ktm_data_usecase.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/auth/ktm_verification_provider.dart';
import 'package:ubantu/ui/auth/registration_provider.dart';
import 'package:ubantu/ui/auth/ktm_verification_view.dart';

class _FakeOcrService implements ITextRecognitionService {
  AppResult<String> result;

  _FakeOcrService(this.result);

  @override
  Future<AppResult<String>> recognizeText(String imagePath) async {
    return result;
  }
}

void main() {
  group('KtmVerificationProvider Tests', () {
    test('successful scan sets recognizedNim and updates status', () async {
      const sampleText = '''
UNIVERSITAS BRAWIJAYA
KARTU TANDA MAHASISWA
NIM: 225150201111001
Nama: Budi Pratama
''';
      final service = _FakeOcrService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);
      final provider = KtmVerificationProvider(extractKtmDataUseCase: useCase);

      final result = await provider.scanKtm(File('/fake/ktm.jpg'));

      expect(result, isNotNull);
      expect(provider.isScanning, isFalse);
      expect(provider.recognizedNim, equals('225150201111001'));
      expect(provider.ocrResult?.looksLikeKtm, isTrue);
      expect(provider.isWarningBanner, isFalse);
    });

    test('sets warning banner when image does not look like KTM', () async {
      const sampleText = '''
SUPERMARKET MALANG
Struk Pembayaran
Total: 150000
''';
      final service = _FakeOcrService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);
      final provider = KtmVerificationProvider(extractKtmDataUseCase: useCase);

      final result = await provider.scanKtm(File('/fake/receipt.jpg'));

      expect(result, isNotNull);
      expect(provider.isScanning, isFalse);
      expect(provider.ocrResult?.looksLikeKtm, isFalse);
      expect(provider.isWarningBanner, isTrue);
      expect(
        provider.bannerMessage,
        equals('Foto tidak terlihat seperti KTM, pastikan foto jelas'),
      );
    });

    test('sets info banner when KTM text lacks NIM', () async {
      const sampleText = '''
UNIVERSITAS BRAWIJAYA
KARTU TANDA MAHASISWA
Fakultas Teknik
''';
      final service = _FakeOcrService(AppResult.success(sampleText));
      final useCase = ExtractKtmDataUseCase(service);
      final provider = KtmVerificationProvider(extractKtmDataUseCase: useCase);

      final result = await provider.scanKtm(File('/fake/ktm_no_nim.jpg'));

      expect(result, isNotNull);
      expect(provider.isScanning, isFalse);
      expect(provider.ocrResult?.looksLikeKtm, isTrue);
      expect(provider.isInfoBanner, isTrue);
      expect(
        provider.bannerMessage,
        contains('NIM tidak terdeteksi otomatis'),
      );
    });

    test('handles OCR failure gracefully without throwing', () async {
      final service = _FakeOcrService(
        AppResult.failure('OCR service unavailable'),
      );
      final useCase = ExtractKtmDataUseCase(service);
      final provider = KtmVerificationProvider(extractKtmDataUseCase: useCase);

      final result = await provider.scanKtm(File('/fake/broken.jpg'));

      expect(result, isNull);
      expect(provider.isScanning, isFalse);
      expect(provider.isInfoBanner, isTrue);
      expect(
        provider.bannerMessage,
        contains('Tidak dapat membaca teks otomatis'),
      );
    });
  });

  group('KtmVerificationView Widget Tests', () {
    testWidgets('renders KTM verification form and skip options', (tester) async {
      final authProvider = AuthProvider();
      final regProvider = RegistrationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: regProvider),
          ],
          child: const MaterialApp(
            home: KtmVerificationView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verifikasi KTM'), findsOneWidget);
      expect(find.text('NIM Universitas Brawijaya'), findsOneWidget);
      expect(find.text('Foto Fisik KTM UB'), findsOneWidget);
      expect(find.text('Kirim Verifikasi KTM'), findsOneWidget);
      expect(find.text('Lewati, verifikasi nanti'), findsOneWidget);
      expect(find.text('Lewati'), findsOneWidget);
    });

    testWidgets('auto-fills NIM and displays warning banner when applicable', (
      tester,
    ) async {
      const validKtmText = '''
UNIVERSITAS BRAWIJAYA
KARTU TANDA MAHASISWA
NIM: 225150201111001
Nama: Andi Wijaya
''';
      final service = _FakeOcrService(AppResult.success(validKtmText));
      final useCase = ExtractKtmDataUseCase(service);
      final ktmProvider = KtmVerificationProvider(extractKtmDataUseCase: useCase);
      final authProvider = AuthProvider();
      final regProvider = RegistrationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: regProvider),
            ChangeNotifierProvider.value(value: ktmProvider),
          ],
          child: const MaterialApp(
            home: KtmVerificationView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await ktmProvider.scanKtm(File('dummy_path.jpg'));
      await tester.pumpAndSettle();

      expect(ktmProvider.recognizedNim, equals('225150201111001'));
      expect(ktmProvider.ocrResult?.looksLikeKtm, isTrue);
    });

    testWidgets('shows warning banner when photo does not look like KTM', (
      tester,
    ) async {
      const nonKtmText = '''
TOKO ROTI SEJAHTERA
Alamat: Malang
''';
      final service = _FakeOcrService(AppResult.success(nonKtmText));
      final useCase = ExtractKtmDataUseCase(service);
      final ktmProvider = KtmVerificationProvider(extractKtmDataUseCase: useCase);
      final authProvider = AuthProvider();
      final regProvider = RegistrationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: regProvider),
            ChangeNotifierProvider.value(value: ktmProvider),
          ],
          child: const MaterialApp(
            home: KtmVerificationView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await ktmProvider.scanKtm(File('dummy_non_ktm.jpg'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ktm_ocr_warning_banner')), findsOneWidget);
      expect(
        find.text('Foto tidak terlihat seperti KTM, pastikan foto jelas'),
        findsOneWidget,
      );
    });

    testWidgets('shows info banner when KTM text lacks NIM', (tester) async {
      const ktmNoNim = '''
UNIVERSITAS BRAWIJAYA
MAHASISWA AKTIF
''';
      final service = _FakeOcrService(AppResult.success(ktmNoNim));
      final useCase = ExtractKtmDataUseCase(service);
      final ktmProvider = KtmVerificationProvider(extractKtmDataUseCase: useCase);
      final authProvider = AuthProvider();
      final regProvider = RegistrationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: regProvider),
            ChangeNotifierProvider.value(value: ktmProvider),
          ],
          child: const MaterialApp(
            home: KtmVerificationView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await ktmProvider.scanKtm(File('dummy_ktm_no_nim.jpg'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ktm_ocr_info_banner')), findsOneWidget);
      expect(
        find.text(
          'NIM tidak terdeteksi otomatis. Silakan masukkan NIM secara manual.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('skip button navigates to home when opened standalone', (
      tester,
    ) async {
      final authProvider = AuthProvider();
      final regProvider = RegistrationProvider();

      final router = GoRouter(
        initialLocation: '/ktm-verification',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Screen Destination')),
            ),
          ),
          GoRoute(
            path: '/ktm-verification',
            builder: (context, state) => const KtmVerificationView(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: regProvider),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final skipButton = find.byKey(const Key('ktm_skip_bottom_button'));
      expect(skipButton, findsOneWidget);
      await tester.ensureVisible(skipButton);
      await tester.pumpAndSettle();
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(find.text('Home Screen Destination'), findsOneWidget);
    });

    testWidgets('skip button pops back when opened from profile', (
      tester,
    ) async {
      final authProvider = AuthProvider();
      authProvider.updateUser(
        const UserModel(
          id: 'usr_mock_1',
          fullName: 'Budi Santoso',
          email: 'budi@student.ub.ac.id',
          phoneNumber: '081234567890',
          nim: '225150201111001',
          verificationStatus: KtmVerificationStatus.unverified,
        ),
      );
      final regProvider = RegistrationProvider();

      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('open_ktm_button'),
                  onPressed: () => context.push('/ktm-verification'),
                  child: const Text('Open KTM'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/ktm-verification',
            builder: (context, state) => const KtmVerificationView(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: regProvider),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_ktm_button')));
      await tester.pumpAndSettle();

      expect(find.text('Verifikasi KTM'), findsOneWidget);

      final skipButton = find.byKey(const Key('ktm_skip_bottom_button'));
      expect(skipButton, findsOneWidget);
      await tester.ensureVisible(skipButton);
      await tester.pumpAndSettle();
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(find.text('Open KTM'), findsOneWidget);
      expect(find.text('Verifikasi KTM'), findsNothing);
    });

    testWidgets('appbar skip button also navigates back or home', (
      tester,
    ) async {
      final authProvider = AuthProvider();
      final regProvider = RegistrationProvider();

      final router = GoRouter(
        initialLocation: '/ktm-verification',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home From AppBar Skip')),
            ),
          ),
          GoRoute(
            path: '/ktm-verification',
            builder: (context, state) => const KtmVerificationView(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: regProvider),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final appbarSkip = find.byKey(const Key('ktm_skip_appbar_button'));
      expect(appbarSkip, findsOneWidget);
      await tester.tap(appbarSkip);
      await tester.pumpAndSettle();

      expect(find.text('Home From AppBar Skip'), findsOneWidget);
    });
  });
}
