import 'dart:io';
import 'package:closerrr/core/services/custom_services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PickImageController extends GetxController {
  Rx<File?> imagePath = Rx<File?>(null);

  Future<void> getImagePicker({required bool isCamera}) async {
    try {
      CustomLoader.show();
      final pickedImageFile = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedImageFile != null) {
        imagePath.value = File(pickedImageFile.path);
      }
    } catch (e) {
      kLog('Error while picking image: $e');
    } finally {
      CustomLoader.hide();
    }
  }
}
