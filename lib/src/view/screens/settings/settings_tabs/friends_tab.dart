import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/custom_no_chat.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/api_string.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/img_string.dart';
import '../../../../controller/navbar_cntrollers/navbar_controller.dart';
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
  SettingScreenController controller = SettingScreenController();
  NavbarController navbarController = Get.find();

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  void getFriends() => controller.getFriends();

  @override
  Widget build(BuildContext context) {
    // controller.friends.clear();
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          leading: Container(),
          leadingWidth: 0,
          toolbarHeight: 9.h,
          surfaceTintColor: transparentColor,
          elevation: 12,
          backgroundColor: whiteColor,
          shadowColor: blueBack.withOpacity(0.1),
          title: Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: Row(
              children: [
                InkWell(
                  onTap: () => RouterController.current.pop(),
                  overlayColor: const WidgetStatePropertyAll(transparentColor),
                  child: Image(
                    image: const AssetImage(
                      backIcon,
                    ),
                    height: 5.5.h,
                  ),
                ),
                SizedBox(width: 1.5.w),
                Text(
                  'Friends',
                  style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                    color: primaryColor,
                    fontSize: (widthScale * kTextFormFactor) * 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Circe',
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Obx(() {
          if (controller.friends.value.isEmpty) {
            return CustomNoChat(
              isChat: true,
              title: 'It’s no fun to be alone!',
              subtitle: 'Make Friends Here-',
              navigationShell: widget.navigationShell,
            );
          }
          return ListView.builder(
            itemCount: controller.friends.length <= 5
                ? controller.friends.value.length
                : controller.friends.value.length + 1,
            itemBuilder: (context, index) {
              if (controller.friends.length == index &&
                  controller.friends.length >= 5) {
                return _buildExploreMoreFriends();
              }
              final following = controller.friends[index].following;
              return Container(
                width: 100.w,
                height: 72,
                margin: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: index == 0 ? 24 : 8,
                  // bottom: 8,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: (widthScale * kTextFormFactor) * 23,
                        backgroundImage: NetworkImage(
                          ApiStrings.imageUrl +
                              (following.profile.profilePic ?? ''),
                        ),
                        onBackgroundImageError: (exception, stackTrace) =>
                            const AssetImage(person),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          following.profile.fullname ??
                              following.profile.username,
                          style: CustomTextStyle.styledTextWidget.bodyLarge
                              ?.copyWith(
                            // color: dark,
                            fontSize: (widthScale * kTextFormFactor) * 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Hellix',
                          ),
                        ),
                        SizedBox(height: 1.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/hand_shake.svg',
                              height: 16,
                            ),
                            SizedBox(width: 1.w),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Closerrr For ',
                                    style: CustomTextStyle
                                        .styledTextWidget.labelMedium!
                                        .copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${controller.friends[index].closerrrDays} ',
                                    style: CustomTextStyle
                                        .styledTextWidget.labelMedium!
                                        .copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Days',
                                    style: CustomTextStyle
                                        .styledTextWidget.labelMedium!
                                        .copyWith(
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 12,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.topCenter,
                      child: CustomButton(
                        buttonTitle: 'Remove Friend',
                        height: 24,
                        backButtonColor: primaryColor.withOpacity(0.1),
                        isTextStyle: true,
                        titleStyle: CustomTextStyle.styledTextWidget.labelSmall!
                            .copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: (widthScale * kTextFormFactor) * 10,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        borderRadius: 24,
                        onlyText: true,
                        onPress: () => showDialog(
                          context: context,
                          builder: (context) => RemoveFriends(
                            id: controller.friends[index].followingId,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(
          () => controller.friends.value.length >= 5 ||
                  controller.friends.value.isEmpty
              ? const SizedBox()
              : _buildExploreMoreFriends(),
        ));
  }

  Widget _buildExploreMoreFriends() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Make More Friends Here - ',
                  style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'AnnieUseYourTelescope',
                  ),
                ),
                TextSpan(
                  text: 'Explore',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
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
