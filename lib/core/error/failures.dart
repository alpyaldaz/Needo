import 'package:equatable/equatable.dart';

/// Base class for all failures in the app.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents an error from a server or external API.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Represents an error accessing local cached data.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Represents an authentication-specific failure (e.g. wrong password).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
