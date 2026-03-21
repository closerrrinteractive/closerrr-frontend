import 'dart:convert';
import 'dart:developer';

import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/controller/authentication/third_party_auth_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navbar_cntrollers/navbar_controller.dart';
import '../routing/routing_controller.dart';

/// 🔹 Local Storage for flags
class LocalStorageService {
  static const _isNewUserKey = "is_new_user";

  static Future<void> setNewUser(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isNewUserKey, value);
  }

  static Future<bool> getIsNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isNewUserKey) ?? true;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isNewUserKey);
  }
}

/// 🔹 Email / Mobile Auth Controller
///
class AuthController extends GetxController {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController enterPasswordController = TextEditingController();
  final TextEditingController reEnterPasswordController =
      TextEditingController();
  final UserInformationController userInformationController = Get.find();
  final NavbarController navbarController = Get.find();
  // Observables to watch the text field states
  final isFormFilled = false.obs;
  bool isSignUpScreen = false;
  bool isLoginWithNum = false;

  final siginError = ''.obs;
  @override
  void onInit() {
    super.onInit();
    // Listen for changes in both text controllers and update the observable
    emailController.addListener(_updateFormStatus);
    enterPasswordController.addListener(_updateFormStatus);
    reEnterPasswordController.addListener(_updateFormStatus);
    numberController.addListener(_updateFormStatus);
  }

  void _updateFormStatus() {
    if (isSignUpScreen) {
      // For Sign-Up screen
      isFormFilled.value = emailController.text.isNotEmpty &&
          enterPasswordController.text.isNotEmpty &&
          reEnterPasswordController.text.isNotEmpty;
    } else if (isLoginWithNum) {
      isFormFilled.value = numberController.text.length == 10;
    } else if (!isSignUpScreen) {
      // For Sign-In screen
      isFormFilled.value = emailController.text.isNotEmpty &&
          enterPasswordController.text.isNotEmpty;
    }
  }

  final obscureText1 = true.obs;
  final obscureText2 = true.obs;
  final RxBool toggleButton = false.obs;

  void togglePasswordVisibility1() {
    obscureText1.value = !obscureText1.value;
  }

  void togglePasswordVisibility2() {
    obscureText2.value = !obscureText2.value;
  }

  void rememberToggle() {
    toggleButton.toggle();
  }

  Future signUp() async {
    try {
      CustomLoader.show();
      Map<String, String>? data = {};

      if (emailController.text.isNotEmpty &&
          enterPasswordController.text.isNotEmpty &&
          reEnterPasswordController.text.isNotEmpty) {
        data = {
          'email': emailController.text,
          'password': enterPasswordController.text,
          'confirm_password': reEnterPasswordController.text,
          'role': 'FAN'
        };
      }
      final response = await httpService.post(ApiStrings.signUp, data: data);
      if (isSuccessStatusCode(response.statusCode!)) {
        await userInformationController.setUserData(response.data['data']);
        await Future.delayed(const Duration(
            milliseconds: 300)); // without this redirects to splash
        RouterController.current.push('/verify-otp/email/signup');
      } else {
        CustomSnackbar.show(
          title: 'Failure',
          message: response.data['message'],
          isError: true,
        );
      }
    } catch (error) {
      kLog('Error: $error');
    } finally {
      CustomLoader.hide();
    }
  }

  Future signIn({required bool isMobile, String? routeManage}) async {
    try {
      CustomLoader.show();
      Map<String, String>? data = {};

      if (isMobile) {
        if (numberController.text.isNotEmpty) {
          data = {'mobile': numberController.text};
        }
      } else {
        if (emailController.text.isNotEmpty &&
            enterPasswordController.text.isNotEmpty) {
          data = {
            'email': emailController.text,
            'password': enterPasswordController.text,
          };
        }
      }

      final response = await httpService.post(
        ApiStrings.signIn,
        isFormData: false,
        data: data,
      );
      siginError.value = '';
      print("Hey debug");
      print(response);

      // log(jsonEncode(response.data['data']));
      if (isSuccessStatusCode(response.statusCode!)) {
        if (response.data["message"] == "Otp sent, Please verify") {
          siginError.value = "OTP Successfully Sent.";

          log(jsonEncode(response.data['data']));
          await userInformationController.setUserData(
            {"id": response.data["data"]["user_id"]},
          );
          await Future.delayed(const Duration(seconds: 2));
          return RouterController.current.push('/verify-otp/email/signin');
        }

        CustomSnackbar.show(
          title: 'Success',
          message: 'Login Successfully',
          isError: false,
        );
        await userInformationController.setUserData(response.data['data']);
        RouterController.current.push(
          '/transition',
          extra: {'imagePath': bringCloserrr},
        );
        await Future.delayed(const Duration(seconds: 2));
        String route = userInformationController.userData["role_id"] == 3
            ? "/chat"
            : "/explore";
        RouterController.current.go(routeManage ?? route);
        disposeController();
      } else {
        siginError.value = response.data['error_message']
                .contains('Email or mobile not registered')
            ? 'Incorrect. Please Re-enter Correct Registered Mobile Number'
            : '';
      }
    } catch (error) {
      kLog('Error: $error');
    } finally {
      CustomLoader.hide();
    }
  }

  Future<void> logout() async {
    try {
      CustomLoader.show();
      // Sign out from Google
      final ThirdPartyAuthController thirdPartyController = Get.find();
      if (await thirdPartyController.googleSignIn.isSignedIn()) {
        await thirdPartyController.googleSignIn.signOut();
      }
      await userInformationController.deleteUserData();
      // Clear local storage
      await LocalStorageService.clear();
      navbarController.selectIndex.value = 0;
      RouterController.current.go('/signin-screen');
      // await StreamVideo.reset();
    } catch (error) {
      kLog('Error: $error');
    } finally {
      CustomLoader.hide();
    }
  }

  void goToSignIn() {
    // Navigate to the sign-in paged
    RouterController.current.push("/signin-screen");
    disposeController();
  }

  void goToSignUp() {
    // Navigate to the sign-in page
    RouterController.current.push("/signup-screen");
    disposeController();
  }

  void disposeController() {
    emailController.clear();
    enterPasswordController.clear();
    reEnterPasswordController.clear();
    obscureText1.value = true;
    obscureText2.value = true;
  }
}
