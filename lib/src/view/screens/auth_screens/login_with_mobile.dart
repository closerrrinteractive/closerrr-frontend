import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    authController.isSignUpScreen = false;
    authController.isLoginWithNum = true;
    authController.siginError.value = '';
    authController.numberController.clear();
  }

  @override
  void dispose() {
    authController.isLoginWithNum = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => OnboardingWidget(
        firstTextController: authController.numberController,
        boardTitle: 'Sign In With Mobile',
        firstFieldHeadInBlack: 'Enter Your Registered 10 Digit ',
        firstFieldHeadInBlue: 'Mobile Number',
        secondFieldHeadInBlack: '',
        secondFieldHeadInBlue: '',
        tapColor: authController.isFormFilled.value
            ? primaryColor
            : primaryColor.withOpacity(0.5),
        boardTap: () async {
          await authController.signIn(isMobile: true);
        },
        tapText: 'SEND OTP',
        isSingleField: true,
        isOr: false,
        isObsecureFirst: false,
        isObsecureSecond: false,
        fieldValidator1: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your mobile number';
          }
          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
            return 'Please enter a valid 10 digit mobile number';
          }
          return null;
        },
        prefixFirst: phoneIcon,
        hintFirst: 'Your Registered Mobile Number',
        hintSecond: '',
        textlenght1: 10,
        keyboardType: TextInputType.phone,
        suffixTap1: () {},
        suffixTap2: () {},
      ),
    );
  }
}
