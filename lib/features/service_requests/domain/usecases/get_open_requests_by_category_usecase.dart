import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class GetOpenRequestsByCategoryUseCase {
  final ServiceRequestRepository repository;

  GetOpenRequestsByCategoryUseCase(this.repository);

  Stream<Either<Failure, List<ServiceRequestEntity>>> call(String categoryId) {
    return repository.getOpenRequestsByCategory(categoryId);
  }
}
