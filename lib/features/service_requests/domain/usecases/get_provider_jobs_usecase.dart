import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class GetProviderJobsUseCase {
  final ServiceRequestRepository repository;

  GetProviderJobsUseCase(this.repository);

  Stream<Either<Failure, List<ServiceRequestEntity>>> call(String providerId) {
    return repository.getProviderJobs(providerId);
  }
}
