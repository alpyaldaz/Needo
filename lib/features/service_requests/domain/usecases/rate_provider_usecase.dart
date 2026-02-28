import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class RateProviderUseCase {
  final ServiceRequestRepository repository;

  RateProviderUseCase(this.repository);

  Future<Either<Failure, void>> call(RateProviderParams params) async {
    return await repository.rateProvider(
      params.requestId,
      params.providerId,
      params.rating,
      params.comment,
      params.photos,
    );
  }
}

class RateProviderParams {
  final String requestId;
  final String providerId;
  final double rating;
  final String comment;
  final List<String> photos;

  RateProviderParams({
    required this.requestId,
    required this.providerId,
    required this.rating,
    required this.comment,
    this.photos = const [],
  });
}
