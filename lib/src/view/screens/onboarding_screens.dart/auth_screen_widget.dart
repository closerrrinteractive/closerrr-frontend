import 'dart:io';

import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/controller/authentication/third_party_auth_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_background_screen.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_green_button.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/auth_main_button.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/custom_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/routing/routing_controller.dart';

class AuthScreenWidget extends StatefulWidget {
  const AuthScreenWidget({
    super.key,
    required this.isSinginScreen,
    required this.authMainTap,
  });
  final bool isSinginScreen;
  final VoidCallback authMainTap;

  @override
  State<AuthScreenWidget> createState() => _AuthScreenWidgetState();
}

class _AuthScreenWidgetState extends State<AuthScreenWidget> {
  final AuthController authController = Get.find();

  final formKey = GlobalKey<FormState>();
  final ThirdPartyAuthController thirdPartyAuthController = Get.find();
  final ScalingController scalingController = Get.find();

  @override
  void initState() {
    super.initState();
    authController.emailController.clear();
    authController.enterPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackgroundPage(
        child: Scaffold(
      backgroundColor: Colors.transparent, // Add this
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
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
                          style: CustomTextStyle.styledTextWidget.titleLarge!
                              .copyWith(
                            fontSize: 25.sp,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                SizedBox(
                  width: 100.w,
                  child: Text(
                    widget.isSinginScreen ? "Sign in" : "Create Account:",
                    style: CustomTextStyle.styledTextWidget.displayLarge
                        ?.copyWith(color: headingColor),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                CustomTextFormField(
                  isMaxLine: 1,
                  prefixIcon: mailIcon,
                  hintText: "Your Email Address",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  controller: authController.emailController,
                ),
                SizedBox(
                  height: 2.5.h,
                ),
                Obx(
                  () => CustomTextFormField(
                    isMaxLine: 1,
                    prefixIcon: unlockIcon,
                    hintText: "Your Password",
                    suffixIcon: authController.obscureText1.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (value.trim().isEmpty) {
                        return 'Only spaces are not allowed';
                      }
                      if (value != value.trim()) {
                        return 'No spaces at the start or end';
                      }
                      return null;
                    },
                    onTapSuffix: () {
                      authController.togglePasswordVisibility1();
                    },
                    obscureText: authController.obscureText1.value,
                    controller: authController.enterPasswordController,
                  ),
                ),
                SizedBox(
                  height: 2.5.h,
                ),
                if (!widget.isSinginScreen)
                  Obx(
                    () => CustomTextFormField(
                      isMaxLine: 1,
                      suffixIcon: authController.obscureText2.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onTapSuffix: () {
                        authController.togglePasswordVisibility2();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please re-enter Password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (value.trim().isEmpty) {
                          return 'Only spaces are not allowed';
                        }
                        if (value != value.trim()) {
                          return 'No spaces at the start or end';
                        }
                        if (value !=
                            authController.enterPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      obscureText: authController.obscureText2.value,
                      prefixIcon: unlockIcon,
                      hintText: "Re-enter Your Password",
                      controller: authController.reEnterPasswordController,
                    ),
                  ),
                SizedBox(
                  height: widget.isSinginScreen ? 1.5.h : 5.h,
                ),
                if (widget.isSinginScreen)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Obx(
                            () => CustomToggleButton(
                              onToggle: authController.rememberToggle,
                              isToggle: authController.toggleButton.value,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "Remember Me",
                            style: CustomTextStyle
                                .styledTextWidget.headlineLarge!
                                .copyWith(color: headingColor, fontSize: 12.sp),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          RouterController.current.push("/forgot-password");
                        },
                        child: Text(
                          "Forgot Password?",
                          style: CustomTextStyle.styledTextWidget.headlineLarge!
                              .copyWith(color: headingColor, fontSize: 12.sp),
                        ),
                      )
                    ],
                  ),
                if (widget.isSinginScreen) SizedBox(height: 2.5.h),
                Obx(() {
                  return AuthMainButton(
                    buttonColor: authController.isFormFilled.value
                        ? primaryColor
                        : primaryColor.withOpacity(0.5),
                    onTap: () {
                      if (authController.isFormFilled.value &&
                          formKey.currentState!.validate()) {
                        widget.authMainTap();
                      }
                    },
                    buttonText: widget.isSinginScreen ? "SIGN IN" : "SEND OTP",
                  );
                }),
                SizedBox(
                  height: 2.5.h,
                ),
                Text(
                  "OR",
                  style: CustomTextStyle.styledTextWidget.displayLarge
                      ?.copyWith(fontSize: 16.sp, color: headingColor),
                ),
                SizedBox(
                  height: 2.5.h,
                ),
                if (widget.isSinginScreen)
                  CustomGreenButton(
                    onTap: () {
                      RouterController.current.push('/mobile-login');
                    },
                    buttonText:
                        "Sign ${widget.isSinginScreen ? 'In' : 'Up'} With Mobile Number",
                    buttonWidth: 75.w,
                    backButtonColor: blueBack,
                    textColor: whiteColor,
                    isImage: true,
                    imageIcon: phoneSignin,
                    borderRad: 10.h,
                  ),
                if (widget.isSinginScreen)
                  SizedBox(
                    height: 2.h,
                  ),
                if (Platform.isIOS)
                  CustomGreenButton(
                    onTap: () async {
                      CustomLoader.show();
                      await thirdPartyAuthController.signInWithApple();
                      CustomLoader.hide();
                    },
                    buttonText:
                        "Sign ${widget.isSinginScreen ? 'In' : 'Up'} With Apple",
                    buttonWidth: 75.w,
                    borderRad: 10.h,
                    backButtonColor: primaryColor,
                    textColor: whiteColor,
                    isImage: true,
                    imageIcon: appleSignin,
                  ),
                if (!Platform.isIOS)
                  SizedBox(
                    height: 2.h,
                  ),
                if (!Platform.isIOS)
                  CustomGreenButton(
                    onTap: () async {
                      CustomLoader.show();
                      await thirdPartyAuthController.signInWithGoogle();
                      CustomLoader.hide();
                    },
                    buttonText:
                        "Sign ${widget.isSinginScreen ? 'In' : 'Up'} With Google",
                    buttonWidth: 75.w,
                    backButtonColor: primaryColor,
                    textColor: whiteColor,
                    isImage: true,
                    imageIcon: googleSignin,
                    borderRad: 10.h,
                  ),
                SizedBox(
                  height: widget.isSinginScreen ? 4.h : 8.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.isSinginScreen
                          ? "Don't have an account?"
                          : "Already have an account?",
                      style: CustomTextStyle.styledTextWidget.headlineSmall!
                          .copyWith(fontSize: 13.sp, color: blackColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.isSinginScreen
                            ? authController.goToSignUp()
                            : authController.goToSignIn();
                      },
                      child: Text(
                        widget.isSinginScreen
                            ? " Sign Up Here!"
                            : " Sign In Here!",
                        style: CustomTextStyle.styledTextWidget.titleMedium
                            ?.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: blueBack),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}



// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Obx(() => SizedBox(
//             width: 26,
//             height: 26,
//             child: Checkbox(
//               value:
//                   exploreScreenController.acceptPpAndTAC.value,
//               onChanged: (value) {
//                 exploreScreenController.acceptPpAndTAC.value =
//                     (value ?? false);
//               },
//               activeColor: primaryColor,
//               side: const BorderSide(
//                   color: primaryColor, width: 2.5),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           )),
//       SizedBox(
//         width: 75.w,
//         child: RichText(
//           text: TextSpan(
//             text: '',
//             style: const TextStyle(
//               height: 1.4,
//             ),
//             children: [
//               TextSpan(
//                 text: 'I have read and accept all the',
//                 style: CustomTextStyle
//                     .styledTextWidget.labelLarge!
//                     .copyWith(
//                   fontSize: (widthScale * kTextFormFactor) * 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               TextSpan(
//                 text: ' Terms and Conditions',
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () => showDialog(
//                         context: context,
//                         builder: (context) =>
//                             const TermConditionsAndPrivacyPolicy(),
//                       ),
//                 style: CustomTextStyle
//                     .styledTextWidget.labelLarge!
//                     .copyWith(
//                   fontSize: (widthScale * kTextFormFactor) * 14,
//                   color: primaryColor,
//                   fontWeight: FontWeight.w500,
//                   textBaseline: TextBaseline.alphabetic,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//               TextSpan(
//                 text: ' and',
//                 style: CustomTextStyle
//                     .styledTextWidget.labelLarge!
//                     .copyWith(
//                   fontSize: (widthScale * kTextFormFactor) * 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               TextSpan(
//                 text: ' Privacy Policy',
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () => showDialog(
//                         context: context,
//                         builder: (context) =>
//                             const TermConditionsAndPrivacyPolicy(),
//                       ),
//                 style: CustomTextStyle
//                     .styledTextWidget.labelLarge!
//                     .copyWith(
//                   fontSize: (widthScale * kTextFormFactor) * 14,
//                   color: primaryColor,
//                   fontWeight: FontWeight.w500,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//               TextSpan(
//                 text:
//                     ', and will adhere to them unconditionally.',
//                 style: CustomTextStyle
//                     .styledTextWidget.labelLarge!
//                     .copyWith(
//                   fontSize: (widthScale * kTextFormFactor) * 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )
//     ],
//   ),
// ),
// const SizedBox(height: 24),