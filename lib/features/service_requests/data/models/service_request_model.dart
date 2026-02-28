import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';

class ServiceRequestModel extends ServiceRequestEntity {
  const ServiceRequestModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.title,
    required super.description,
    required super.date,
    required super.status,
    required super.priceRange,
    required super.address,
    super.providerId,
    super.providerRating,
    super.providerReview,
    super.createdAt,
    super.acceptedAt,
    super.completedAt,
  });

  factory ServiceRequestModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return ServiceRequestModel(
      id: documentId,
      userId: json['userId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status']?.toString() ?? 'Open',
      priceRange: json['priceRange']?.toString() ?? '',
      address: json['address']?.toString() ?? 'Not provided',
      providerId: json['providerId']?.toString(),
      providerRating: json['providerRating'] != null
          ? (json['providerRating'] as num).toDouble()
          : null,
      providerReview: json['providerReview']?.toString(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      acceptedAt: json['acceptedAt'] != null
          ? (json['acceptedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'status': status,
      'priceRange': priceRange,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
      if (providerId != null) 'providerId': providerId,
      if (providerRating != null) 'providerRating': providerRating,
      if (providerReview != null) 'providerReview': providerReview,
    };
  }
}
