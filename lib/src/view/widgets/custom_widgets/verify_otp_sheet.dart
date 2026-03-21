import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/auth_main_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class VerifyOtpSheet extends StatefulWidget {
  final String type;
  const VerifyOtpSheet({super.key, required this.type});

  @override
  State<VerifyOtpSheet> createState() => _VerifyOtpSheetState();
}

class _VerifyOtpSheetState extends State<VerifyOtpSheet> {
  final ScalingController scalingController = Get.find();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final SettingScreenController settingScreenController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settingScreenController.verificationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: blackColor.withAlpha(40),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.sp),
            topRight: Radius.circular(15.sp),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            SizedBox(
              width: 100.w,
              child: Text(
                "Enter OTP:",
                style: CustomTextStyle.styledTextWidget.displayLarge
                    ?.copyWith(color: headingColor),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: 100.w,
              child: RichText(
                text: TextSpan(
                  style: CustomTextStyle
                      .styledTextWidget.displayMedium, // Default style
                  children: [
                    const TextSpan(
                      text: "Please Enter The ",
                    ),
                    TextSpan(
                      text: "One Time Password",
                      style: CustomTextStyle.styledTextWidget.displayMedium
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
                  controller: settingScreenController.verificationController,
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
                  textStyle: CustomTextStyle.styledTextWidget.displayMedium
                      ?.copyWith(color: primaryColor, fontSize: 20.sp),
                  onChanged: (value) {
                    settingScreenController.otp.value = value;
                    if (value.length == 5) {
                      settingScreenController.isFormFilled.value = true;
                    } else {
                      settingScreenController.isFormFilled.value = false;
                    }
                  },
                  keyboardType: TextInputType.number,
                  autoDismissKeyboard: true,
                  animationType: AnimationType.fade,
                  animationDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Did Not Recieve OTP?",
                  style: CustomTextStyle.styledTextWidget.displayMedium,
                ),
                SizedBox(width: 1.w),
                GestureDetector(
                  onTap: () async {
                    settingScreenController.verificationController.clear();
                    await settingScreenController.verifyOtp(
                      type: widget.type,
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Resend OTP",
                      style: CustomTextStyle.styledTextWidget.displayMedium
                          ?.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: blueBack,
                        decoration: TextDecoration.underline,
                        decorationColor: blueBack,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 2.h),
            Obx(
              () => AuthMainButton(
                buttonColor: settingScreenController.isFormFilled.value
                    ? primaryColor
                    : primaryColor.withOpacity(0.5),
                onTap: !settingScreenController.isFormFilled.value
                    ? () {}
                    : () {
                        if (formKey.currentState!.validate()) {
                          if (settingScreenController.otp.value.length < 5) {
                            CustomSnackbar.show(
                              title: 'Invalid OTP',
                              message: 'Invalid OTP',
                              isError: true,
                            );
                            return;
                          }
                          settingScreenController
                              .verifyOtp(
                            type: widget.type,
                          )
                              .then((value) {
                            context.pop(value);
                            if (value) {
                              CustomSnackbar.show(
                                title:
                                    '${widget.type == 'mobile' ? 'Mobile Number' : 'Email'} Verified Successfully',
                                message:
                                    '${widget.type == 'mobile' ? 'Mobile Number' : 'Email'} Verified Successfully',
                                isError: false,
                              );
                            } else {
                              CustomSnackbar.show(
                                title: 'Verification Failed',
                                message: 'Verification Failed',
                                isError: true,
                              );
                            }
                          });
                        }
                      },
                buttonText: "VERIFY OTP",
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
