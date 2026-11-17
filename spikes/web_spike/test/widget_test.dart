import 'package:flutter_test/flutter_test.dart';
import 'package:web_spike/main.dart';

void main() {
  test('Article host parses image url', () {
    expect(Article('t', 'https://a.example.com/x.jpg').host, 'a.example.com');
  });
}
