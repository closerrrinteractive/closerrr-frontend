import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/authentication/verify_otp_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_background_screen.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/auth_main_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String verifyType;
  final String verifyEvent;
  const VerifyOtpScreen({
    super.key,
    required this.verifyType,
    required this.verifyEvent,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final ScalingController scalingController = Get.find();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final VerifyOtpController verifyOtpController = Get.find();

  @override
  void initState() {
    super.initState();
    verifyOtpController.verificationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackgroundPage(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
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
                                style: CustomTextStyle
                                    .styledTextWidget.titleLarge!
                                    .copyWith(
                                  fontSize: 25.sp,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      SizedBox(
                        width: 100.w,
                        child: Text(
                          "Enter OTP:",
                          style: CustomTextStyle.styledTextWidget.displayLarge
                              ?.copyWith(
                            color: headingColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      SizedBox(
                        width: 100.w,
                        child: RichText(
                          text: TextSpan(
                            style:
                                CustomTextStyle.styledTextWidget.displayMedium,
                            children: [
                              const TextSpan(
                                text: "Please Enter The ",
                              ),
                              TextSpan(
                                text: "One Time Password",
                                style: CustomTextStyle
                                    .styledTextWidget.displayMedium
                                    ?.copyWith(
                                  color: blueBack,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(
                                text: " We Just Sent You:",
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Form(
                        key: formKey,
                        child: SizedBox(
                          height: 10.h,
                          width: 100.w,
                          child: PinCodeTextField(
                            enableActiveFill: true,
                            showCursor: true,
                            cursorColor: primaryColor,
                            autoDisposeControllers: false,
                            appContext: context,
                            length: 5,
                            controller:
                                verifyOtpController.verificationController,
                            pinTheme: PinTheme(
                              activeFillColor: whiteColor,
                              inactiveFillColor: whiteColor,
                              selectedFillColor: whiteColor,
                              shape: PinCodeFieldShape.box,
                              activeColor: primaryColor.withOpacity(0.8),
                              inactiveColor: primaryColor.withOpacity(0.6),
                              selectedColor: primaryColor.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10.sp),
                              activeBorderWidth: 1.5,
                              inactiveBorderWidth: 1.5,
                              borderWidth: 1.5,
                              selectedBorderWidth: 1.5,
                              fieldHeight: 60.0,
                              fieldWidth: 60.0,
                            ),
                            textStyle: CustomTextStyle
                                .styledTextWidget.displayMedium
                                ?.copyWith(
                                    color: primaryColor, fontSize: 20.sp),
                            onChanged: (value) {
                              verifyOtpController.emailOtp.value = value;
                            },
                            keyboardType: TextInputType.number,
                            autoDismissKeyboard: true,
                            autoFocus: true,
                            animationType: AnimationType.fade,
                            animationDuration:
                                const Duration(milliseconds: 300),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Did Not Recieve OTP?",
                            style:
                                CustomTextStyle.styledTextWidget.displayMedium,
                          ),
                          SizedBox(
                            width: 1.w,
                          ),
                          GestureDetector(
                            onTap: () async {
                              verifyOtpController.verificationController
                                  .clear();
                              await verifyOtpController.resendVerifyEmail(
                                  verifyEvent: widget.verifyEvent);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Resend OTP",
                                style: CustomTextStyle
                                    .styledTextWidget.displayMedium
                                    ?.copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: blueBack,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      blueBack, // Set underline color to white
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Obx(
                        () => AuthMainButton(
                            buttonColor: verifyOtpController.isFormFilled.value
                                ? primaryColor
                                : primaryColor.withOpacity(0.5),
                            onTap: () {
                              if (verifyOtpController.isFormFilled.value) {
                                verifyOtpController.verifyEmail(
                                    verifyEvent: widget.verifyEvent,
                                    verifyType: widget.verifyType);
                              }
                            },
                            buttonText: "VERIFY OTP"),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 4.h,
                    left: 0.w,
                    child: GestureDetector(
                      onTap: () {
                        if (RouterController.current.canPop()) {
                          RouterController.current.pop();
                        } else {
                          RouterController.current.go('/signin-screen');
                        }
                      },
                      child: Container(
                        height: 5.h,
                        width: 5.h,
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, -.1), //(x,y)
                                blurRadius: 1.0,
                              ),
                            ],
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(50.sp)),
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
