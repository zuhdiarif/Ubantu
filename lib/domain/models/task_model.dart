import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';

class TaskModel {
  final String id;
  final String title;
  final String requesterName;
  final double rating;
  final int ratingCount;
  final ServiceCategory category;
  final String location;
  final String date;
  final String time;
  final String notes;
  final TaskStatus status;
  final bool isFemaleOnly;
  final bool isEmergency;
  final int rewardPoints;

  const TaskModel({
    required this.id,
    required this.title,
    required this.requesterName,
    required this.rating,
    required this.ratingCount,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    required this.notes,
    this.status = TaskStatus.pending,
    this.isFemaleOnly = false,
    this.isEmergency = false,
    this.rewardPoints = 10,
  });

  static String _categoryLabel(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.pindahKos:
        return 'Pindah Kos';
      case ServiceCategory.bersihKos:
        return 'Bersih Kos';
      case ServiceCategory.antarJemput:
        return 'Antar Jemput';
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final category = ServiceCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => ServiceCategory.bersihKos,
    );

    final rawTitle = json['title'] as String?;
    final rawItemDescription = json['item_description'] as String?;
    final String title;
    if (rawTitle != null && rawTitle.trim().isNotEmpty) {
      title = rawTitle;
    } else if (rawItemDescription != null && rawItemDescription.trim().isNotEmpty) {
      title = rawItemDescription;
    } else {
      title = 'Bantuan ${_categoryLabel(category)}';
    }

    final rawRequester = json['requester_name'] as String? ??
        (json['profiles'] is Map ? (json['profiles'] as Map)['full_name'] as String? : null);
    final rawReceiver = json['receiver_name'] as String?;
    final String requesterName;
    if (rawRequester != null && rawRequester.trim().isNotEmpty) {
      requesterName = rawRequester.trim();
    } else if (rawReceiver != null && rawReceiver.trim().isNotEmpty) {
      requesterName = rawReceiver.trim();
    } else {
      requesterName = 'Mahasiswa UB';
    }

    final rawLocation = json['location'] as String?;
    final rawLocationOrigin = json['location_origin'] as String?;
    final String location;
    if (rawLocation != null && rawLocation.trim().isNotEmpty) {
      location = rawLocation;
    } else if (rawLocationOrigin != null && rawLocationOrigin.trim().isNotEmpty) {
      location = rawLocationOrigin;
    } else {
      location = 'Universitas Brawijaya';
    }

    final rawDate = json['date'] as String?;
    final rawTime = json['time'] as String?;
    final scheduledAtStr = json['scheduled_at']?.toString();
    final scheduledDt = scheduledAtStr != null ? DateTime.tryParse(scheduledAtStr)?.toLocal() : null;

    final String date;
    if (rawDate != null && rawDate.trim().isNotEmpty) {
      date = rawDate;
    } else if (scheduledDt != null) {
      date = '${scheduledDt.day.toString().padLeft(2, '0')}/${scheduledDt.month.toString().padLeft(2, '0')}/${scheduledDt.year}';
    } else {
      date = 'Hari ini';
    }

    final String time;
    if (rawTime != null && rawTime.trim().isNotEmpty) {
      time = rawTime;
    } else if (scheduledDt != null) {
      time = '${scheduledDt.hour.toString().padLeft(2, '0')}:${scheduledDt.minute.toString().padLeft(2, '0')} WIB';
    } else {
      time = '10:00 WIB';
    }

    final rawNotes = json['notes'] as String?;
    final rawBarterDescription = json['barter_description'] as String?;
    final String notes;
    if (rawNotes != null && rawNotes.trim().isNotEmpty) {
      notes = rawNotes;
    } else if (rawBarterDescription != null && rawBarterDescription.trim().isNotEmpty) {
      notes = rawBarterDescription;
    } else if (rawItemDescription != null && rawItemDescription.trim().isNotEmpty) {
      notes = rawItemDescription;
    } else {
      notes = '';
    }

    final rawStatus = json['status']?.toString();
    final TaskStatus status;
    switch (rawStatus) {
      case 'accepted':
      case 'inProgress':
      case 'menujuLokasi':
      case 'tiba':
      case 'dikerjakan':
      case 'dalamPengantaran':
        status = TaskStatus.inProgress;
        break;
      case 'completed':
        status = TaskStatus.completed;
        break;
      case 'cancelled':
      case 'dibatalkan':
        status = TaskStatus.cancelled;
        break;
      case 'waiting':
      case 'searching':
      case 'terjadwal':
      case 'pending':
      default:
        status = TaskStatus.pending;
        break;
    }

    return TaskModel(
      id: json['id'] as String? ?? '',
      title: title,
      requesterName: requesterName,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      category: category,
      location: location,
      date: date,
      time: time,
      notes: notes,
      status: status,
      isFemaleOnly: json['is_female_only'] as bool? ?? false,
      isEmergency: json['is_emergency'] as bool? ?? false,
      rewardPoints: (json['reward_points'] as num?)?.toInt() ?? 10,
    );
  }

  factory TaskModel.fromServiceOrder(ServiceOrderModel order) {
    final json = order.toJson();
    if (order.requesterName != null && order.requesterName!.trim().isNotEmpty) {
      json['requester_name'] = order.requesterName!.trim();
    }
    return TaskModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'requester_name': requesterName,
      'rating': rating,
      'rating_count': ratingCount,
      'category': category.name,
      'location': location,
      'date': date,
      'time': time,
      'notes': notes,
      'status': status.name,
      'is_female_only': isFemaleOnly,
      'is_emergency': isEmergency,
      'reward_points': rewardPoints,
    };
  }
}
