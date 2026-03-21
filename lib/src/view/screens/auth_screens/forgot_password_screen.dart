import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/authentication/password_controller.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ForgotPasswordController forgotPasswordController = Get.find();

  @override
  void initState() {
    super.initState();
    forgotPasswordController.isForgotScreen = true;
    forgotPasswordController.clearField();
    forgotPasswordController.forgotNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => OnboardingWidget(
        fieldValidator1: (String? value) {
          if ((value == null || value.isEmpty) &&
              (forgotPasswordController.forgotNumberController.text.isEmpty)) {
            return 'Please enter your email address or mobile number';
          } else if (value != null &&
              value.isNotEmpty &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
        fieldValidator2: (String? value) {
          if ((value == null || value.isEmpty) &&
              (forgotPasswordController.forgotEmailController.text.isEmpty)) {
            return 'Please enter your mobile number or email address';
          } else if (value != null &&
              value.isNotEmpty &&
              !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
            return 'Please enter a valid mobile number with country code';
          }
          return null;
        },
        firstTextController: forgotPasswordController.forgotEmailController,
        secondTextController: forgotPasswordController.forgotNumberController,
        textlenght2: 10,
        boardTitle: "Forgot Your Password?",
        firstFieldHeadInBlack: "Reset With Your Registered ",
        firstFieldHeadInBlue: "Email",
        secondFieldHeadInBlack: "Reset With Your Registered 10 Digit ",
        secondFieldHeadInBlue: "Mobile Number",
        tapColor: forgotPasswordController.isFormFilled.value
            ? primaryColor
            : primaryColor.withOpacity(0.5),
        boardTap: () {
          if (forgotPasswordController.isFormFilled.value) {
            forgotPasswordController.resendOtp();
          }
        },
        isOr: true,
        prefixFirst: mailIcon,
        prefixSecond: phoneIcon,
        tapText: "SEND OTP",
        isSingleField: false,
        isObsecureFirst: false,
        isObsecureSecond: false,
        hintFirst: "Your Registered Email Address",
        hintSecond: "Your Registered Mobile Number",
        suffixTap1: () {},
        suffixTap2: () {},
      ),
    );
  }
}
