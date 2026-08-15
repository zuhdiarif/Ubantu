class RewardPointsModel {
  final String userId;
  final int totalPoints;
  final int availableVouchers;
  final List<String> claimedVoucherCodes;

  const RewardPointsModel({
    required this.userId,
    this.totalPoints = 0,
    this.availableVouchers = 0,
    this.claimedVoucherCodes = const [],
  });

  factory RewardPointsModel.fromJson(Map<String, dynamic> json) {
    return RewardPointsModel(
      userId: json['user_id'] as String? ?? '',
      totalPoints: json['total_points'] as int? ?? 0,
      availableVouchers: json['available_vouchers'] as int? ?? 0,
      claimedVoucherCodes: (json['claimed_voucher_codes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_points': totalPoints,
      'available_vouchers': availableVouchers,
      'claimed_voucher_codes': claimedVoucherCodes,
    };
  }

  RewardPointsModel copyWith({
    String? userId,
    int? totalPoints,
    int? availableVouchers,
    List<String>? claimedVoucherCodes,
  }) {
    return RewardPointsModel(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      availableVouchers: availableVouchers ?? this.availableVouchers,
      claimedVoucherCodes: claimedVoucherCodes ?? this.claimedVoucherCodes,
    );
  }
}
