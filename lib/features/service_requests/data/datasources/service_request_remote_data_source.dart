import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needo/core/error/exceptions.dart';
import 'package:needo/features/service_requests/data/models/service_request_model.dart';
import 'package:needo/features/service_requests/data/models/bid_model.dart';
import 'package:needo/features/service_requests/data/models/review_model.dart';

abstract class ServiceRequestRemoteDataSource {
  Future<ServiceRequestModel> createRequest({
    required String userId,
    required String categoryId,
    required String title,
    required String description,
    required DateTime date,
    required String status,
    required String priceRange,
    required String address,
  });

  Stream<List<ServiceRequestModel>> getUserRequests(String userId);
  Stream<List<ServiceRequestModel>> getOpenRequestsByCategory(
    String categoryId,
  );
  Stream<List<ServiceRequestModel>> getProviderJobs(String providerId);
  Future<void> cancelRequest(String requestId);
  Future<BidModel> placeBid(BidModel bid);
  Future<void> declineBid(String requestId, String bidId);
  Stream<List<BidModel>> getBidsForRequest(String requestId);
  Future<void> acceptBid(
    String requestId,
    String bidId,
    String providerId,
    double price,
  );
  Future<void> completeJob(String requestId);
  Future<void> rateProvider(
    String requestId,
    String providerId,
    double rating,
    String comment,
    List<String> photos,
  );
  Future<ServiceRequestModel> getRequestById(String id);
  Future<List<ReviewModel>> getProviderReviews(String providerId);
}

class ServiceRequestRemoteDataSourceImpl
    implements ServiceRequestRemoteDataSource {
  final FirebaseFirestore firestore;

  ServiceRequestRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ServiceRequestModel> createRequest({
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
      final requestModel = ServiceRequestModel(
        id: '', // Firestore will generate this
        userId: userId,
        categoryId: categoryId,
        title: title,
        description: description,
        date: date,
        status: status,
        priceRange: priceRange,
        address: address, // Added address
      );

      final docRef = await firestore
          .collection('requests')
          .add(requestModel.toJson());

      // Return the model with the newly generated ID
      return ServiceRequestModel(
        id: docRef.id,
        userId: requestModel.userId,
        categoryId: requestModel.categoryId,
        title: requestModel.title,
        description: requestModel.description,
        date: requestModel.date,
        status: requestModel.status,
        priceRange: requestModel.priceRange,
        address: requestModel.address, // Added address
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<ServiceRequestModel>> getUserRequests(String userId) {
    try {
      return firestore
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ServiceRequestModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      await firestore.collection('requests').doc(requestId).update({
        'status': 'Cancelled',
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<ServiceRequestModel>> getOpenRequestsByCategory(
    String categoryId,
  ) {
    try {
      return firestore
          .collection('requests')
          .where('status', isEqualTo: 'Open')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ServiceRequestModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<ServiceRequestModel>> getProviderJobs(String providerId) {
    try {
      return firestore
          .collection('requests')
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ServiceRequestModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<BidModel> placeBid(BidModel bid) async {
    try {
      final requestRef = firestore.collection('requests').doc(bid.requestId);

      // Store the bid in the bids subcollection
      final docRef = await requestRef.collection('bids').add(bid.toJson());

      return BidModel(
        id: docRef.id,
        requestId: bid.requestId,
        providerId: bid.providerId,
        providerName: bid.providerName,
        amount: bid.amount,
        note: bid.note,
        createdAt: bid.createdAt,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> declineBid(String requestId, String bidId) async {
    try {
      await firestore
          .collection('requests')
          .doc(requestId)
          .collection('bids')
          .doc(bidId)
          .delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<BidModel>> getBidsForRequest(String requestId) {
    try {
      return firestore
          .collection('requests')
          .doc(requestId)
          .collection('bids')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BidModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> acceptBid(
    String requestId,
    String bidId,
    String providerId,
    double price,
  ) async {
    try {
      await firestore.collection('requests').doc(requestId).update({
        'status': 'In Progress',
        'providerId': providerId,
        'acceptedBidId': bidId,
        'price': price,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> completeJob(String requestId) async {
    try {
      await firestore.collection('requests').doc(requestId).update({
        'status': 'Completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> rateProvider(
    String requestId,
    String providerId,
    double rating,
    String comment,
    List<String> photos,
  ) async {
    try {
      await firestore.runTransaction((transaction) async {
        // 1. Get Request
        final requestRef = firestore.collection('requests').doc(requestId);
        final requestDoc = await transaction.get(requestRef);
        if (!requestDoc.exists) throw Exception("Request not found");
        final customerId = requestDoc.data()?['userId']?.toString() ?? '';

        // 2. Get Customer Details
        final customerRef = firestore.collection('users').doc(customerId);
        final customerDoc = await transaction.get(customerRef);
        final customerName =
            customerDoc.data()?['name']?.toString() ?? 'Unknown Customer';
        final customerAvatarUrl = customerDoc
            .data()?['profileImageUrl']
            ?.toString();

        // 3. Get Provider Details
        final providerRef = firestore.collection('users').doc(providerId);
        final providerDoc = await transaction.get(providerRef);
        int currentCount = providerDoc.data()?['reviewCount'] as int? ?? 0;
        double currentAvg =
            (providerDoc.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;

        // Get current rating distribution
        final rawDist = providerDoc.data()?['ratingDistribution'];
        final Map<String, int> currentDist = {
          '1': 0,
          '2': 0,
          '3': 0,
          '4': 0,
          '5': 0,
        };
        if (rawDist != null && rawDist is Map) {
          for (final key in ['1', '2', '3', '4', '5']) {
            currentDist[key] = (rawDist[key] as num?)?.toInt() ?? 0;
          }
        }

        // Calculate new stats
        int newCount = currentCount + 1;
        double newAvg = ((currentAvg * currentCount) + rating) / newCount;

        // Increment the star bucket (round to nearest int for the bucket key)
        final starKey = rating.round().clamp(1, 5).toString();
        currentDist[starKey] = (currentDist[starKey] ?? 0) + 1;

        // 4. Create Review
        final reviewRef = providerRef.collection('reviews').doc();
        final review = ReviewModel(
          id: reviewRef.id,
          providerId: providerId,
          customerId: customerId,
          customerName: customerName,
          customerAvatarUrl: customerAvatarUrl,
          rating: rating,
          comment: comment,
          photos: photos,
          timestamp: DateTime.now(),
        );

        // 5. Perform Writes
        transaction.set(reviewRef, review.toJson());
        transaction.update(providerRef, {
          'reviewCount': newCount,
          'averageRating': newAvg,
          'ratingDistribution': currentDist,
        });
        transaction.update(requestRef, {
          'providerRating': rating,
          'providerReview': comment,
        });
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceRequestModel> getRequestById(String id) async {
    try {
      final doc = await firestore.collection('requests').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return ServiceRequestModel.fromJson(doc.data()!, doc.id);
      } else {
        throw ServerException(message: 'Request not found');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ReviewModel>> getProviderReviews(String providerId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(providerId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
