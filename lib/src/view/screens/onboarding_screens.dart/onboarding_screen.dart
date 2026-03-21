import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/onboarding-controllers/onboarding_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart'; // For scaling

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnBoardingSliderController onBoardingSliderController = Get.find();
  final ScalingController scalingController = Get.find();

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     showIpAddressDialog();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backScreenColor,
      body: Obx(
        () => Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: PageView.builder(
                controller: onBoardingSliderController.pageController,
                onPageChanged: (index) {
                  onBoardingSliderController.currentIndex.value = index;
                },
                itemCount: onBoardingSliderController.pages.length,
                itemBuilder: (context, index) {
                  return onBoardingSliderController.pages[index];
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0) {
                    // Swipe right to previous page
                    if (onBoardingSliderController.currentIndex.value > 0) {
                      onBoardingSliderController.pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  } else if (details.delta.dx < 0) {
                    // Swipe left to next page
                    if (onBoardingSliderController.currentIndex.value <
                        onBoardingSliderController.pages.length - 1) {
                      onBoardingSliderController.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  }
                },
                child: Container(
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.sp),
                      topRight: Radius.circular(40.sp),
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Heading
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: onBoardingSliderController.pageTitle[
                                      onBoardingSliderController
                                          .currentIndex.value],
                                  style: CustomTextStyle
                                      .styledTextWidget.bodyLarge!
                                      .copyWith(
                                    color: peachColor,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: onBoardingSliderController.colorTitle[
                                      onBoardingSliderController
                                          .currentIndex.value],
                                  style: CustomTextStyle
                                      .styledTextWidget.bodyLarge!
                                      .copyWith(
                                    height: 1.5, // Add line height here as well
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        // Description text based on the current page
                        Text(
                          onBoardingSliderController.pageDescriptions[
                              onBoardingSliderController.currentIndex.value],
                          textAlign: TextAlign.center,
                          style: CustomTextStyle.styledTextWidget.bodyMedium,
                        ),

                        // Page indicator
                        SizedBox(height: 3.h),
                        // Next or Get Started button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Skip Button
                            SizedBox(
                              width: 25.w, // Fixed width to avoid shifting
                              child: GestureDetector(
                                onTap: onBoardingSliderController.goToSignIn,
                                child: Text(
                                  "Skip",
                                  textAlign: TextAlign
                                      .start, // Ensure the text is centered
                                  style: TextStyle(
                                    color: whiteColor.withOpacity(0.6),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                            // Middle Dots Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                onBoardingSliderController.pages.length,
                                (index) {
                                  return Obx(
                                    () => AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: 1.h,
                                      width: 2.w,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 1.w),
                                      decoration: BoxDecoration(
                                        color: onBoardingSliderController
                                                    .currentIndex.value ==
                                                index
                                            ? whiteColor
                                            : Colors.grey.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Next or Get Started Button
                            SizedBox(
                              width: 30.w,
                              child: GestureDetector(
                                onTap: () {
                                  if (onBoardingSliderController
                                          .currentIndex.value ==
                                      onBoardingSliderController.pages.length -
                                          1) {
                                    onBoardingSliderController.goToSignIn();
                                  } else {
                                    onBoardingSliderController.onNext();
                                  }
                                },
                                child: Text(
                                  onBoardingSliderController
                                              .currentIndex.value ==
                                          onBoardingSliderController
                                                  .pages.length -
                                              1
                                      ? "Get Started"
                                      : "Next",
                                  textAlign: TextAlign
                                      .end, // Ensure the text is centered
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 14.sp,
                                    fontWeight: onBoardingSliderController
                                                .currentIndex.value ==
                                            onBoardingSliderController
                                                    .pages.length -
                                                1
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 7.h),
                child: Column(
                  children: [
                    Obx(
                      () => Transform.scale(
                        scale: scalingController.scaleFactor.value,
                        child: Image.asset(
                          mainLogo,
                          scale: 7,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Closerrr",
                          style: CustomTextStyle.styledTextWidget.titleLarge!
                              .copyWith(color: primaryColor, fontSize: 14.sp),
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        Text(
                          "toyou!",
                          style: CustomTextStyle.styledTextWidget.labelLarge!
                              .copyWith(
                            color: peachColor,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'AnnieUseYourTelescope',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;

  const OnboardingPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Padding(
        padding: EdgeInsets.only(bottom: 15.h),
        child: Center(child: Image.asset(image, height: 35.h)),
      ),
    );
  }
}
