import 'package:ubantu/domain/models/app_enums.dart';

class MitraProfileModel {
  final String id;
  final String userId;
  final String name;
  final String faculty;
  final String phone;
  final String? avatarUrl;
  final bool isOnline;
  final bool isKtmVerified;
  final double rating;
  final int totalReviews;
  final int totalOrdersCompleted;
  final double acceptanceRate;
  final int totalBarterPoints;
  final List<ServiceCategory> selectedCategories;
  final String? vehicleInfo;
  final String? vehiclePlate;

  const MitraProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.faculty,
    required this.phone,
    this.avatarUrl,
    this.isOnline = true,
    this.isKtmVerified = true,
    this.rating = 4.9,
    this.totalReviews = 38,
    this.totalOrdersCompleted = 42,
    this.acceptanceRate = 98.0,
    this.totalBarterPoints = 180,
    this.selectedCategories = const [
      ServiceCategory.pindahKos,
      ServiceCategory.bersihKos,
      ServiceCategory.antarJemput,
    ],
    this.vehicleInfo,
    this.vehiclePlate,
  });

  MitraProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? faculty,
    String? phone,
    String? avatarUrl,
    bool? isOnline,
    bool? isKtmVerified,
    double? rating,
    int? totalReviews,
    int? totalOrdersCompleted,
    double? acceptanceRate,
    int? totalBarterPoints,
    List<ServiceCategory>? selectedCategories,
    String? vehicleInfo,
    String? vehiclePlate,
  }) {
    return MitraProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      isKtmVerified: isKtmVerified ?? this.isKtmVerified,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalOrdersCompleted: totalOrdersCompleted ?? this.totalOrdersCompleted,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      totalBarterPoints: totalBarterPoints ?? this.totalBarterPoints,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    );
  }

  factory MitraProfileModel.fromJson(Map<String, dynamic> json) {
    return MitraProfileModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      faculty: json['faculty'] as String? ?? 'Universitas Brawijaya',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? true,
      isKtmVerified: json['is_ktm_verified'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      totalReviews: json['total_reviews'] as int? ?? 38,
      totalOrdersCompleted: json['total_orders_completed'] as int? ?? 42,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 98.0,
      totalBarterPoints: json['total_barter_points'] as int? ?? 180,
      selectedCategories: (json['selected_categories'] as List<dynamic>?)
              ?.map((e) => ServiceCategory.values.firstWhere(
                    (cat) => cat.name == e,
                    orElse: () => ServiceCategory.antarJemput,
                  ))
              .toList() ??
          const [
            ServiceCategory.pindahKos,
            ServiceCategory.bersihKos,
            ServiceCategory.antarJemput,
          ],
      vehicleInfo: json['vehicle_info'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'faculty': faculty,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'is_ktm_verified': isKtmVerified,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_orders_completed': totalOrdersCompleted,
      'acceptance_rate': acceptanceRate,
      'total_barter_points': totalBarterPoints,
      'selected_categories': selectedCategories.map((e) => e.name).toList(),
      'vehicle_info': vehicleInfo,
      'vehicle_plate': vehiclePlate,
    };
  }
}
