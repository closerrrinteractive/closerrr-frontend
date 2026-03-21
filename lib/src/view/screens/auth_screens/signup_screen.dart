import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/auth_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingupScreen extends StatefulWidget {
  const SingupScreen({super.key});

  @override
  State<SingupScreen> createState() => _SingupScreenState();
}

class _SingupScreenState extends State<SingupScreen> {
  final AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    authController.isSignUpScreen = true;
    // emailController.text.isNotEmpty;
    //       enterPasswordController.text.isNotEmpty;
    //       reEnterPasswordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenWidget(
      isSinginScreen: false,
      authMainTap: () async {
        await authController.signUp();
      },
    );
  }
}
