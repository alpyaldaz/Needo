import 'package:equatable/equatable.dart';

class ServiceRequestEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final String title;
  final String description;
  final DateTime date;
  final String status;
  final String priceRange;
  final String address;
  final String? providerId;
  final double? providerRating;
  final String? providerReview;

  // Timeline tracking
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const ServiceRequestEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.priceRange,
    required this.address,
    this.providerId,
    this.providerRating,
    this.providerReview,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    title,
    description,
    date,
    status,
    priceRange,
    address,
    providerId,
    providerRating,
    providerReview,
    createdAt,
    acceptedAt,
    completedAt,
  ];
}
