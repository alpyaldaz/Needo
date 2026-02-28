import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/core/usecases/usecase.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class CreateRequestParams {
  final String userId;
  final String categoryId;
  final String title;
  final String description;
  final DateTime date;
  final String priceRange;
  final String address;

  const CreateRequestParams({
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.date,
    required this.priceRange,
    required this.address,
  });
}

class CreateRequestUseCase
    implements UseCase<ServiceRequestEntity, CreateRequestParams> {
  final ServiceRequestRepository repository;

  CreateRequestUseCase(this.repository);

  @override
  Future<Either<Failure, ServiceRequestEntity>> call(
    CreateRequestParams params,
  ) {
    return repository.createRequest(
      userId: params.userId,
      categoryId: params.categoryId,
      title: params.title,
      description: params.description,
      date: params.date,
      status: 'Open',
      priceRange: params.priceRange,
      address: params.address,
    );
  }
}
