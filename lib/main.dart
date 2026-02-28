import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/config/theme.dart';
import 'package:needo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:needo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';
import 'package:needo/features/auth/domain/usecases/login_usecase.dart';
import 'package:needo/features/auth/domain/usecases/register_usecase.dart';
import 'package:needo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:needo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:needo/features/auth/domain/usecases/become_provider_usecase.dart';
import 'package:needo/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:needo/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_event.dart';
import 'package:needo/features/service_requests/data/datasources/service_request_remote_data_source.dart';
import 'package:needo/features/service_requests/data/repositories/service_request_repository_impl.dart';
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
import 'package:needo/features/chat/domain/usecases/get_messages_stream_usecase.dart';
import 'package:needo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/chat/data/datasources/chat_remote_data_source_impl.dart';
import 'package:needo/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:needo/features/chat/domain/usecases/create_or_get_chat_room_usecase.dart';
import 'package:needo/features/chat/domain/usecases/get_user_chat_rooms_usecase.dart';
import 'package:needo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:needo/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('🔥 [BlocObserver] ${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('🔥 [BlocObserver] ${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('🔥 [BlocObserver] Error in ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  // Ensure Flutter binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Requires google-services.json/GoogleService-Info.plist)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  Bloc.observer = SimpleBlocObserver();

  // ==== Auth Feature Dependency Injection ====
  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logOutUseCase = LogOutUseCase(authRepository);

  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final becomeProviderUseCase = BecomeProviderUseCase(authRepository);
  final updateUserProfileUseCase = UpdateUserProfileUseCase(authRepository);
  final sendPasswordResetEmailUseCase = SendPasswordResetEmailUseCase(
    authRepository,
  );

  // ==== Service Request Dependency Injection ====
  final serviceRequestRemoteDataSource = ServiceRequestRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
  );

  final serviceRequestRepository = ServiceRequestRepositoryImpl(
    remoteDataSource: serviceRequestRemoteDataSource,
  );

  final createRequestUseCase = CreateRequestUseCase(serviceRequestRepository);
  final getUserRequestsUseCase = GetUserRequestsUseCase(
    serviceRequestRepository,
  );
  final cancelRequestUseCase = CancelRequestUseCase(serviceRequestRepository);
  final getOpenRequestsByCategoryUseCase = GetOpenRequestsByCategoryUseCase(
    serviceRequestRepository,
  );
  final placeBidUseCase = PlaceBidUseCase(serviceRequestRepository);
  final getBidsForRequestUseCase = GetBidsForRequestUseCase(
    serviceRequestRepository,
  );
  final acceptBidUseCase = AcceptBidUseCase(serviceRequestRepository);
  final completeJobUseCase = CompleteJobUseCase(serviceRequestRepository);
  final rateProviderUseCase = RateProviderUseCase(serviceRequestRepository);
  final getRequestByIdUseCase = GetRequestByIdUseCase(serviceRequestRepository);
  final getProviderJobsUseCase = GetProviderJobsUseCase(
    serviceRequestRepository,
  );
  final getProviderReviewsUseCase = GetProviderReviewsUseCase(
    serviceRequestRepository,
  );

  // ==== Chat Dependency Injection ====
  final chatRemoteDataSource = ChatRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
  );

  final chatRepository = ChatRepositoryImpl(
    remoteDataSource: chatRemoteDataSource,
  );

  final createOrGetChatRoomUseCase = CreateOrGetChatRoomUseCase(chatRepository);
  final getMessagesStreamUseCase = GetMessagesStreamUseCase(chatRepository);
  final sendMessageUseCase = SendMessageUseCase(chatRepository);
  final getUserChatRoomsUseCase = GetUserChatRoomsUseCase(chatRepository);

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    NeedoApp(
      initialRoute: hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding,
      authRepository: authRepository,
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logOutUseCase: logOutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      becomeProviderUseCase: becomeProviderUseCase,
      updateUserProfileUseCase: updateUserProfileUseCase,
      sendPasswordResetEmailUseCase: sendPasswordResetEmailUseCase,
      createRequestUseCase: createRequestUseCase,
      getUserRequestsUseCase: getUserRequestsUseCase,
      cancelRequestUseCase: cancelRequestUseCase,
      getOpenRequestsByCategoryUseCase: getOpenRequestsByCategoryUseCase,
      placeBidUseCase: placeBidUseCase,
      getBidsForRequestUseCase: getBidsForRequestUseCase,
      acceptBidUseCase: acceptBidUseCase,
      completeJobUseCase: completeJobUseCase,
      rateProviderUseCase: rateProviderUseCase,
      getRequestByIdUseCase: getRequestByIdUseCase,
      getProviderJobsUseCase: getProviderJobsUseCase,
      getProviderReviewsUseCase: getProviderReviewsUseCase,
      createOrGetChatRoomUseCase: createOrGetChatRoomUseCase,
      getMessagesStreamUseCase: getMessagesStreamUseCase,
      sendMessageUseCase: sendMessageUseCase,
      getUserChatRoomsUseCase: getUserChatRoomsUseCase,
    ),
  );
}

class NeedoApp extends StatelessWidget {
  final AuthRepository authRepository;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogOutUseCase logOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final BecomeProviderUseCase becomeProviderUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
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
  final CreateOrGetChatRoomUseCase createOrGetChatRoomUseCase;
  final GetMessagesStreamUseCase getMessagesStreamUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetUserChatRoomsUseCase getUserChatRoomsUseCase;
  final String initialRoute;

  const NeedoApp({
    super.key,
    required this.initialRoute,
    required this.authRepository,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logOutUseCase,
    required this.getCurrentUserUseCase,
    required this.becomeProviderUseCase,
    required this.updateUserProfileUseCase,
    required this.sendPasswordResetEmailUseCase,
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
    required this.createOrGetChatRoomUseCase,
    required this.getMessagesStreamUseCase,
    required this.sendMessageUseCase,
    required this.getUserChatRoomsUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<GetMessagesStreamUseCase>.value(
          value: getMessagesStreamUseCase,
        ),
        RepositoryProvider<SendMessageUseCase>.value(value: sendMessageUseCase),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              loginUseCase: loginUseCase,
              registerUseCase: registerUseCase,
              logoutUseCase: logOutUseCase,
              getCurrentUserUseCase: getCurrentUserUseCase,
              becomeProviderUseCase: becomeProviderUseCase,
              updateUserProfileUseCase: updateUserProfileUseCase,
              sendPasswordResetEmailUseCase: sendPasswordResetEmailUseCase,
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<ServiceRequestBloc>(
            create: (context) => ServiceRequestBloc(
              createRequestUseCase: createRequestUseCase,
              getUserRequestsUseCase: getUserRequestsUseCase,
              cancelRequestUseCase: cancelRequestUseCase,
              getOpenRequestsByCategoryUseCase:
                  getOpenRequestsByCategoryUseCase,
              placeBidUseCase: placeBidUseCase,
              getBidsForRequestUseCase: getBidsForRequestUseCase,
              acceptBidUseCase: acceptBidUseCase,
              completeJobUseCase: completeJobUseCase,
              rateProviderUseCase: rateProviderUseCase,
              getRequestByIdUseCase: getRequestByIdUseCase,
              getProviderJobsUseCase: getProviderJobsUseCase,
              getProviderReviewsUseCase: getProviderReviewsUseCase,
              firebaseAuth: FirebaseAuth.instance,
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              createOrGetChatRoomUseCase: createOrGetChatRoomUseCase,
              getUserChatRoomsUseCase: getUserChatRoomsUseCase,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Needo Service Marketplace',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: initialRoute,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}
