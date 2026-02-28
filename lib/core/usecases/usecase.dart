import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';

/// Base interface for all use cases.
/// Type = The success return type.
/// Params = The input parameters required.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when a UseCase requires no specific parameters.
class NoParams {}
