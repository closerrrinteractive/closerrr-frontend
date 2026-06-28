import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routing/routing_controller.dart';

class VerifyOtpController extends GetxController {
  final TextEditingController verificationController = TextEditingController();
  final RxString emailOtp = ''.obs;
  final UserInformationController userInformationController = Get.find();
  var isFormFilled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen for changes in the text controller and update the button's status
    verificationController.addListener(_updateFormFilledStatus);
  }

  void _updateFormFilledStatus() {
    // Enable the button only if the input is exactly 5 digits
    isFormFilled.value = verificationController.text.length == 5;
  }

  Future verifyEmail(
      {required String verifyType, required String verifyEvent}) async {
    try {
      CustomLoader.show();
      await userInformationController.getUserData();
      Map<String, String>? data = {};

      if (userInformationController.userData.isNotEmpty) {
        data = {
          'user_id': userInformationController.userData['id'].toString(),
          'otp': emailOtp.value,
          'type': verifyType,
          'event': verifyEvent
        };
      }

      final response = await httpService.post(ApiStrings.verifyOtp, data: data);
      if (isSuccessStatusCode(response.statusCode!)) {
        await userInformationController.setUserData(response.data["data"]);
        await Future.delayed(const Duration(
            milliseconds: 300)); // without this redirects to splash
        CustomSnackbar.show(
            title: 'Success',
            message: response.data['message'],
            isError: false);
        CustomLoader.hide();
        if (verifyEvent == "forgot_password") {
          RouterController.current.pushReplacement('/reset-password');
        } else if (verifyEvent == "signin") {
          final userData = response.data['data'];
          final isOnboarded = userData['is_onboarded'] == true ||
              userData['is_onboarded'] == 1;
          if (isOnboarded) {
            RouterController.current.push(
              '/transition',
              extra: {'imagePath': bringCloserrr},
            );
            await Future.delayed(const Duration(seconds: 2));
            final route = userData['role_id'] == 3 ? '/chat' : '/explore';
            RouterController.current.go(route);
          } else {
            RouterController.current.pushReplacement('/onboard-profile');
          }
        } else {
          RouterController.current.pushReplacement('/onboard-profile');
        }
        verificationController.clear();
      } else {
        CustomSnackbar.show(
            title: 'Error', message: response.data['message'], isError: true);
      }
    } on Exception catch (e) {
      kLog('Error: $e');
    } finally {
      CustomLoader.hide();
    }
  }

  Future resendVerifyEmail({required String verifyEvent}) async {
    try {
      CustomLoader.show();
      await userInformationController.getUserData();
      Map<String, String>? data = {};

      if (userInformationController.userData.isNotEmpty) {
        data = {
          'user_id': userInformationController.userData['id'].toString(),
          'event': verifyEvent
        };
      }

      final response = await httpService.post(ApiStrings.resendOtp, data: data);
      if (isSuccessStatusCode(response.statusCode!)) {
        CustomSnackbar.show(
          title: 'Success',
          message: response.data['message'],
          isError: false,
        );
      } else {
        CustomSnackbar.show(
          title: 'Error',
          message: response.data['message'],
          isError: true,
        );
      }
    } on Exception catch (e) {
      kLog('Error: $e');
    } finally {
      CustomLoader.hide();
    }
  }
}
