import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/entities/bid_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class PlaceBidUseCase {
  final ServiceRequestRepository repository;

  PlaceBidUseCase(this.repository);

  Future<Either<Failure, BidEntity>> call(BidEntity bid) async {
    return await repository.placeBid(bid);
  }
}
