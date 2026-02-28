import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';

class LogOutUseCase {
  final AuthRepository repository;

  LogOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
