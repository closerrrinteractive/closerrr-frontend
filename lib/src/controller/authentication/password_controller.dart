import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/controller/authentication/verify_otp_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routing/routing_controller.dart';

class ForgotPasswordController extends GetxController {
  final UserInformationController userInformationController = Get.find();
  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController forgotNumberController = TextEditingController();
  final VerifyOtpController verifyOtpController = Get.find();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool isLoading = false.obs;
  final obscureText1 = true.obs;
  final obscureText2 = true.obs;

  var isFormFilled = false.obs;
  bool isForgotScreen = false;
  @override
  void onInit() {
    super.onInit();
    // Listen for changes in both text controllers and update the observable
    forgotEmailController.addListener(_updateFormFilledStatus);
    forgotNumberController.addListener(_updateFormFilledStatus);
    newPasswordController.addListener(_updateFormFilledStatus);
    confirmPasswordController.addListener(_updateFormFilledStatus);
  }

  void _updateFormFilledStatus() {
    if (isForgotScreen) {
      isFormFilled.value = forgotEmailController.text.isNotEmpty &&
          forgotNumberController.text.length == 10;
    } else {
      isFormFilled.value = newPasswordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
    }
  }

  void togglePasswordVisibility1() {
    obscureText1.value = !obscureText1.value;
  }

  void togglePasswordVisibility2() {
    obscureText2.value = !obscureText2.value;
  }

  Future resendOtp() async {
    try {
      CustomLoader.show();

      Map<String, dynamic>? data = {};
      String? type; // Declare a variable to store the type

      // Check if both fields are filled
      if (forgotEmailController.text.isNotEmpty &&
          forgotNumberController.text.isNotEmpty) {
        CustomSnackbar.show(
            title: 'Error',
            message:
                'Please fill only one field, either email or mobile number.',
            isError: true);
        return; // Stop execution if both fields are filled
      }

      // If email field is filled
      if (forgotEmailController.text.isNotEmpty) {
        data = {
          "type": "email",
          "event": "forgot_password",
          "email": forgotEmailController.text
        };
        type = "email"; // Set type to email
      }

      // If mobile field is filled
      if (forgotNumberController.text.isNotEmpty) {
        data = {
          "type": "mobile",
          "event": "forgot_password",
          "mobile":
              forgotNumberController.text // Fixed from 'email' to 'mobile'
        };
        type = "mobile"; // Set type to mobile
      }

      // If no field is filled, show an error
      if (data.isEmpty) {
        CustomSnackbar.show(
            title: 'Error',
            message: 'Please fill either email or mobile number to proceed.',
            isError: true);
        return;
      }

      // Proceed with API call
      final response = await httpService.post(ApiStrings.sendOtp, data: data);
      if (isSuccessStatusCode(response.statusCode!)) {
        CustomSnackbar.show(
          title: 'Success',
          message: response.data['message'],
          isError: false,
        );
        await userInformationController.setUserData(response.data['data']);

        // Dynamically build the route based on the type
        RouterController.current
            .pushReplacement('/verify-otp/$type/forgot_password');
      }
    } catch (e) {
      kLog("Error $e");
    } finally {
      CustomLoader.hide();
    }
  }

  Future resetPassword() async {
    try {
      CustomLoader.show();

      Map<String, dynamic>? data = {};

      if (newPasswordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty) {
        data = {
          "password": newPasswordController.text,
          "confirm_password": confirmPasswordController.text,
          "otp": verifyOtpController.verificationController.text,
          "user_id": userInformationController.userData['id'].toString()
        };
      }

      final response =
          await httpService.post(ApiStrings.forgotPassword, data: data);
      if (isSuccessStatusCode(response.statusCode!)) {
        CustomSnackbar.show(
            title: 'Success',
            message: response.data['message'],
            isError: false);
        RouterController.current.pushReplacement('/signin-screen');
      }
    } catch (e) {
      kLog("Error $e");
    } finally {
      CustomLoader.hide();
    }
  }

  void clearField() {
    forgotEmailController.clear();
    forgotNumberController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }
}
