import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onInit;
  const SplashScreen({super.key, this.onInit});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ScalingController scalingController = Get.find();

  @override
  void initState() {
    super.initState();
    widget.onInit?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(2.h),
        height: 100.h,
        width: 100.w,
        decoration: const BoxDecoration(color: backScreenColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 5.h,
            ),
            Center(
              child: Obx(
                () => Transform.scale(
                  scale: scalingController.scaleFactor
                      .value, // Bind the scale to the animation value
                  child: Image.asset(
                    mainLogo,
                    scale: 3,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Closerrr",
              style: CustomTextStyle.styledTextWidget.titleLarge!
                  .copyWith(color: primaryColor),
            )
          ],
        ),
      ),
    );
  }
}
