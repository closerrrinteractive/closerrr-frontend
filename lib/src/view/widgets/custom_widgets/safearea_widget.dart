import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SafeAreaWidget extends StatelessWidget {
  const SafeAreaWidget({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.useBackgroundImage = false,
  });

  final double? height;
  final double? width;
  final Widget child;
  final bool useBackgroundImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 100.h,
      width: width ?? 100.w,
      decoration: BoxDecoration(
        color: primaryColor,
        image: useBackgroundImage
            ? const DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              )
            : null, // If no background image, fallback to default color
      ),
      child: SafeArea(
        child: Container(
          color: Colors.transparent, // Ensure foreground is transparent
          child: child,
        ),
      ),
    );
  }
}
