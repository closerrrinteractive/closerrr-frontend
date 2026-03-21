import 'package:closerrr/core/utils/img_string.dart';
import 'package:flutter/material.dart';

class CustomBackgroundPage extends StatelessWidget {
  final Widget child;

  const CustomBackgroundPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
          ),
        ),
        // Foreground Content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
