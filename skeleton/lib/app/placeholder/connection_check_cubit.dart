import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:skeleton/app/env.dart';
import 'package:skeleton/app/placeholder/connection_check_state.dart';
import 'package:skeleton/core/log/logger.dart';
import 'package:skeleton/core/network/api_client.dart';
import 'package:skeleton/core/network/dio_error_mapper.dart';

/// Requests `Env.healthUrl` and reports the outcome.
@injectable
class ConnectionCheckCubit extends Cubit<ConnectionCheckState> {
  /// Creates the cubit in the idle state.
  ConnectionCheckCubit(this._apiClient, this._env, this._logger)
    : super(const ConnectionCheckState.idle());

  final ApiClient _apiClient;
  final Env _env;
  final Logger _logger;

  /// Runs one check. A call made while a check is loading is ignored.
  Future<void> check() async {
    if (state is ConnectionCheckLoading) {
      return;
    }
    emit(const ConnectionCheckState.loading());
    final result = await guardRepository(
      () => _apiClient.get<void>(_env.healthUrl),
    );
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) {
        _logger.logInfo('Connection check failed: $failure');
        emit(ConnectionCheckState.failure(failure));
      },
      (_) => emit(const ConnectionCheckState.success()),
    );
  }
}
