import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class TransitionPage extends StatelessWidget {
  final ScalingController scalingController = Get.find();
  final String imagePath;

  TransitionPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          height: 100.h,
          width: 100.w,
          alignment: Alignment.center,
          child: Image(
            image: AssetImage(
              imagePath,
            ),
            height: 35.h,
          ),
        ),
      ),
    );
  }
}
