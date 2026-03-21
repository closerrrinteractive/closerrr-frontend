import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Responsive extends StatelessWidget {
  final Widget? mobile;
  final Widget? desktop;
  final Widget? tablet;
  final Widget? smallMobile;

  const Responsive(
      {super.key, this.mobile, this.desktop, this.tablet, this.smallMobile});

  static bool isMobile() => Get.width < 768;

  static bool isTablet() => Get.width < 1200 && Get.width >= 768;

  static bool isDesktop() => Get.width >= 1200 && Get.width <= 3000;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // If our width is more than 1200 then we consider it a desktop
    if (size.width >= 1200 && size.width <= 3000) {
      return desktop!;
    }
    // If width it less then 1200 and more then 768 we consider it as tablet
    else if (size.width >= 768 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile device
    else if (size.width >= 376 && size.width <= 768 && mobile != null) {
      return mobile!;
    } else {
      return smallMobile!;
    }
  }
}
