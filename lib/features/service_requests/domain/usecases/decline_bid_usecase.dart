import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class DeclineBidParams {
  final String requestId;
  final String bidId;

  DeclineBidParams({required this.requestId, required this.bidId});
}

class DeclineBidUseCase {
  final ServiceRequestRepository repository;

  DeclineBidUseCase(this.repository);

  Future<Either<Failure, void>> call(DeclineBidParams params) async {
    return await repository.declineBid(params.requestId, params.bidId);
  }
}
