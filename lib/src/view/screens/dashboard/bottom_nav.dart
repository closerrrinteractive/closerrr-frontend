import 'dart:async';
import 'dart:ui';

import 'package:closerrr/core/services/local_notification_service.dart';
import 'package:closerrr/core/services/notification_service.dart';
import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/services/custom_services.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// import 'package:stream_video_flutter/stream_video_flutter.dart' as getStreamIO;

import 'package:closerrr/core/config/haptic_helper.dart';

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
    try {
      await PushNotificationService().initNotifications();
      String? fcmToken = await PushNotificationService.fcm.getToken();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true);
      if (fcmToken != null) {
        await notificationController.setFcmToken(fcmToken: fcmToken);
      }
    } catch (e) {
      kLog("Error fetching FCM token: $e");
    }
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
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: Obx(
        () {
          final isInfluencer =
              userInformationController.userData["role_id"] == 3;

          final items = [
            if (!isInfluencer)
              _NavItemData(icon: exploreIcon, label: 'Explore', index: 0),
            _NavItemData(
                icon: chatIcon,
                label: 'Chats',
                index: isInfluencer ? 0 : 1),
            _NavItemData(
                icon: eventIcon,
                label: 'Events',
                index: isInfluencer ? 1 : 2),
            _NavItemData(
                icon: settingIcon,
                label: 'Settings',
                index: isInfluencer ? 2 : 3),
          ];

          return SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 12.0,
                left: 16.0,
                right: 16.0,
              ),
              height: 68.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.0),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0x1F1E1E2E)
                        : const Color(0xD9FFFFFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: items.map((item) {
                        final isSelected =
                            navbarController.selectIndex.value == item.index;
                        return _buildCustomTab(item, isSelected);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomTab(_NavItemData item, bool isSelected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticHelper.trigger(type: HapticFeedbackType.selection);
        widget.navigationShell.goBranch(item.index);
        navbarController.selectIndex.value = item.index;
        chatController.isSearching.value = false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20.0 : 15.0,
          vertical: 11.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            item.label == 'Explore'
                ? Transform.scale(
                    scale: 1.7,
                    child: SvgPicture.asset(
                      exploreIconSvg,
                      width: 24.0,
                      height: 24.0,
                      colorFilter: ColorFilter.mode(
                        isSelected ? whiteColor : bottomNavColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : ImageIcon(
                    AssetImage(item.icon),
                    color: isSelected ? whiteColor : bottomNavColor,
                    size: 26.0,
                  ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8.0),
                        Text(
                          item.label,
                          style: CustomTextStyle.styledTextWidget.headlineMedium!.copyWith(
                            color: whiteColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.0.sp,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String icon;
  final String label;
  final int index;

  _NavItemData({
    required this.icon,
    required this.label,
    required this.index,
  });
}
