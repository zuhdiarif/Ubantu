import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/profile_provider.dart';
import 'package:ubantu/presentation/views/profil_view.dart';

void main() {
  group('ProfileProvider Unit Tests', () {
    test('ProfileProvider initial state and task increment', () {
      final provider = ProfileProvider();
      expect(provider.profileStats.completedTasksCount, 12);
      expect(provider.profileStats.volunteerPoints, 150);

      provider.incrementCompletedTask();
      expect(provider.profileStats.completedTasksCount, 13);
      expect(provider.profileStats.volunteerPoints, 160);
    });
  });

  group('AuthProvider Profile & KTM Unit Tests', () {
    test('AuthProvider updateUser updates currentUser state', () {
      final auth = AuthProvider();
      const user = UserModel(
        id: 'usr_test_1',
        fullName: 'Mahasiswi UB',
        email: 'mahasiswi@student.ub.ac.id',
        phoneNumber: '081234567891',
        nim: '245150200111002',
        avatarUrl: 'https://example.com/avatar.jpg',
        verificationStatus: KtmVerificationStatus.verified,
        gender: UserGender.female,
        isFemaleOnlyPreferred: true,
      );

      auth.updateUser(user);
      expect(auth.currentUser?.fullName, 'Mahasiswi UB');
      expect(auth.currentUser?.avatarUrl, 'https://example.com/avatar.jpg');
      expect(auth.currentUser?.gender, UserGender.female);
      expect(auth.currentUser?.isFemaleOnlyPreferred, true);
    });

    test('AuthProvider updateProfile modifies user fields', () async {
      final auth = AuthProvider();
      await auth.updateProfile(
        fullName: 'Zuhdi Arif',
        phoneNumber: '089876543210',
        gender: UserGender.male,
        isFemaleOnlyPreferred: false,
      );

      expect(auth.currentUser?.fullName, 'Zuhdi Arif');
      expect(auth.currentUser?.phoneNumber, '089876543210');
      expect(auth.currentUser?.gender, UserGender.male);
      expect(auth.currentUser?.isFemaleOnlyPreferred, false);
    });
  });

  group('ProfilView Widget Tests', () {
    testWidgets('ProfilView renders profile options and does not contain Mode Mitra button', (tester) async {
      final auth = AuthProvider();
      auth.updateUser(const UserModel(
        id: 'usr_farel',
        fullName: 'Ahmad Farel',
        email: 'farel@student.ub.ac.id',
        phoneNumber: '081234567890',
        nim: '245150200111001',
        verificationStatus: KtmVerificationStatus.verified,
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

      expect(find.text('Profil Pengguna'), findsOneWidget);
      expect(find.text('Ahmad Farel'), findsOneWidget);
      expect(find.text('farel@student.ub.ac.id'), findsOneWidget);
      expect(find.text('KTM UB Terverifikasi'), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Ubah Foto Profil'), findsOneWidget);
      expect(find.text('Verifikasi KTM UB'), findsOneWidget);
      expect(find.text('Mode Mitra (Bantu Mahasiswa Lain)'), findsNothing);
    });
  });
}
