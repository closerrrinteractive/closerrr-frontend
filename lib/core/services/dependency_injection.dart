import 'package:closerrr/core/services/connectivity_status_service.dart';
import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/controller/authentication/google_maps_controller.dart';
import 'package:closerrr/src/controller/authentication/password_controller.dart';
import 'package:closerrr/src/controller/authentication/third_party_auth_controller.dart';
import 'package:closerrr/src/controller/authentication/verify_otp_controller.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/custom_controllers/app_links_controller.dart';
import 'package:closerrr/src/controller/custom_controllers/pick_image_controller.dart';
import 'package:closerrr/src/controller/navbar_cntrollers/navbar_controller.dart';
import 'package:closerrr/src/controller/notification/notification_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/onboard_profile_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/onboarding_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../src/controller/event_controllers/event_controller.dart';
import '../../src/controller/explore_controllers/explore_screen_controller.dart';
import '../../src/controller/live/live_controller.dart';
import '../../src/controller/routing/routing_controller.dart';
import '../../src/controller/settings_controller/settings_controller.dart';

class DependencyInjection {
  static final dio = Dio(BaseOptions(baseUrl: ApiStrings.baseUrl));
  static inject() async {
    Get.put(NavbarController());
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
    Get.lazyPut(() => UserInformationController());
    Get.put(CoreSocketServices());
    Get.put(NotificationController());
    Get.put(ScalingController());
    Get.put(OnBoardingSliderController());
    Get.put(AuthController());
    Get.put(ThirdPartyAuthController());
    Get.put(VerifyOtpController());
    Get.put(ForgotPasswordController());
    Get.put(OnboardProfileController());
    Get.put(PickImageController());
    Get.put(ChatController(dio));
    Get.put(ExploreScreenController());
    Get.lazyPut(() => EventScreenController());
    Get.put(GoogleMapsController());
    Get.put(SettingScreenController());
    Get.put(LiveController());
    Get.put(RouterController());
    Get.put(AppLinkController());
  }
}
