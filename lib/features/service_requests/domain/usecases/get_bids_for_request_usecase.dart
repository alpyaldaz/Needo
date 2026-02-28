import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/entities/bid_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class GetBidsForRequestUseCase {
  final ServiceRequestRepository repository;

  GetBidsForRequestUseCase(this.repository);

  Stream<Either<Failure, List<BidEntity>>> call(String requestId) {
    return repository.getBidsForRequest(requestId);
  }
}
