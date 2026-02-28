import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class GetRequestByIdUseCase {
  final ServiceRequestRepository repository;

  GetRequestByIdUseCase(this.repository);

  Future<Either<Failure, ServiceRequestEntity>> call(String id) async {
    return await repository.getRequestById(id);
  }
}
