import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/domain/usecases/create_request_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/get_user_requests_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/cancel_request_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/get_open_requests_by_category_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/place_bid_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/get_bids_for_request_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/accept_bid_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/complete_job_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/rate_provider_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/get_request_by_id_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/get_provider_jobs_usecase.dart';
import 'package:needo/features/service_requests/domain/usecases/get_provider_reviews_usecase.dart';
import 'package:needo/features/service_requests/domain/entities/bid_entity.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';

class ServiceRequestBloc
    extends Bloc<ServiceRequestEvent, ServiceRequestState> {
  final CreateRequestUseCase createRequestUseCase;
  final GetUserRequestsUseCase getUserRequestsUseCase;
  final CancelRequestUseCase cancelRequestUseCase;
  final GetOpenRequestsByCategoryUseCase getOpenRequestsByCategoryUseCase;
  final PlaceBidUseCase placeBidUseCase;
  final GetBidsForRequestUseCase getBidsForRequestUseCase;
  final AcceptBidUseCase acceptBidUseCase;
  final CompleteJobUseCase completeJobUseCase;
  final RateProviderUseCase rateProviderUseCase;
  final GetRequestByIdUseCase getRequestByIdUseCase;
  final GetProviderJobsUseCase getProviderJobsUseCase;
  final GetProviderReviewsUseCase getProviderReviewsUseCase;
  final FirebaseAuth firebaseAuth;

  List<ServiceRequestEntity> currentRequests = [];

  StreamSubscription? _requestsSubscription;
  StreamSubscription? _bidsSubscription;

  ServiceRequestBloc({
    required this.createRequestUseCase,
    required this.getUserRequestsUseCase,
    required this.cancelRequestUseCase,
    required this.getOpenRequestsByCategoryUseCase,
    required this.placeBidUseCase,
    required this.getBidsForRequestUseCase,
    required this.acceptBidUseCase,
    required this.completeJobUseCase,
    required this.rateProviderUseCase,
    required this.getRequestByIdUseCase,
    required this.getProviderJobsUseCase,
    required this.getProviderReviewsUseCase,
    required this.firebaseAuth,
  }) : super(ServiceRequestInitial()) {
    on<CreateServiceRequestEvent>(_onCreateRequest);
    on<LoadMyRequestsEvent>(_onLoadMyRequests);
    on<FetchOpenRequestsByCategoryEvent>(_onFetchOpenRequestsByCategory);
    on<FetchProviderJobsEvent>(_onFetchProviderJobs);
    on<_ServiceRequestsLoadedEvent>(_onRequestsLoaded);
    on<_ServiceRequestsErrorEvent>(_onRequestsError);
    on<CancelRequestEvent>(_onCancelRequest);
    on<PlaceBidEvent>(_onPlaceBid);
    on<LoadBidsForRequestEvent>(_onLoadBidsForRequest);
    on<_ServiceRequestBidsLoadedEvent>(_onBidsLoaded);
    on<_ServiceRequestBidsErrorEvent>(_onBidsError);
    on<AcceptBidEvent>(_onAcceptBid);
    on<CompleteJobEvent>(_onCompleteJob);
    on<RateProviderEvent>(_onRateProvider);
    on<LoadRequestDetailEvent>(_onLoadRequestDetail);
    on<LoadProviderReviewsEvent>(_onLoadProviderReviews);
  }

  // ──────────────────────────────────────────────
  // CREATE
  // ──────────────────────────────────────────────

  Future<void> _onCreateRequest(
    CreateServiceRequestEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestLoading());

    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(
        const ServiceRequestError("You must be logged in to create a request."),
      );
      return;
    }

    try {
      final result = await createRequestUseCase(
        CreateRequestParams(
          userId: userId,
          categoryId: event.categoryId,
          title: event.title,
          description: event.description,
          date: event.date,
          priceRange: event.priceRange,
          address: event.address,
        ),
      );

      result.fold(
        (failure) => emit(ServiceRequestError(failure.message)),
        (request) => emit(ServiceRequestSuccess(request)),
      );
    } catch (e) {
      debugPrint('[ServiceRequestBloc] Create request error: $e');
      emit(ServiceRequestError("An unexpected error occurred: $e"));
    }
  }

  // ──────────────────────────────────────────────
  // CANCEL
  // ──────────────────────────────────────────────

  Future<void> _onCancelRequest(
    CancelRequestEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    // Don't emit full loading — prevents list flickering
    final result = await cancelRequestUseCase(event.requestId);
    result.fold((failure) => emit(ServiceRequestError(failure.message)), (_) {
      emit(ServiceRequestCancelled());
      if (currentRequests.isNotEmpty) {
        emit(ServiceRequestsLoaded(currentRequests));
      }
    });
  }

  // ──────────────────────────────────────────────
  // LOAD REQUESTS (streams)
  // ──────────────────────────────────────────────

  void _onLoadMyRequests(
    LoadMyRequestsEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(ServiceRequestLoading());

    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(
        const ServiceRequestError("You must be logged in to view requests."),
      );
      return;
    }

    _requestsSubscription?.cancel();
    _requestsSubscription = getUserRequestsUseCase(userId).listen((result) {
      result.fold(
        (failure) => add(_ServiceRequestsErrorEvent(failure.message)),
        (requests) => add(_ServiceRequestsLoadedEvent(requests)),
      );
    }, onError: (error) => add(_ServiceRequestsErrorEvent(error.toString())));
  }

  void _onFetchProviderJobs(
    FetchProviderJobsEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(ServiceRequestLoading());

    final providerId = firebaseAuth.currentUser?.uid;
    if (providerId == null) {
      emit(const ServiceRequestError("You must be logged in to view jobs."));
      return;
    }

    _requestsSubscription?.cancel();
    _requestsSubscription = getProviderJobsUseCase(providerId).listen((result) {
      result.fold(
        (failure) => add(_ServiceRequestsErrorEvent(failure.message)),
        (requests) => add(_ServiceRequestsLoadedEvent(requests)),
      );
    }, onError: (error) => add(_ServiceRequestsErrorEvent(error.toString())));
  }

  void _onFetchOpenRequestsByCategory(
    FetchOpenRequestsByCategoryEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(ServiceRequestLoading());

    _requestsSubscription?.cancel();
    _requestsSubscription = getOpenRequestsByCategoryUseCase(event.categoryId)
        .listen(
          (result) {
            result.fold(
              (failure) => add(_ServiceRequestsErrorEvent(failure.message)),
              (requests) => add(_ServiceRequestsLoadedEvent(requests)),
            );
          },
          onError: (error) => add(_ServiceRequestsErrorEvent(error.toString())),
        );
  }

  void _onRequestsLoaded(
    _ServiceRequestsLoadedEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    currentRequests = event.requests;
    emit(ServiceRequestsLoaded(event.requests));
  }

  void _onRequestsError(
    _ServiceRequestsErrorEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(ServiceRequestError(event.message));
  }

  // ──────────────────────────────────────────────
  // PLACE BID — uses ActionLoading (no full-screen wipe)
  // ──────────────────────────────────────────────

  Future<void> _onPlaceBid(
    PlaceBidEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestActionLoading());

    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const ServiceRequestError("You must be logged in to place a bid."));
      return;
    }

    final bid = BidEntity(
      id: '',
      requestId: event.requestId,
      providerId: currentUser.uid,
      providerName: currentUser.displayName ?? 'Provider',
      amount: event.price,
      note: event.note,
      createdAt: DateTime.now(),
    );

    final result = await placeBidUseCase(bid);
    result.fold((failure) => emit(ServiceRequestError(failure.message)), (_) {
      emit(const BidPlacedSuccess());
      // Restore requests list so the dashboard doesn't go blank
      if (currentRequests.isNotEmpty) {
        emit(ServiceRequestsLoaded(currentRequests));
      }
    });
  }

  // ──────────────────────────────────────────────
  // BIDS STREAM
  // ──────────────────────────────────────────────

  void _onLoadBidsForRequest(
    LoadBidsForRequestEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(ServiceRequestBidsLoading());

    _bidsSubscription?.cancel();
    _bidsSubscription = getBidsForRequestUseCase(event.requestId).listen(
      (result) {
        result.fold(
          (failure) => add(_ServiceRequestBidsErrorEvent(failure.message)),
          (bids) => add(_ServiceRequestBidsLoadedEvent(bids)),
        );
      },
      onError: (error) => add(_ServiceRequestBidsErrorEvent(error.toString())),
    );
  }

  void _onBidsLoaded(
    _ServiceRequestBidsLoadedEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(ServiceRequestBidsLoaded(event.bids));
  }

  void _onBidsError(
    _ServiceRequestBidsErrorEvent event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(ServiceRequestBidsError(event.message));
  }

  // ──────────────────────────────────────────────
  // ACCEPT BID — uses ActionLoading (no full-screen wipe)
  // ──────────────────────────────────────────────

  Future<void> _onAcceptBid(
    AcceptBidEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestActionLoading());

    final result = await acceptBidUseCase(
      AcceptBidParams(
        requestId: event.requestId,
        bidId: event.bidId,
        providerId: event.providerId,
        price: event.price,
      ),
    );

    result.fold(
      (failure) => emit(ServiceRequestError(failure.message)),
      (_) => emit(const BidAcceptedSuccess()),
    );
  }

  // ──────────────────────────────────────────────
  // COMPLETE JOB — uses ActionLoading
  // ──────────────────────────────────────────────

  Future<void> _onCompleteJob(
    CompleteJobEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestActionLoading());

    // 1. Mark as completed
    final result = await completeJobUseCase(event.requestId);

    await result.fold(
      (failure) async {
        emit(ServiceRequestError(failure.message));
      },
      (_) async {
        // 2. If a rating was provided, submit it as well
        if (event.rating != null &&
            event.providerId != null &&
            event.providerId!.isNotEmpty) {
          final rateResult = await rateProviderUseCase(
            RateProviderParams(
              requestId: event.requestId,
              providerId: event.providerId!,
              rating: event.rating!,
              comment: event.comment ?? '',
              photos: event.photos ?? const [],
            ),
          );

          rateResult.fold(
            (failure) => emit(ServiceRequestError(failure.message)),
            (_) {
              emit(const ProviderRatedSuccess());
              add(LoadRequestDetailEvent(event.requestId));
            },
          );
        } else {
          // Just completed
          emit(const JobCompletedSuccess());
          add(LoadRequestDetailEvent(event.requestId));
        }
      },
    );
  }

  // ──────────────────────────────────────────────
  // RATE PROVIDER — uses ActionLoading
  // ──────────────────────────────────────────────

  Future<void> _onRateProvider(
    RateProviderEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestActionLoading());

    final result = await rateProviderUseCase(
      RateProviderParams(
        requestId: event.requestId,
        providerId: event.providerId,
        rating: event.rating,
        comment: event.comment,
        photos: event.photos,
      ),
    );

    result.fold((failure) => emit(ServiceRequestError(failure.message)), (_) {
      emit(const ProviderRatedSuccess());
      add(LoadRequestDetailEvent(event.requestId));
    });
  }

  // ──────────────────────────────────────────────
  // LOAD REQUEST DETAIL (one-shot)
  // ──────────────────────────────────────────────

  Future<void> _onLoadRequestDetail(
    LoadRequestDetailEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    // Don't emit full loading here — the detail screen already has data
    final result = await getRequestByIdUseCase(event.requestId);

    result.fold(
      (failure) => emit(ServiceRequestError(failure.message)),
      (request) => emit(RequestDetailLoaded(request)),
    );
  }

  // ──────────────────────────────────────────────
  // REVIEWS
  // ──────────────────────────────────────────────

  Future<void> _onLoadProviderReviews(
    LoadProviderReviewsEvent event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ProviderReviewsLoading());

    final result = await getProviderReviewsUseCase(event.providerId);
    result.fold(
      (failure) => emit(ProviderReviewsError(failure.message)),
      (reviews) => emit(ProviderReviewsLoaded(reviews)),
    );
  }

  // ──────────────────────────────────────────────
  // CLEANUP
  // ──────────────────────────────────────────────

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    _bidsSubscription?.cancel();
    return super.close();
  }
}

// ──────────────────────────────────────────────
// Internal Events (not exported)
// ──────────────────────────────────────────────

class _ServiceRequestsLoadedEvent extends ServiceRequestEvent {
  final List<ServiceRequestEntity> requests;
  const _ServiceRequestsLoadedEvent(this.requests);
}

class _ServiceRequestsErrorEvent extends ServiceRequestEvent {
  final String message;
  const _ServiceRequestsErrorEvent(this.message);
}

class _ServiceRequestBidsLoadedEvent extends ServiceRequestEvent {
  final List<BidEntity> bids;
  const _ServiceRequestBidsLoadedEvent(this.bids);
}

class _ServiceRequestBidsErrorEvent extends ServiceRequestEvent {
  final String message;
  const _ServiceRequestBidsErrorEvent(this.message);
}
