import 'dart:async';

import 'package:closerrr/core/services/local_notification_service.dart';
import 'package:closerrr/core/services/notification_service.dart';
import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:closerrr/src/controller/navbar_cntrollers/navbar_controller.dart';
import 'package:closerrr/src/controller/notification/notification_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// import 'package:stream_video_flutter/stream_video_flutter.dart' as getStreamIO;

import '../../../../core/utils/constant.dart';

class HomeDashboard extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeDashboard({super.key, required this.navigationShell});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with WidgetsBindingObserver {
  final UserInformationController userInformationController = Get.find();
  final NotificationController notificationController = Get.find();
  final NavbarController navbarController = Get.find();
  final EventScreenController eventController = Get.find();
  final ChatController chatController = Get.find();
  final ExploreScreenController exploreController = Get.find();
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // if (userInformationController.userData.value['role_id'] == 3) {
      //   navbarController.selectIndex.value = 1;
      // }
      fetchFcm();
      initStream();
      initSocket();
      LocalNotificationService.initialize(context); // Initialize notifications
      PushNotificationService().handleForegroundMsg(context);
      PushNotificationService().handlebackgroundMsg(context);
      PushNotificationService().handleMsgWhenTerminated(context);
    });
  }

  Future<void> fetchFcm() async {
    await PushNotificationService().initNotifications();
    String? fcmToken = await PushNotificationService.fcm.getToken();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    await notificationController.setFcmToken(fcmToken: fcmToken!);
    // String fcmToken = await Helpers.getFcmToken();

    // print("ohh acha");
    // print(fcmToken);

    // if (fcmToken.isEmpty || fcmToken == 'null') {
    //   try {
    //     String? fcmToken = await PushNotificationService.fcm.getToken();
    //     await FirebaseMessaging.instance
    //         .setForegroundNotificationPresentationOptions(
    //             alert: true, badge: true, sound: true);
    //     await notificationController.setFcmToken(fcmToken: fcmToken!);
    //   } catch (e) {
    //     print("Error fetching FCM Token: $e");
    //   }
    // } else {
    //   kLog("FCM Token already exists: $fcmToken");
    // }
  }

  initStream() {
    // final userData = userInformationController.userData;
    // getStreamIO.StreamVideo(
    //   Constants.getStreamIOKey,
    //   user: getStreamIO.User(
    //     info: getStreamIO.UserInfo(
    //       name: userData["Profile"]["username"],
    //       id: userData["id"].toString(),
    //     ),
    //   ),
    //   userToken: userData["stream_token"],
    // );
  }

  initSocket() async {
    print("Socket initialization Started...");
    await CoreSocketServices().connectSocket();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Obx(
        () {
          final isInfluencer =
              userInformationController.userData["role_id"] == 3;

          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: whiteColor,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle:
                  CustomTextStyle.styledTextWidget.headlineMedium!.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp),
              unselectedLabelStyle:
                  CustomTextStyle.styledTextWidget.headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: (widthScale * kTextFormFactor) * 14,
                      )
                      .copyWith(color: bottomNavColor),
              currentIndex: navbarController.selectIndex.value,
              selectedItemColor: primaryColor,
              unselectedItemColor: bottomNavColor,
              onTap: (index) {
                widget.navigationShell.goBranch(index);
                navbarController.selectIndex.value = index;
                chatController.isSearching.value = false;
              },
              items: [
                if (!isInfluencer)
                  _buildNavItem(
                    icon: exploreIcon,
                    label: 'Explore',
                    isSelected: navbarController.selectIndex.value == 0,
                    isFirst: true,
                  ),
                _buildNavItem(
                  icon: chatIcon,
                  label: 'Chats',
                  isSelected: navbarController.selectIndex.value ==
                      (isInfluencer ? 0 : 1),
                ),
                _buildNavItem(
                  icon: eventIcon,
                  label: 'Events',
                  isSelected: navbarController.selectIndex.value ==
                      (isInfluencer ? 1 : 2),
                ),
                _buildNavItem(
                  icon: settingIcon,
                  label: 'Settings',
                  isSelected: navbarController.selectIndex.value ==
                      (isInfluencer ? 2 : 3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    bool isFirst = false,
  }) {
    final double iconSize =
        isFirst ? (isSelected ? 0 : 5) : (isSelected ? 8 : 10);

    return BottomNavigationBarItem(
      icon: Container(
        width: 45,
        height: 45,
        padding: EdgeInsets.all(iconSize),
        decoration: isSelected
            ? const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              )
            : null,
        child: ImageIcon(
          AssetImage(icon),
          color: isSelected ? whiteColor : bottomNavColor,
        ),
      ),
      label: label,
    );
  }
}
