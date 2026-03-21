import 'dart:io';

import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/controller/custom_controllers/pick_image_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:dio/dio.dart' as dio_instance;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routing/routing_controller.dart';

class OnboardProfileController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final UserInformationController userInformationController = Get.find();
  var selectedGender = ''.obs;
  var isGenderValid = true.obs;

  final isFormFilled = false.obs;
  final isFormFilled1 = false.obs;

  final showVerifyMessage = ''.obs;
  final isGooglePrefilled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen for changes in both text controllers and update the observable
    usernameController.addListener(_updateFormFilledStatus1);
    fullnameController.addListener(_updateFormFilledStatus1);
    addressController.addListener(_updateFormFilledStatus1);
    birthdayController.addListener(_updateFormFilledStatus1);
    mobileNumberController.addListener(_updateFormFilledStatus);
  }

  void _updateFormFilledStatus() {
    // For Sign-Up screen
    isFormFilled.value = mobileNumberController.text.length == 10;
  }

  void _updateFormFilledStatus1() {
    // For Sign-Up screen
    isFormFilled1.value = usernameController.text.isNotEmpty &&
        fullnameController.text.isNotEmpty &&
        birthdayController.text.isNotEmpty &&
        addressController.text.isNotEmpty;
  }

  // Function to update the selected gender
  void selectGender(String gender) {
    selectedGender.value = gender;
    isGenderValid.value = true; // Reset validation state on selection
  }

  // Function to validate the gender selection
  bool validateGender() {
    if (selectedGender.value.isEmpty) {
      isGenderValid.value = false; // Mark as invalid if no gender selected
      return false;
    }
    isGenderValid.value = true;
    return true;
  }

  // Function to send data to the backend (replace with your API call)
  void sendGenderToBackend() {
    if (validateGender()) {
      kLog('Sending selected gender: ${selectedGender.value} to the backend');
      // Add API call logic here
    }
  }

  Future onBoardProfile() async {
    try {
      final PickImageController pickImageController = Get.find();

      // Format the birthdayController text to use '/' instead of '-'
      String formattedBirthday = birthdayController.text;
      // Check if gender is selected
      if (selectedGender.value.isEmpty) {
        CustomLoader.hide();
        CustomSnackbar.show(
          title: 'Missing Gender',
          message: 'Please select a gender to proceed.',
          isError: true,
        );
        return;
      }
      if (addressController.text.isEmpty) {
        CustomLoader.hide();
        CustomSnackbar.show(
          title: 'Missing Address',
          message: 'Please add address to proceed.',
          isError: true,
        );
        return;
      }

      // Initialize the data map
      Map<String, dynamic> data = {
        'username': usernameController.text.trim(), // Trim spaces
        'fullname': fullnameController.text.trim(), // Trim spaces
        'gender': selectedGender.value,
        'address': addressController.text, // Trim spaces
        'birthday': formattedBirthday, // Use formatted birthday
      };

      // Include profile_pic only if profileImg is not null
      final File? profileImg = pickImageController.imagePath.value;
      if (profileImg != null && profileImg.path.isNotEmpty) {
        data['profile_pic'] = await dio_instance.MultipartFile.fromFile(
          profileImg.path,
        );
      }

      // Make the API request
      final response =
          await httpService.post(ApiStrings.onboardProfile, data: data);

      if (isSuccessStatusCode(response.statusCode!)) {
        Map<String, dynamic>? userData =
            await userInformationController.getUserData();
        userData!["is_onboarded"] = true;
        userData["Profile"] = response.data["data"]["Profile"];
        await userInformationController.setUserData(userData);

        // CustomSnackbar.show(
        //     title: 'Success',
        //     message: response.data['message'],
        //     isError: false);
        kLog(response.data['data']);

        await _playTransition(accountCreated, bringCloserrr);

        RouterController.current.go('/splash');
      } else {
        CustomSnackbar.show(
          title: 'Failure',
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

  Future<void> _playTransition(String firstImage, [String? secondImage]) async {
    RouterController.current
        .push('/transition', extra: {'imagePath': firstImage});
    await Future.delayed(const Duration(seconds: 2));
    if (secondImage != null) {
      RouterController.current
          .push('/transition', extra: {'imagePath': secondImage});
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future verifyMobileNumber() async {
    try {
      CustomLoader.show();
      showVerifyMessage.value = '';

      Map<String, dynamic>? data = {};

      // If mobile field is filled
      if (mobileNumberController.text.isNotEmpty) {
        data = {
          "type": "mobile",
          "event": "signup",
          "mobile": mobileNumberController.text,
          "email": userInformationController.userData['email']
        };
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
        showVerifyMessage.value =
            response.data['message'].contains("Otp sent, Please verify")
                ? "OTP Successfully Sent."
                : "";
        // CustomSnackbar.show(
        //   title: 'Success',
        //   message: response.data['message'],
        //   isError: false,
        // );
        // await userInformationController.setUserData(response.data['data']);
      }
    } catch (e) {
      kLog("Error $e");
    } finally {
      CustomLoader.hide();
    }
  }
}
