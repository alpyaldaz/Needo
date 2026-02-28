import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class CheckAuthStatusEvent extends AuthEvent {}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {}

class BecomeProviderEvent extends AuthEvent {
  final String userId;
  final String categoryId;
  final double hourlyRate;

  const BecomeProviderEvent({
    required this.userId,
    required this.categoryId,
    required this.hourlyRate,
  });

  @override
  List<Object> get props => [userId, categoryId, hourlyRate];
}

class UpdateUserProfileEvent extends AuthEvent {
  final String userId;
  final String? name;
  final String? phone;
  final String? profileImageUrl;
  final String? googleBusinessUrl;
  final String? about;
  final String? providerCategory;

  const UpdateUserProfileEvent({
    required this.userId,
    this.name,
    this.phone,
    this.profileImageUrl,
    this.googleBusinessUrl,
    this.about,
    this.providerCategory,
  });

  @override
  List<Object> get props => [
    userId,
    name ?? '',
    phone ?? '',
    profileImageUrl ?? '',
    googleBusinessUrl ?? '',
    about ?? '',
    providerCategory ?? '',
  ];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}
