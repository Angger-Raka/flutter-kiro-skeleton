import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:skeleton/core/network/interceptors/auth_interceptor.dart';

/// The single HTTP client of the app. Paths are relative to the configured
/// `baseUrl`; an absolute URL overrides it.
@lazySingleton
class ApiClient {
  /// Creates the client over [_dio] and installs the no-op auth interceptor.
  ApiClient(this._dio) {
    _dio.interceptors.add(const AuthInterceptor());
  }

  final Dio _dio;

  /// GET [path].
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _dio.get<T>(path, queryParameters: query);

  /// POST [path].
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) => _dio.post<T>(path, data: data, queryParameters: query);

  /// PUT [path].
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) => _dio.put<T>(path, data: data, queryParameters: query);

  /// DELETE [path].
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) => _dio.delete<T>(path, data: data, queryParameters: query);
}
