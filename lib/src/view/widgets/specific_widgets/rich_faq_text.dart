import 'package:flutter/material.dart';

class RichFaqText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const RichFaqText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    if (!text.toLowerCase().contains('closerrr')) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
      );
    }

    final List<TextSpan> spans = [];
    final pattern = RegExp(r'(closerrr)', caseSensitive: false);
    
    final matches = pattern.allMatches(text);
    
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }
      
      final matchedText = text.substring(match.start, match.end);
      spans.add(TextSpan(
        text: matchedText,
        style: style.copyWith(
          fontFamily: 'FredokaOne',
          fontWeight: FontWeight.normal,
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
    );
  }
}
