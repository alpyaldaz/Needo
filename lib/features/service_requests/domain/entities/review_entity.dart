import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String providerId;
  final String customerId;
  final String customerName;
  final String? customerAvatarUrl;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime timestamp;

  const ReviewEntity({
    required this.id,
    required this.providerId,
    required this.customerId,
    required this.customerName,
    this.customerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.photos,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    providerId,
    customerId,
    customerName,
    customerAvatarUrl,
    rating,
    comment,
    photos,
    timestamp,
  ];
}
