// ignore_for_file: must_be_immutable

import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/controller/authentication/password_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_background_screen.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/auth_main_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/routing/routing_controller.dart';

class OnboardingWidget extends StatelessWidget {
  OnboardingWidget({
    super.key,
    required this.firstTextController,
    this.secondTextController,
    required this.boardTitle,
    required this.firstFieldHeadInBlack,
    required this.firstFieldHeadInBlue,
    required this.secondFieldHeadInBlack,
    required this.secondFieldHeadInBlue,
    required this.boardTap,
    required this.tapText,
    required this.isSingleField,
    required this.isOr,
    required this.isObsecureFirst,
    required this.isObsecureSecond,
    required this.fieldValidator1,
    this.fieldValidator2,
    this.suffixFirst,
    this.suffixSecond,
    this.prefixFirst,
    this.prefixSecond,
    required this.hintFirst,
    this.textlenght1,
    this.textlenght2,
    required this.hintSecond,
    this.keyboardType = TextInputType.text,
    required this.suffixTap1,
    required this.suffixTap2,
    required this.tapColor,
  });
  final TextEditingController firstTextController;
  final TextEditingController? secondTextController;
  final String boardTitle;
  final String firstFieldHeadInBlack;
  final String firstFieldHeadInBlue;
  final String secondFieldHeadInBlack;
  final String secondFieldHeadInBlue;
  final int? textlenght1;
  final int? textlenght2;
  final Color tapColor;
  final Function() boardTap;
  final Function() suffixTap1;
  final Function() suffixTap2;
  final String tapText;
  final bool isSingleField;
  final bool isOr;
  final bool isObsecureFirst;
  final bool isObsecureSecond;
  final ScalingController scalingController = Get.find();
  final IconData? suffixFirst;
  final IconData? suffixSecond;
  final String? prefixFirst;
  final String? prefixSecond;
  final String hintFirst;
  final String hintSecond;
  final TextInputType? keyboardType;
  final String? Function(String?)? fieldValidator1;
  final String? Function(String?)? fieldValidator2;
  final formKey = GlobalKey<FormState>();

  ForgotPasswordController forgotPasswordController = Get.find();
  AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return CustomBackgroundPage(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(
                              () => Transform.scale(
                                scale: scalingController.scaleFactor.value,
                                child: Image.asset(
                                  mainLogo,
                                  scale: 5.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Closerrr...",
                              style: CustomTextStyle
                                  .styledTextWidget.titleLarge!
                                  .copyWith(
                                      fontSize: 25.sp, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                      SizedBox(
                        width: 100.w,
                        child: Text(
                          boardTitle,
                          style: CustomTextStyle.styledTextWidget.displayLarge
                              ?.copyWith(color: headingColor),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      SizedBox(
                        width: 100.w,
                        child: RichText(
                          text: TextSpan(
                            text: firstFieldHeadInBlack,
                            style:
                                CustomTextStyle.styledTextWidget.displayMedium,
                            children: [
                              TextSpan(
                                text: firstFieldHeadInBlue,
                                style: CustomTextStyle
                                    .styledTextWidget.displayMedium
                                    ?.copyWith(
                                  color: blueBack,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: ":",
                                style: CustomTextStyle
                                    .styledTextWidget.displayMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      CustomTextFormField(
                        onTapSuffix: suffixTap1,
                        isMaxLine: 1,
                        textLength: textlenght1,
                        validator: fieldValidator1,
                        suffixIcon: suffixFirst,
                        hintText: hintFirst,
                        obscureText: isObsecureFirst,
                        prefixIcon: prefixFirst,
                        controller: firstTextController,
                        keyboardType: keyboardType!,
                      ),
                      if (isSingleField) ...{
                        Obx(() {
                          if (authController.siginError.value.isNotEmpty) {
                            return Container(
                              margin: EdgeInsets.only(top: 2.h),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                authController.siginError.value,
                                style: CustomTextStyle
                                    .styledTextWidget.labelMedium!
                                    .copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                        SizedBox(height: 1.h),
                        SizedBox(height: 2.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Or If You Don't Have An Account, ",
                                  style: CustomTextStyle
                                      .styledTextWidget.displayMedium
                                      ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        (widthScale * kTextFormFactor) * 14,
                                  ),
                                ),
                                TextSpan(
                                  text: "Sign Up Here!",
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      RouterController.current.push(
                                        '/signup-screen',
                                      );
                                    },
                                  style: CustomTextStyle
                                      .styledTextWidget.displayMedium
                                      ?.copyWith(
                                    decoration: TextDecoration.underline,
                                    color: blueBack,
                                    fontSize:
                                        (widthScale * kTextFormFactor) * 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      } else ...{
                        SizedBox(height: 2.h),
                      },
                      if (isOr)
                        Text(
                          "OR",
                          style: CustomTextStyle.styledTextWidget.displayLarge
                              ?.copyWith(fontSize: 16.sp, color: headingColor),
                        ),
                      SizedBox(height: 3.h),
                      if (!isSingleField)
                        Column(
                          children: [
                            SizedBox(
                              width: 100.w,
                              child: Wrap(
                                children: [
                                  Text(
                                    secondFieldHeadInBlack,
                                    style: CustomTextStyle
                                        .styledTextWidget.displayMedium,
                                  ),
                                  Text(
                                    secondFieldHeadInBlue,
                                    style: CustomTextStyle
                                        .styledTextWidget.displayMedium
                                        ?.copyWith(
                                      color: blueBack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    ":",
                                    style: CustomTextStyle
                                        .styledTextWidget.displayMedium,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            CustomTextFormField(
                              onTapSuffix: suffixTap2,
                              textLength: textlenght2,
                              isMaxLine: 1,
                              suffixIcon: suffixSecond,
                              validator: fieldValidator2,
                              hintText: hintSecond,
                              obscureText: isObsecureSecond,
                              prefixIcon: prefixSecond,
                              controller: secondTextController!,
                            ),
                          ],
                        ),
                      SizedBox(height: !isSingleField ? 12.h : 30.h),
                      AuthMainButton(
                        buttonColor: tapColor,
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            boardTap();
                          }
                        },
                        buttonText: tapText,
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                  Positioned(
                    top: 4.h,
                    left: 0.w,
                    child: GestureDetector(
                      onTap: () {
                        RouterController.current.pop();
                      },
                      child: Container(
                        height: 5.h,
                        width: 5.h,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, -.1),
                              blurRadius: 1.0,
                            ),
                          ],
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(50.sp),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: primaryColor,
                          size: 3.h,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
