import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeleton/core/log/logger.dart';

/// Routes every bloc and cubit error to the [Logger].
class AppBlocObserver extends BlocObserver {
  /// Creates an observer that logs through [_logger].
  const AppBlocObserver(this._logger);

  final Logger _logger;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.logError(error, stackTrace, context: bloc.runtimeType.toString());
    super.onError(bloc, error, stackTrace);
  }
}
