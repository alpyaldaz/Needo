import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';

/// Interface defining the contract for Authentication operations.
///
/// The Data layer will implement this abstract class using Firebase,
/// but the Domain layer only depends on this interface.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerCustomer({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, UserEntity>> becomeProvider({
    required String userId,
    required String categoryId,
    required double hourlyRate,
  });

  Future<Either<Failure, UserEntity>> updateUserProfile(
    String userId, {
    String? name,
    String? phone,
    String? profileImageUrl,
    String? googleBusinessUrl,
    String? about,
    String? providerCategory,
  });

  /// Gets the currently logged-in user if available, otherwise returns null safely.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Gets a user by their ID from Firestore.
  Future<Either<Failure, UserEntity>> getUserById(String userId);

  /// Fetches the top-rated providers from Firestore.
  Future<Either<Failure, List<UserEntity>>> getTopProviders();
}
