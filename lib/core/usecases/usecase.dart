import 'package:fpdart/fpdart.dart';
import 'package:needo/core/error/failures.dart';

/// Base interface for all use cases.
/// T = The success return type.
/// Params = The input parameters required.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use this when a UseCase requires no specific parameters.
class NoParams {}
