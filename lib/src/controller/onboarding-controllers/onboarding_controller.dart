import 'package:closerrr/core/services/shared_preference_service.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routing/routing_controller.dart';

class OnBoardingSliderController extends GetxController {
  final RxInt currentIndex = 0.obs;
  PageController pageController = PageController();

  void onNext() {
    if (currentIndex.value < pages.length - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      goToSignIn();
    }
  }

  Future<void> goToSignIn() async {
    await setDataInShared("initilized", true);
    // Navigate to the sign-in page
    RouterController.current.pushReplacement("/signin-screen");
  }

  final List<Widget> pages = [
    const OnboardingPage(
      image: sliderOne,
    ),
    const OnboardingPage(
      image: sliderTwo,
    ),
    const OnboardingPage(
      image: sliderThree,
    ),
  ];

  final List<String> pageDescriptions = [
    'Chat Directly with your Favorite Artists - cause your messages Stay Private, just between you two!',
    ' Be the First One to Know and Stay Updated with your Favorite Artists’ Schedules and Events.',
    'Have Exclusive Access to Live Streams and Behind-The-Scenes Magic of your Favorite Artists.',
  ];
  final List<String> pageTitle = [
    'Chat Privately ',
    'Stay In Sync ',
    'Enjoy Exclusive Content ',
  ];
  final List<String> colorTitle = [
    'With Your Favorite Artists!',
    'With Your Favorite Artists!',
    'From Your Favorite Artists!',
  ];
}
