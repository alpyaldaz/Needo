import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class CompleteJobUseCase {
  final ServiceRequestRepository repository;

  CompleteJobUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.completeJob(requestId);
  }
}
