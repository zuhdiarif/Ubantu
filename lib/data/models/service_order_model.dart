import 'package:ubantu/data/models/app_enums.dart';

class ServiceOrderModel {
  final String id;
  final String requesterId;
  final String? requesterName;
  final String? helperId;
  final String? helperName;
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
  final bool isFemaleOnly;
  final String? receiverName;
  final String? receiverPhone;
  final String? completionPhotoUrl;
  final DateTime? completedAt;
  final bool barterConfirmedByCustomer;
  final DateTime createdAt;

  const ServiceOrderModel({
    required this.id,
    required this.requesterId,
    this.requesterName,
    this.helperId,
    this.helperName,
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
    this.isFemaleOnly = false,
    this.receiverName,
    this.receiverPhone,
    this.completionPhotoUrl,
    this.completedAt,
    this.barterConfirmedByCustomer = false,
    required this.createdAt,
  });

  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) {
    String? parsedRequesterName;
    final rawReqName = json['requester_name'];
    if (rawReqName is String && rawReqName.trim().isNotEmpty) {
      parsedRequesterName = rawReqName.trim();
    } else if (json['profiles'] is Map) {
      final prof = json['profiles'] as Map;
      final pName = prof['full_name'];
      if (pName is String && pName.trim().isNotEmpty) {
        parsedRequesterName = pName.trim();
      }
    }

    return ServiceOrderModel(
      id: json['id'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      requesterName: parsedRequesterName,
      helperId: json['helper_id'] as String?,
      helperName: json['helper_name'] as String?,
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
      isFemaleOnly: json['is_female_only'] as bool? ?? false,
      receiverName: json['receiver_name'] as String?,
      receiverPhone: json['receiver_phone'] as String?,
      completionPhotoUrl: json['completion_photo_url'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      barterConfirmedByCustomer:
          json['barter_confirmed_by_customer'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      if (requesterName != null && requesterName!.isNotEmpty)
        'requester_name': requesterName,
      'helper_id': helperId,
      'helper_name': helperName,
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
      'is_female_only': isFemaleOnly,
      if (receiverName != null) 'receiver_name': receiverName,
      if (receiverPhone != null) 'receiver_phone': receiverPhone,
      if (completionPhotoUrl != null)
        'completion_photo_url': completionPhotoUrl,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'barter_confirmed_by_customer': barterConfirmedByCustomer,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ServiceOrderModel copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? helperId,
    String? helperName,
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
    bool? isFemaleOnly,
    String? receiverName,
    String? receiverPhone,
    String? completionPhotoUrl,
    DateTime? completedAt,
    bool? barterConfirmedByCustomer,
    DateTime? createdAt,
  }) {
    return ServiceOrderModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      helperId: helperId ?? this.helperId,
      helperName: helperName ?? this.helperName,
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
      isFemaleOnly: isFemaleOnly ?? this.isFemaleOnly,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      completionPhotoUrl: completionPhotoUrl ?? this.completionPhotoUrl,
      completedAt: completedAt ?? this.completedAt,
      barterConfirmedByCustomer:
          barterConfirmedByCustomer ?? this.barterConfirmedByCustomer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get pickupLocation => locationOrigin;
  String get destinationLocation => locationDestination;
}
