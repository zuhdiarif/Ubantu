import 'package:ubantu/domain/models/app_enums.dart';

class ServiceOrderModel {
  final String id;
  final String requesterId;
  final String? helperId;
  final ServiceCategory category;
  final MoveServiceStatus status;
  final String locationOrigin;
  final String locationDestination;
  final DateTime scheduledAt;
  final String itemDescription;
  final BarterType barterType;
  final String barterDescription;
  final String? barterPhotoUrl;
  final VehicleType? vehicleType;
  final double? weightKg;
  final DateTime createdAt;

  const ServiceOrderModel({
    required this.id,
    required this.requesterId,
    this.helperId,
    required this.category,
    required this.status,
    required this.locationOrigin,
    required this.locationDestination,
    required this.scheduledAt,
    required this.itemDescription,
    required this.barterType,
    required this.barterDescription,
    this.barterPhotoUrl,
    this.vehicleType,
    this.weightKg,
    required this.createdAt,
  });

  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) {
    return ServiceOrderModel(
      id: json['id'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      helperId: json['helper_id'] as String?,
      category: ServiceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ServiceCategory.pindahKos,
      ),
      status: MoveServiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MoveServiceStatus.waiting,
      ),
      locationOrigin: json['location_origin'] as String? ?? '',
      locationDestination: json['location_destination'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      itemDescription: json['item_description'] as String? ?? '',
      barterType: BarterType.values.firstWhere(
        (e) => e.name == json['barter_type'],
        orElse: () => BarterType.makanan,
      ),
      barterDescription: json['barter_description'] as String? ?? '',
      barterPhotoUrl: json['barter_photo_url'] as String?,
      vehicleType: json['vehicle_type'] != null
          ? VehicleType.values.firstWhere(
              (e) => e.name == json['vehicle_type'],
              orElse: () => VehicleType.motor,
            )
          : null,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'helper_id': helperId,
      'category': category.name,
      'status': status.name,
      'location_origin': locationOrigin,
      'location_destination': locationDestination,
      'scheduled_at': scheduledAt.toIso8601String(),
      'item_description': itemDescription,
      'barter_type': barterType.name,
      'barter_description': barterDescription,
      'barter_photo_url': barterPhotoUrl,
      'vehicle_type': vehicleType?.name,
      'weight_kg': weightKg,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ServiceOrderModel copyWith({
    String? id,
    String? requesterId,
    String? helperId,
    ServiceCategory? category,
    MoveServiceStatus? status,
    String? locationOrigin,
    String? locationDestination,
    DateTime? scheduledAt,
    String? itemDescription,
    BarterType? barterType,
    String? barterDescription,
    String? barterPhotoUrl,
    VehicleType? vehicleType,
    double? weightKg,
    DateTime? createdAt,
  }) {
    return ServiceOrderModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      helperId: helperId ?? this.helperId,
      category: category ?? this.category,
      status: status ?? this.status,
      locationOrigin: locationOrigin ?? this.locationOrigin,
      locationDestination: locationDestination ?? this.locationDestination,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      itemDescription: itemDescription ?? this.itemDescription,
      barterType: barterType ?? this.barterType,
      barterDescription: barterDescription ?? this.barterDescription,
      barterPhotoUrl: barterPhotoUrl ?? this.barterPhotoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get pickupLocation => locationOrigin;
  String get destinationLocation => locationDestination;
}
