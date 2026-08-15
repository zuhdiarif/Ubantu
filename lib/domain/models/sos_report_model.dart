import 'package:ubantu/domain/models/app_enums.dart';

class SosReportModel {
  final String id;
  final String userId;
  final String issueType;
  final SosStatus status;
  final DateTime createdAt;

  const SosReportModel({
    required this.id,
    required this.userId,
    required this.issueType,
    required this.status,
    required this.createdAt,
  });

  factory SosReportModel.fromJson(Map<String, dynamic> json) {
    return SosReportModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      issueType: json['issue_type'] as String? ?? '',
      status: SosStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SosStatus.received,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'issue_type': issueType,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
