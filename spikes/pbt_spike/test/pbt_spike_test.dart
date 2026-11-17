import 'package:glados/glados.dart';
import 'package:kiri_check/kiri_check.dart' as kiri;
import 'package:test/test.dart';

void main() {
  group('glados', () {
    Glados<List<int>>().test('reverse twice is identity', (list) {
      expect(list.reversed.toList().reversed.toList(), equals(list));
    });
  });

  group('kiri_check', () {
    kiri.property('reverse twice is identity', () {
      kiri.forAll(
        kiri.list(kiri.integer()),
        (list) {
          expect(list.reversed.toList().reversed.toList(), equals(list));
        },
      );
    });
  });
}
