import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/main.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  Future setFcmToken({required String fcmToken}) async {
    try {
      Map<String, String>? data = {};

      data = {"fcm_token": fcmToken};

      final response =
          await httpService.post(ApiStrings.saveFcmToken, data: data);
      if (isSuccessStatusCode(response.statusCode!)) {
        // CustomSnackbar.show(
        //     title: 'Success',
        //     message: response.data['message'],
        //     isError: false);
        await Helpers.setString(key: 'FcmToken', value: fcmToken);
        CustomLoader.hide();
      } else {
        CustomSnackbar.show(
            title: 'Failure', message: response.data['message'], isError: true);
        CustomLoader.hide(); 
      }

      return null;
    } catch (error) {
      CustomLoader.hide();
      kLog('Error: $error');
    }
    return null;
  }
}
