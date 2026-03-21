import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/auth_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final AuthController authController = Get.find();
  @override
  void initState() {
    super.initState();
    authController.isSignUpScreen = false;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenWidget(
      isSinginScreen: true,
      authMainTap: () async {
        await authController.signIn(isMobile: false);
      },
    );
  }
}
