import 'package:needo/core/error/exceptions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';

/// Implements the [AuthRepository] interface from the Domain layer.
///
/// This class acts as a bridge. It calls the Data Source (Firebase),
/// catches raw Exceptions, and converts them into functional [Either] returns.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      );
      return Right(userModel); // UserModel extends UserEntity
    } on AuthFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerCustomer({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.registerCustomer(
        name: name,
        email: email,
        password: password,
      );
      return Right(userModel);
    } on AuthFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(
        ServerFailure('Registration failed due to an unknown error.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> becomeProvider({
    required String userId,
    required String categoryId,
    required double hourlyRate,
  }) async {
    try {
      final updatedUser = await remoteDataSource.becomeProvider(
        userId: userId,
        categoryId: categoryId,
        hourlyRate: hourlyRate,
      );
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(
    String userId, {
    String? name,
    String? phone,
    String? profileImageUrl,
    String? googleBusinessUrl,
    String? about,
    String? providerCategory,
  }) async {
    try {
      final userModel = await remoteDataSource.updateUserProfile(
        userId,
        name: name,
        phone: phone,
        profileImageUrl: profileImageUrl,
        googleBusinessUrl: googleBusinessUrl,
        about: about,
        providerCategory: providerCategory,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } catch (e) {
      return const Left(ServerFailure('Failed to fetch current user session.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    try {
      final userModel = await remoteDataSource.getUserById(userId);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getTopProviders() async {
    try {
      final providers = await remoteDataSource.getTopProviders();
      return Right(providers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
