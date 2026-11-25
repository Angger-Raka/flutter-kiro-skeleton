import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/log/logger.dart';

void main() {
  group('redact', () {
    const table = <String, String>{
      'Authorization: Bearer abc.def-123': 'Authorization: ***',
      'authorization=xyz123': 'authorization=***',
      'sent Bearer abc123XYZ== now': 'sent Bearer *** now',
      '{"password":"hunter2","name":"a"}': '{"password":"***","name":"a"}',
      '{"token": "t0k3n"}': '{"token": "***"}',
      'https://x.test/p?token=abc123&page=2':
          'https://x.test/p?token=***&page=2',
      'access_token=abc': 'access_token=***',
      'plain text stays': 'plain text stays',
      'Status 404 for /users/12': 'Status 404 for /users/12',
    };
    for (final MapEntry(key: input, value: expected) in table.entries) {
      test(input, () => expect(redact(input), expected));
    }
  });

  group('Logger', () {
    late List<String?> printed;
    late DebugPrintCallback original;

    setUp(() {
      original = debugPrint;
      printed = [];
      debugPrint = (message, {wrapWidth}) => printed.add(message);
    });
    tearDown(() => debugPrint = original);

    test('logError prints the masked bearer token', () {
      Logger().logError(
        Exception('failed with Bearer secret-token-1'),
        null,
        context: 'Ctx',
      );
      final out = printed.join('\n');
      expect(out, contains('Bearer ***'));
      expect(out, isNot(contains('secret-token-1')));
      expect(out, contains('[Ctx]'));
    });

    test('logFlutterError and logInfo print', () {
      Logger()
        ..logFlutterError(FlutterErrorDetails(exception: StateError('boom')))
        ..logInfo('password=abc');
      expect(printed.join('\n'), contains('boom'));
      expect(printed.last, 'password=***');
    });
  });
}
