import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class CancelRequestUseCase {
  final ServiceRequestRepository repository;

  CancelRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.cancelRequest(requestId);
  }
}
