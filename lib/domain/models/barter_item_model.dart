import 'package:ubantu/domain/models/app_enums.dart';

class BarterItemModel {
  final String id;
  final String title;
  final String description;
  final BarterType type;
  final String iconAsset;

  const BarterItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.iconAsset,
  });

  factory BarterItemModel.fromJson(Map<String, dynamic> json) {
    return BarterItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: BarterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BarterType.makanan,
      ),
      iconAsset: json['icon_asset'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'icon_asset': iconAsset,
    };
  }
}
