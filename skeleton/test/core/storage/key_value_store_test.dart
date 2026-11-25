import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton/core/error/exceptions.dart';
import 'package:skeleton/core/storage/key_value_store.dart';

class _MockPrefs extends Mock implements SharedPreferences {}

void main() {
  test('reads, writes, and removes', () async {
    SharedPreferences.setMockInitialValues({'a': 'one'});
    final store = SharedPrefsKeyValueStore(
      await SharedPreferences.getInstance(),
    );

    expect(store.getString('a'), 'one');
    expect(store.getString('missing'), isNull);

    await store.setString('b', 'two');
    expect(store.getString('b'), 'two');

    await store.remove('a');
    expect(store.getString('a'), isNull);
  });

  test('a write that returns false throws CacheException', () {
    final prefs = _MockPrefs();
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => false);
    when(() => prefs.remove(any())).thenAnswer((_) async => false);
    final store = SharedPrefsKeyValueStore(prefs);

    expect(store.setString('k', 'v'), throwsA(isA<CacheException>()));
    expect(store.remove('k'), throwsA(isA<CacheException>()));
  });
}
