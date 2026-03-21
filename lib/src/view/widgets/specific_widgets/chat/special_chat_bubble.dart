import 'package:flutter/material.dart';

import '../../../../../core/themes/colors.dart';

class SpecialChatBubbleOne extends CustomPainter {
  final Color color;
  final Alignment alignment;
  final bool tail;

  SpecialChatBubbleOne({
    required this.color,
    required this.alignment,
    required this.tail,
  });

  final double _radius = 10.0;
  final double _x = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (alignment == Alignment.topRight) {
      if (tail) {
        var rrect = RRect.fromLTRBAndCorners(
          0,
          0,
          size.width - _x,
          size.height,
          bottomLeft: Radius.circular(_radius),
          bottomRight: Radius.circular(_radius),
          topLeft: Radius.circular(_radius),
        );

        // Create a shadow for the RRect
        var rrectPath = Path()..addRRect(rrect);
        canvas.drawShadow(rrectPath, blackColor, 4.0, false);

        canvas.drawRRect(
            rrect,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);

        var path = Path();
        path.moveTo(size.width - _x, 0);
        path.lineTo(size.width - _x, 10);
        path.lineTo(size.width, 0);
        canvas.clipPath(path);

        var smallRRect = RRect.fromLTRBAndCorners(
          size.width - _x,
          0.0,
          size.width,
          size.height,
          topRight: const Radius.circular(3),
        );
        canvas.drawShadow(
          Path()..addRRect(smallRRect),
          blackColor,
          4.0,
          false,
        );

        canvas.drawRRect(
            smallRRect,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      } else {
        var rrect = RRect.fromLTRBAndCorners(
          0,
          0,
          size.width - _x,
          size.height,
          bottomLeft: Radius.circular(_radius),
          bottomRight: Radius.circular(_radius),
          topLeft: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
        );

        // Create a shadow for the RRect
        var rrectPath = Path()..addRRect(rrect);
        canvas.drawShadow(rrectPath, blackColor, 4.0, false);

        canvas.drawRRect(
            rrect,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      }
    } else {
      if (tail) {
        var rrect = RRect.fromLTRBAndCorners(
          _x,
          0,
          size.width,
          size.height,
          bottomRight: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
          bottomLeft: Radius.circular(_radius),
        );

        // Create a shadow for the RRect
        var rrectPath = Path()..addRRect(rrect);
        canvas.drawShadow(rrectPath, blackColor, 4.0, false);

        canvas.drawRRect(
            rrect,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);

        var path = Path();
        path.moveTo(_x, 0);
        path.lineTo(_x, 10);
        path.lineTo(0, 0);
        canvas.clipPath(path);

        var smallRRect = RRect.fromLTRBAndCorners(
          0,
          0.0,
          _x,
          size.height,
          topLeft: const Radius.circular(3),
        );
        canvas.drawShadow(
          Path()..addRRect(smallRRect),
          blackColor,
          4.0,
          false,
        );

        canvas.drawRRect(
            smallRRect,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      } else {
        var rrect = RRect.fromLTRBAndCorners(
          _x,
          0,
          size.width,
          size.height,
          bottomRight: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
          bottomLeft: Radius.circular(_radius),
          topLeft: Radius.circular(_radius),
        );

        var rrectPath = Path()..addRRect(rrect);
        canvas.drawShadow(rrectPath, blackColor, 4.0, false);

        canvas.drawRRect(
            rrect,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
