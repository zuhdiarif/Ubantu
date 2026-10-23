class MitraEarningItemModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final String serviceTitle;
  final DateTime date;
  final String barterDescription;
  final int pointsEarned;
  final String customerName;

  const MitraEarningItemModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.serviceTitle,
    required this.date,
    required this.barterDescription,
    required this.pointsEarned,
    required this.customerName,
  });

  MitraEarningItemModel copyWith({
    String? id,
    String? orderId,
    String? orderNumber,
    String? serviceTitle,
    DateTime? date,
    String? barterDescription,
    int? pointsEarned,
    String? customerName,
  }) {
    return MitraEarningItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      date: date ?? this.date,
      barterDescription: barterDescription ?? this.barterDescription,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      customerName: customerName ?? this.customerName,
    );
  }

  factory MitraEarningItemModel.fromJson(Map<String, dynamic> json) {
    return MitraEarningItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      serviceTitle: json['service_title'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      barterDescription: json['barter_description'] as String? ?? '',
      pointsEarned: json['points_earned'] as int? ?? 10,
      customerName: json['customer_name'] as String? ?? 'Mahasiswa UB',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_number': orderNumber,
      'service_title': serviceTitle,
      'date': date.toIso8601String(),
      'barter_description': barterDescription,
      'points_earned': pointsEarned,
      'customer_name': customerName,
    };
  }
}
