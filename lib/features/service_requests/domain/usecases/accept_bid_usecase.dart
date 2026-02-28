import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class AcceptBidUseCase {
  final ServiceRequestRepository repository;

  AcceptBidUseCase(this.repository);

  Future<Either<Failure, void>> call(AcceptBidParams params) async {
    return await repository.acceptBid(
      params.requestId,
      params.bidId,
      params.providerId,
      params.price,
    );
  }
}

class AcceptBidParams {
  final String requestId;
  final String bidId;
  final String providerId;
  final double price;

  AcceptBidParams({
    required this.requestId,
    required this.bidId,
    required this.providerId,
    required this.price,
  });
}
