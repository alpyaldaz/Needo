import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';

class GetTopProvidersUseCase {
  final AuthRepository repository;
  GetTopProvidersUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call() {
    return repository.getTopProviders();
  }
}
