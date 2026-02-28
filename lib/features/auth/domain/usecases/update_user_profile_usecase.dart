import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    UpdateUserProfileParams params,
  ) async {
    return await repository.updateUserProfile(
      params.userId,
      name: params.name,
      phone: params.phone,
      profileImageUrl: params.profileImageUrl,
      googleBusinessUrl: params.googleBusinessUrl,
      about: params.about,
      providerCategory: params.providerCategory,
    );
  }
}

class UpdateUserProfileParams {
  final String userId;
  final String? name;
  final String? phone;
  final String? profileImageUrl;
  final String? googleBusinessUrl;
  final String? about;
  final String? providerCategory;

  UpdateUserProfileParams({
    required this.userId,
    this.name,
    this.phone,
    this.profileImageUrl,
    this.googleBusinessUrl,
    this.about,
    this.providerCategory,
  });
}
