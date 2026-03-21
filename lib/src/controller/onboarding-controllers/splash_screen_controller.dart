import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScalingController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController animationController;
  late RxDouble scaleFactor;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 1.0,
      upperBound: 1.3,
    )..repeat(reverse: true); // Continuous animation loop

    scaleFactor = 1.0.obs; // Initialize with default scale

    animationController.addListener(() {
      scaleFactor.value =
          animationController.value; // Update scale value continuously
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
