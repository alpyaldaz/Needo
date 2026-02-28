import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needo/features/service_requests/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.providerId,
    required super.customerId,
    required super.customerName,
    super.customerAvatarUrl,
    required super.rating,
    required super.comment,
    required super.photos,
    required super.timestamp,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    return ReviewModel(
      id: id,
      providerId: json['providerId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerAvatarUrl: json['customerAvatarUrl']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatarUrl': customerAvatarUrl,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
