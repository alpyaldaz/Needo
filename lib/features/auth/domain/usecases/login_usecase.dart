import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/core/usecases/usecase.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

/// A specific business rule definition: Logging into Needo.
/// It delegates the data-fetching mechanism to the abstract [AuthRepository].
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}
