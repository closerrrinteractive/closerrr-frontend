import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/custom_no_chat.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/api_string.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/img_string.dart';
import '../../../../controller/navbar_cntrollers/navbar_controller.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../controller/routing/routing_controller.dart';
import '../../../../controller/settings_controller/settings_controller.dart';
import '../../../popup/setting/remove_friend.dart';
import '../../../widgets/custom_widgets/custom_button.dart';

class FriendTab extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const FriendTab({super.key, required this.navigationShell});

  @override
  State<FriendTab> createState() => _FriendTabState();
}

class _FriendTabState extends State<FriendTab> {
  final SettingScreenController controller = Get.find<SettingScreenController>();
  final NavbarController navbarController = Get.find();

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  void getFriends() {
    controller.friends.clear();
    controller.getFriends();
  }

  @override
  Widget build(BuildContext context) {
    // controller.friends.clear();
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
        backgroundColor: backScreenColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blueBack.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticHelper.trigger(type: HapticFeedbackType.light);
                        RouterController.current.pop();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withOpacity(0.08),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              backSvgIcon,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'My Friends',
                            style: TextStyle(
                              fontFamily: 'Hellix',
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: (widthScale * kTextFormFactor) * 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.friends.value.isEmpty) {
                    return CustomNoChat(
                      isChat: true,
                      title: 'It’s no fun to be alone!',
                      subtitle: 'Make Friends Here- ',
                      navigationShell: widget.navigationShell,
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.friends.value.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.friends.value.length) {
                        return _buildExploreMoreFriends();
                      }
                      final following = controller.friends[index].following;
                      final profile = following.profile;
                      return Container(
                        margin: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: index == 0 ? 24 : 12,
                          bottom: index == controller.friends.value.length - 1 ? 12 : 0,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(16.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              offset: const Offset(0, 8),
                              blurRadius: 24,
                              spreadRadius: -2,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: ApiStrings.imageUrl + (profile.profilePic ?? ''),
                                height: 6.h,
                                width: 6.h,
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) => Image(
                                  image: const AssetImage(person),
                                  height: 6.h,
                                  width: 6.h,
                                ),
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                    strokeWidth: 1,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (profile.fullname?.isNotEmpty == true
                                            ? profile.fullname
                                            : profile.username) ??
                                        '',
                                    overflow: TextOverflow.ellipsis,
                                    style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                                      color: mainTextColor,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                      fontSize: (widthScale * kTextFormFactor) * 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.username != null ? '@${profile.username}' : '',
                                    style: CustomTextStyle.styledTextWidget.headlineLarge!.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                      fontSize: (widthScale * kTextFormFactor) * 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/hand_shake.svg',
                                      height: 14,
                                    ).animate(
                                      onPlay: (controller) => controller.repeat(reverse: true),
                                    ).scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1.18, 1.18),
                                      duration: 650.ms,
                                      curve: Curves.easeInOut,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${controller.friends[index].closerrrDays} Days',
                                      style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: (widthScale * kTextFormFactor) * 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (context) => RemoveFriends(
                                      id: controller.friends[index].followingId,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 3.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.sp),
                                      color: primaryColor.withOpacity(0.1),
                                    ),
                                    child: Text(
                                      "REMOVE FRIEND",
                                      style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: (widthScale * kTextFormFactor) * 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildExploreMoreFriends() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Make More Friends Here- ',
                  style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'AnnieUseYourTelescope',
                    letterSpacing: 0.15,
                  ),
                ),
                TextSpan(
                  text: 'Explore',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      try {
                        final exploreController = Get.find<ExploreScreenController>();
                        exploreController.changeCategory('All');
                      } catch (e) {
                        debugPrint("Could not set Explore category to All: $e");
                      }
                      navbarController.selectIndex.value = 0;
                      widget.navigationShell.goBranch(0);
                    },
                  style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                    color: blueBack,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
