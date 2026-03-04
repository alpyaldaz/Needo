import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/entities/bid_entity.dart';
import 'package:needo/features/service_requests/domain/entities/review_entity.dart';

abstract class ServiceRequestRepository {
  Future<Either<Failure, ServiceRequestEntity>> createRequest({
    required String userId,
    required String categoryId,
    required String title,
    required String description,
    required DateTime date,
    required String status,
    required String priceRange,
    required String address,
  });

  Stream<Either<Failure, List<ServiceRequestEntity>>> getUserRequests(
    String userId,
  );

  Stream<Either<Failure, List<ServiceRequestEntity>>> getOpenRequestsByCategory(
    String categoryId,
  );

  Stream<Either<Failure, List<ServiceRequestEntity>>> getProviderJobs(
    String providerId,
  );

  Future<Either<Failure, void>> cancelRequest(String requestId);

  Future<Either<Failure, BidEntity>> placeBid(BidEntity bid);

  Stream<Either<Failure, List<BidEntity>>> getBidsForRequest(String requestId);

  Future<Either<Failure, void>> declineBid(String requestId, String bidId);

  Future<Either<Failure, void>> acceptBid(
    String requestId,
    String bidId,
    String providerId,
    double price,
  );
  Future<Either<Failure, void>> completeJob(String requestId);
  Future<Either<Failure, void>> rateProvider(
    String requestId,
    String providerId,
    double rating,
    String comment,
    List<String> photos,
  );
  Future<Either<Failure, ServiceRequestEntity>> getRequestById(String id);
  Future<Either<Failure, List<ReviewEntity>>> getProviderReviews(
    String providerId,
  );
}
