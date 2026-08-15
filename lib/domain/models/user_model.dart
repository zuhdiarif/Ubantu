import 'package:ubantu/domain/models/app_enums.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String nim;
  final String? ktmPhotoUrl;
  final String? avatarUrl;
  final KtmVerificationStatus verificationStatus;
  final UserRole role;
  final UserGender gender;
  final bool isFemaleOnlyPreferred;
  final int rewardPoints;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.nim,
    this.ktmPhotoUrl,
    this.avatarUrl,
    this.verificationStatus = KtmVerificationStatus.unverified,
    this.role = UserRole.customer,
    this.gender = UserGender.unspecified,
    this.isFemaleOnlyPreferred = false,
    this.rewardPoints = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      nim: json['nim'] as String? ?? '',
      ktmPhotoUrl: json['ktm_photo_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      verificationStatus: KtmVerificationStatus.values.firstWhere(
        (e) => e.name == json['verification_status'],
        orElse: () => KtmVerificationStatus.unverified,
      ),
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      gender: UserGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => UserGender.unspecified,
      ),
      isFemaleOnlyPreferred: json['is_female_only_preferred'] as bool? ?? false,
      rewardPoints: json['reward_points'] as int? ?? 0,
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
      'avatar_url': avatarUrl,
      'verification_status': verificationStatus.name,
      'role': role.name,
      'gender': gender.name,
      'is_female_only_preferred': isFemaleOnlyPreferred,
      'reward_points': rewardPoints,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? nim,
    String? ktmPhotoUrl,
    String? avatarUrl,
    KtmVerificationStatus? verificationStatus,
    UserRole? role,
    UserGender? gender,
    bool? isFemaleOnlyPreferred,
    int? rewardPoints,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nim: nim ?? this.nim,
      ktmPhotoUrl: ktmPhotoUrl ?? this.ktmPhotoUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      isFemaleOnlyPreferred: isFemaleOnlyPreferred ?? this.isFemaleOnlyPreferred,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }
}
