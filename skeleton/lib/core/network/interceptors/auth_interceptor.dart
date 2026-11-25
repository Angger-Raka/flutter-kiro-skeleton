import 'package:dio/dio.dart';

/// No-op auth interceptor and extension point.
///
/// The skeleton ships no authentication. An app that needs it attaches tokens
/// in [onRequest] and refreshes them in [onError].
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor].
  const AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO(core): attach the access token here when an app adds auth.
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO(core): refresh the token on 401 here when an app adds auth.
    handler.next(err);
  }
}
