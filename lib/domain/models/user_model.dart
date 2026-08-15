import 'package:ubantu/domain/models/app_enums.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String nim;
  final String? ktmPhotoUrl;
  final KtmVerificationStatus verificationStatus;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.nim,
    this.ktmPhotoUrl,
    this.verificationStatus = KtmVerificationStatus.unverified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      nim: json['nim'] as String? ?? '',
      ktmPhotoUrl: json['ktm_photo_url'] as String?,
      verificationStatus: KtmVerificationStatus.values.firstWhere(
        (e) => e.name == json['verification_status'],
        orElse: () => KtmVerificationStatus.unverified,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'nim': nim,
      'ktm_photo_url': ktmPhotoUrl,
      'verification_status': verificationStatus.name,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? nim,
    String? ktmPhotoUrl,
    KtmVerificationStatus? verificationStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nim: nim ?? this.nim,
      ktmPhotoUrl: ktmPhotoUrl ?? this.ktmPhotoUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
