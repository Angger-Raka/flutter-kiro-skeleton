import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeleton/core/error/failure.dart';

/// Base contract for a domain use case.
// ignore: one_member_abstracts, the contract is the point of this type.
abstract class UseCase<T, P> {
  /// Runs the use case.
  Future<Either<Failure, T>> call(P params);
}

/// Params for a use case that takes none.
@immutable
class NoParams {
  /// Creates [NoParams].
  const NoParams();
}
