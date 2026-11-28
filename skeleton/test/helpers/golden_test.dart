import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/theme/theme_x.dart';

import 'golden.dart';

void main() {
  goldenGallery(
    'golden_setup',
    size: const Size(400, 160),
    variants: {
      'Text': Builder(
        builder: (context) => Text('Weekly report', style: context.text.body),
      ),
    },
  );

  testWidgets('the golden font is Inter and not Ahem', (tester) async {
    late TextStyle style;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            style = context.text.body;
            return Text('Weekly report', style: style);
          },
        ),
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Weekly report'),
    );
    expect(paragraph.text.style?.fontFamily, 'Inter');
    final inter = paragraph.size.width;
    final ahem = TextPainter(
      text: TextSpan(
        text: 'Weekly report',
        style: style.copyWith(fontFamily: 'Ahem'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    expect(inter, isNot(ahem.width));
  });
}
