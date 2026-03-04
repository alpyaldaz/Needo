import 'package:equatable/equatable.dart';

abstract class ServiceRequestEvent extends Equatable {
  const ServiceRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyRequestsEvent extends ServiceRequestEvent {}

class CancelRequestEvent extends ServiceRequestEvent {
  final String requestId;

  const CancelRequestEvent(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class CreateServiceRequestEvent extends ServiceRequestEvent {
  // Normally userId comes from the AuthBloc/Session, but we pass it explicitly here for completeness
  // or fetch it within the Bloc if injected. We'll pass it from UI/Bloc for now.
  final String categoryId;
  final String title;
  final String description;
  final DateTime date;
  final String priceRange;
  final String address;

  const CreateServiceRequestEvent({
    required this.categoryId,
    required this.title,
    required this.description,
    required this.date,
    required this.priceRange,
    required this.address,
  });

  @override
  List<Object> get props => [
    categoryId,
    title,
    description,
    date,
    priceRange,
    address,
  ];
}

class FetchOpenRequestsByCategoryEvent extends ServiceRequestEvent {
  final String categoryId;

  const FetchOpenRequestsByCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class FetchProviderJobsEvent extends ServiceRequestEvent {
  const FetchProviderJobsEvent();
}

class PlaceBidEvent extends ServiceRequestEvent {
  final String requestId;
  final double price;
  final String note;
  final String providerName;

  const PlaceBidEvent({
    required this.requestId,
    required this.price,
    required this.note,
    required this.providerName,
  });

  @override
  List<Object> get props => [requestId, price, note, providerName];
}

class LoadBidsForRequestEvent extends ServiceRequestEvent {
  final String requestId;

  const LoadBidsForRequestEvent(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class AcceptBidEvent extends ServiceRequestEvent {
  final String requestId;
  final String bidId;
  final String providerId;
  final double price;

  const AcceptBidEvent({
    required this.requestId,
    required this.bidId,
    required this.providerId,
    required this.price,
  });

  @override
  List<Object> get props => [requestId, bidId, providerId, price];
}

class DeclineBidEvent extends ServiceRequestEvent {
  final String requestId;
  final String bidId;

  const DeclineBidEvent({required this.requestId, required this.bidId});

  @override
  List<Object> get props => [requestId, bidId];
}

class CompleteJobEvent extends ServiceRequestEvent {
  final String requestId;
  final String? providerId;
  final double? rating;
  final String? comment;
  final List<String>? photos;

  const CompleteJobEvent({
    required this.requestId,
    this.providerId,
    this.rating,
    this.comment,
    this.photos,
  });

  @override
  List<Object?> get props => [requestId, providerId, rating, comment, photos];
}

class RateProviderEvent extends ServiceRequestEvent {
  final String requestId;
  final String providerId;
  final double rating;
  final String comment;
  final List<String> photos;

  const RateProviderEvent({
    required this.requestId,
    required this.providerId,
    required this.rating,
    required this.comment,
    this.photos = const [],
  });

  @override
  List<Object> get props => [requestId, providerId, rating, comment, photos];
}

class LoadRequestDetailEvent extends ServiceRequestEvent {
  final String requestId;

  const LoadRequestDetailEvent(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class LoadProviderReviewsEvent extends ServiceRequestEvent {
  final String providerId;

  const LoadProviderReviewsEvent(this.providerId);

  @override
  List<Object> get props => [providerId];
}
