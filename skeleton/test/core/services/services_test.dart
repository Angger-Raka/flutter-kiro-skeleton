import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/services/clipboard_service.dart';
import 'package:skeleton/core/services/link_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  test(
    'ClipboardService.copy sends the text to the platform channel',
    () async {
      Object? sent;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          sent = call.arguments;
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await const ClipboardService().copy('hello');

      expect(sent, {'text': 'hello'});
    },
  );

  group('LinkLauncher.open', () {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final calls = <String>[];

    void mock({required bool canLaunch, required bool launched}) {
      calls.clear();
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return switch (call.method) {
          'canLaunch' => canLaunch,
          'launch' => launched,
          _ => null,
        };
      });
    }

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('returns true when the URL can be launched', () async {
      mock(canLaunch: true, launched: true);

      expect(
        await const LinkLauncher().open(Uri.parse('https://a.test')),
        isTrue,
      );
      expect(calls, ['canLaunch', 'launch']);
    });

    test('returns false and does not launch when it cannot', () async {
      mock(canLaunch: false, launched: true);

      expect(
        await const LinkLauncher().open(Uri.parse('https://a.test')),
        isFalse,
      );
      expect(calls, ['canLaunch']);
    });
  });
}
