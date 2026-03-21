import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showIpAddressDialog() {
  TextEditingController ipController = TextEditingController();

  Get.dialog(
    AlertDialog(
      title: const Text('Enter IP Address'),
      content: TextField(
        controller: ipController,
        decoration: const InputDecoration(
          hintText: 'IP Address',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Handle cancel
            Get.back(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Get the entered IP address and update the controller
            String enteredIp = ipController.text;

            // Update the controller (example for GetX)
            Get.find<UserInformationController>().ipAddress.value = enteredIp;

            // Close the dialog
            Get.back();
          },
          child: const Text('Submit'),
        ),
      ],
    ),
    barrierDismissible:
        false, // Prevents the dialog from being dismissed by tapping outside
  );
}
