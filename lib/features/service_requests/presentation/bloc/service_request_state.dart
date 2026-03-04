import 'package:equatable/equatable.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/entities/bid_entity.dart';
import 'package:needo/features/service_requests/domain/entities/review_entity.dart';

abstract class ServiceRequestState extends Equatable {
  const ServiceRequestState();

  @override
  List<Object> get props => [];
}

class ServiceRequestInitial extends ServiceRequestState {}

class ServiceRequestLoading extends ServiceRequestState {}

/// Lightweight loading state for button-level actions (accept bid, place bid, etc.).
/// Does NOT trigger full-screen spinners — only disables action buttons.
class ServiceRequestActionLoading extends ServiceRequestState {}

class ServiceRequestSuccess extends ServiceRequestState {
  final ServiceRequestEntity request;

  const ServiceRequestSuccess(this.request);

  @override
  List<Object> get props => [request];
}

class ServiceRequestError extends ServiceRequestState {
  final String message;

  const ServiceRequestError(this.message);

  @override
  List<Object> get props => [message];
}

class BidPlacedSuccess extends ServiceRequestState {
  final String message;

  const BidPlacedSuccess({this.message = "Bid placed successfully!"});

  @override
  List<Object> get props => [message];
}

class BidDeclinedSuccess extends ServiceRequestState {
  final String message;

  const BidDeclinedSuccess({this.message = "Bid declined successfully."});

  @override
  List<Object> get props => [message];
}

class ServiceRequestCancelled extends ServiceRequestState {}

class ServiceRequestsLoaded extends ServiceRequestState {
  final List<ServiceRequestEntity> requests;

  const ServiceRequestsLoaded(this.requests);

  @override
  List<Object> get props => [requests];
}

class ServiceRequestBidsLoading extends ServiceRequestState {}

class ServiceRequestBidsLoaded extends ServiceRequestState {
  final List<BidEntity> bids;

  const ServiceRequestBidsLoaded(this.bids);

  @override
  List<Object> get props => [bids];
}

class ServiceRequestBidsError extends ServiceRequestState {
  final String message;

  const ServiceRequestBidsError(this.message);

  @override
  List<Object> get props => [message];
}

class BidAcceptedSuccess extends ServiceRequestState {
  final String message;

  const BidAcceptedSuccess({this.message = "Bid accepted successfully!"});

  @override
  List<Object> get props => [message];
}

class JobCompletedSuccess extends ServiceRequestState {
  final String message;

  const JobCompletedSuccess({this.message = "Job completed successfully!"});

  @override
  List<Object> get props => [message];
}

class ProviderRatedSuccess extends ServiceRequestState {
  final String message;

  const ProviderRatedSuccess({this.message = "Provider rated successfully!"});

  @override
  List<Object> get props => [message];
}

class RequestDetailLoaded extends ServiceRequestState {
  final ServiceRequestEntity request;

  const RequestDetailLoaded(this.request);

  @override
  List<Object> get props => [request];
}

class ProviderReviewsLoading extends ServiceRequestState {}

class ProviderReviewsLoaded extends ServiceRequestState {
  final List<ReviewEntity> reviews;

  const ProviderReviewsLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class ProviderReviewsError extends ServiceRequestState {
  final String message;

  const ProviderReviewsError(this.message);

  @override
  List<Object> get props => [message];
}
