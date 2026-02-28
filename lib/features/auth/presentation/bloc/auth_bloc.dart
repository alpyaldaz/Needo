import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:needo/features/auth/domain/usecases/login_usecase.dart';
import 'package:needo/features/auth/domain/usecases/register_usecase.dart';
import 'package:needo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:needo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:needo/features/auth/domain/usecases/become_provider_usecase.dart';
import 'package:needo/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:needo/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:needo/features/auth/presentation/bloc/auth_event.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogOutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final BecomeProviderUseCase becomeProviderUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.becomeProviderUseCase,
    required this.updateUserProfileUseCase,
    required this.sendPasswordResetEmailUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatusEvent);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<BecomeProviderEvent>(_onBecomeProviderEvent);
    on<UpdateUserProfileEvent>(_onUpdateUserProfileEvent);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
  }

  Future<void> _onCheckAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold((_) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onBecomeProviderEvent(
    BecomeProviderEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await becomeProviderUseCase(
      BecomeProviderParams(
        userId: event.userId,
        categoryId: event.categoryId,
        hourlyRate: event.hourlyRate,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onUpdateUserProfileEvent(
    UpdateUserProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await updateUserProfileUseCase(
      UpdateUserProfileParams(
        userId: event.userId,
        name: event.name,
        phone: event.phone,
        profileImageUrl: event.profileImageUrl,
        googleBusinessUrl: event.googleBusinessUrl,
        about: event.about,
        providerCategory: event.providerCategory,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Execute the UseCase from the Domain layer
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    // FP Dart's Either requires us to handle both sides explicitly using fold()
    result.fold(
      (failure) => emit(AuthError(failure.message)), // Left: Error
      (user) => emit(AuthAuthenticated(user)), // Right: Success
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await sendPasswordResetEmailUseCase(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(
        const AuthPasswordResetSent("Password reset link sent to your email"),
      ),
    );
  }
}
