import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';

class BecomeProviderParams {
  final String userId;
  final String categoryId;
  final double hourlyRate;

  BecomeProviderParams({
    required this.userId,
    required this.categoryId,
    required this.hourlyRate,
  });
}

class BecomeProviderUseCase {
  final AuthRepository repository;

  BecomeProviderUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(BecomeProviderParams params) async {
    return await repository.becomeProvider(
      userId: params.userId,
      categoryId: params.categoryId,
      hourlyRate: params.hourlyRate,
    );
  }
}
