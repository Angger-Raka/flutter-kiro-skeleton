import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skeleton/core/error/failure.dart';

part 'connection_check_state.freezed.dart';

/// State of the placeholder page's connection check.
@freezed
sealed class ConnectionCheckState with _$ConnectionCheckState {
  /// No check has run yet.
  const factory ConnectionCheckState.idle() = ConnectionCheckIdle;

  /// A request is in flight.
  const factory ConnectionCheckState.loading() = ConnectionCheckLoading;

  /// The health URL answered with a success status.
  const factory ConnectionCheckState.success() = ConnectionCheckSuccess;

  /// The request failed with [failure].
  const factory ConnectionCheckState.failure(Failure failure) =
      ConnectionCheckFailure;
}
