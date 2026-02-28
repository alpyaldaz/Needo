import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/entities/review_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class GetProviderReviewsUseCase {
  final ServiceRequestRepository repository;

  GetProviderReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(String providerId) {
    return repository.getProviderReviews(providerId);
  }
}
