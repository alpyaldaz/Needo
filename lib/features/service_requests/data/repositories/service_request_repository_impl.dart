import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/exceptions.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/data/datasources/service_request_remote_data_source.dart';
import 'package:needo/features/service_requests/data/models/bid_model.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/entities/bid_entity.dart';
import 'package:needo/features/service_requests/domain/entities/review_entity.dart';
import 'package:needo/features/service_requests/domain/repositories/service_request_repository.dart';

class ServiceRequestRepositoryImpl implements ServiceRequestRepository {
  final ServiceRequestRemoteDataSource remoteDataSource;

  ServiceRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ServiceRequestEntity>> createRequest({
    required String userId,
    required String categoryId,
    required String title,
    required String description,
    required DateTime date,
    required String status,
    required String priceRange,
    required String address,
  }) async {
    try {
      final model = await remoteDataSource.createRequest(
        userId: userId,
        categoryId: categoryId,
        title: title,
        description: description,
        date: date,
        status: status,
        priceRange: priceRange,
        address: address,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ServiceRequestEntity>>> getProviderJobs(
    String providerId,
  ) {
    return remoteDataSource
        .getProviderJobs(providerId)
        .map((models) {
          return Right<Failure, List<ServiceRequestEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<ServiceRequestEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Stream<Either<Failure, List<ServiceRequestEntity>>> getUserRequests(
    String userId,
  ) {
    return remoteDataSource
        .getUserRequests(userId)
        .map((models) {
          return Right<Failure, List<ServiceRequestEntity>>(models);
        })
        .handleError((error) {
          // In a real app we would yield a Stream with a Left(Failure)
          // Here we need to map the error to our Failure type within the stream.
          return Left<Failure, List<ServiceRequestEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Future<Either<Failure, void>> cancelRequest(String requestId) async {
    try {
      await remoteDataSource.cancelRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ServiceRequestEntity>>> getOpenRequestsByCategory(
    String categoryId,
  ) {
    return remoteDataSource
        .getOpenRequestsByCategory(categoryId)
        .map((models) {
          return Right<Failure, List<ServiceRequestEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<ServiceRequestEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Future<Either<Failure, BidEntity>> placeBid(BidEntity bid) async {
    try {
      final bidModel = BidModel(
        id: bid.id,
        requestId: bid.requestId,
        providerId: bid.providerId,
        providerName: bid.providerName,
        amount: bid.amount,
        note: bid.note,
        createdAt: bid.createdAt,
      );
      final storedModel = await remoteDataSource.placeBid(bidModel);
      return Right(storedModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<BidEntity>>> getBidsForRequest(String requestId) {
    return remoteDataSource
        .getBidsForRequest(requestId)
        .map((models) {
          return Right<Failure, List<BidEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<BidEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Future<Either<Failure, void>> declineBid(
    String requestId,
    String bidId,
  ) async {
    try {
      await remoteDataSource.declineBid(requestId, bidId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptBid(
    String requestId,
    String bidId,
    String providerId,
    double price,
  ) async {
    try {
      await remoteDataSource.acceptBid(requestId, bidId, providerId, price);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeJob(String requestId) async {
    try {
      await remoteDataSource.completeJob(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rateProvider(
    String requestId,
    String providerId,
    double rating,
    String comment,
    List<String> photos,
  ) async {
    try {
      await remoteDataSource.rateProvider(
        requestId,
        providerId,
        rating,
        comment,
        photos,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceRequestEntity>> getRequestById(
    String id,
  ) async {
    try {
      final request = await remoteDataSource.getRequestById(id);
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProviderReviews(
    String providerId,
  ) async {
    try {
      final reviewModels = await remoteDataSource.getProviderReviews(
        providerId,
      );
      final reviewEntities = reviewModels
          .map(
            (m) => ReviewEntity(
              id: m.id,
              providerId: m.providerId,
              customerId: m.customerId,
              customerName: m.customerName,
              customerAvatarUrl: m.customerAvatarUrl,
              rating: m.rating,
              comment: m.comment,
              photos: m.photos,
              timestamp: m.timestamp,
            ),
          )
          .toList();
      return Right(reviewEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
