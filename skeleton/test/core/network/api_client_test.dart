import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeleton/core/network/api_client.dart';
import 'package:skeleton/core/network/interceptors/auth_interceptor.dart';

class _MockAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late _MockAdapter adapter;
  late Dio dio;
  late ApiClient client;
  late List<RequestOptions> seen;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
  });

  setUp(() {
    seen = [];
    adapter = _MockAdapter();
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) async {
      seen.add(inv.positionalArguments.first as RequestOptions);
      return ResponseBody.fromString('{}', 200);
    });
    dio = Dio(BaseOptions(baseUrl: 'https://base.test/api'))
      ..httpClientAdapter = adapter;
    client = ApiClient(dio);
  });

  test('installs the auth interceptor', () {
    expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
  });

  test('a request passes through the no-op interceptor unchanged', () async {
    await client.get<dynamic>('/items', query: {'page': 2});

    final options = seen.single;
    expect(options.method, 'GET');
    expect(options.uri.toString(), 'https://base.test/api/items?page=2');
    expect(options.headers.containsKey('Authorization'), isFalse);
  });

  test('an absolute URL overrides baseUrl', () async {
    await client.post<dynamic>('https://other.test/health', data: {'a': 1});

    expect(seen.single.uri.toString(), 'https://other.test/health');
    expect(seen.single.method, 'POST');
  });

  test('put and delete use their HTTP methods', () async {
    await client.put<dynamic>('/x');
    await client.delete<dynamic>('/x');

    expect(seen.map((o) => o.method), ['PUT', 'DELETE']);
  });
}
