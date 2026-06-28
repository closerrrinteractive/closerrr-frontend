import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/authentication/auth_controller.dart';
import '../../../controller/routing/routing_controller.dart';
import '../../../controller/settings_controller/settings_controller.dart';
import '../../../controller/user_information/user_info_controller.dart';
import '../../popup/setting/logut_popup.dart';
import '../../widgets/custom_widgets/custom_search_bar.dart';
import '../../widgets/specific_widgets/custom_setting_tile.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController controller = TextEditingController();
  final SettingScreenController settingScreenController = Get.find();
  final AuthController authController = Get.find();
  final UserInformationController userInfoController = Get.find();

  @override
  Widget build(BuildContext context) {
    Map userData = userInfoController.userData.value;
    final bool isRoleId3 = Helpers.isInfluencer(userData['role_id']);

    final List<void Function()> menuActions = [
      () => {
            RouterController.current.go('/settings/manage_account', extra: {
              'user': userData,
            })
          },
      if (!isRoleId3) () => RouterController.current.goNamed('friends'),
      if (isRoleId3)
        () =>
            RouterController.current.goNamed('manage_showcase_profile', extra: {
              'influencer': userData,
              'influencerId': userData['id'].toString(),
              'isInfluencer': true,
            }),
      if (isRoleId3) () => RouterController.current.goNamed('my_payouts'),
      () => RouterController.current.goNamed('notification_settings'),
      () => RouterController.current.goNamed('preferences'),
      () => RouterController.current.goNamed('faqs_and_about'),
      () => RouterController.current.goNamed('contact_us'),
      () => RouterController.current.goNamed('about'),
      () => showDialog(
            context: context,
            builder: (context) => const LogutPopup(),
          ),
    ];

    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    String profilePic = userData['Profile']?['profile_pic'] ?? '';

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: const CustomSearchBar(
        isEvents: true,
        icon: 'assets/svg/setting_icon.svg',
        title: 'Settings',
        gif: settingsGif,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: profilePic.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: ApiStrings.imageUrl + profilePic,
                        fit: BoxFit.cover,
                        width: 140,
                        height: 140,
                        placeholder: (context, url) => Container(
                          width: 140,
                          height: 140,
                          color: primaryColor.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          person,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          color: primaryColor,
                        ),
                      )
                    : Image.asset(
                        person,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        color: primaryColor,
                      ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${userData['Profile']?['fullname'] ?? userData['Profile']?['username'] ?? 'NA'}'
                        .capitalizeFirst ??
                    'NA',
                style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  fontSize: (widthScale * kTextFormFactor) * 24,
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Hellix',
                ),
              ),
              if (userData['Profile']?['username'] != null || userData['username'] != null) ...[
                Text(
                  '@${userData['Profile']?['username'] ?? userData['username']}',
                  style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                    fontSize: (widthScale * kTextFormFactor) * 16,
                    color: primaryColor.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Hellix',
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuActions.length,
                itemBuilder: (context, index) {
                  // Define visible tabs based on role_id
                  final List<String> visibleTabs = [
                    'Manage Account',
                    if (!isRoleId3) 'My Friends',
                    if (isRoleId3) 'Manage Showcase Profile',
                    if (isRoleId3) 'My Payouts',
                    'Notifications',
                    'Preferences',
                    'FAQs',
                    'Contact Us',
                    'About',
                    'Logout',
                  ];

                  final List<String> visibleIcons = [
                    manageAccount,
                    if (!isRoleId3) friends,
                    if (isRoleId3) manageShowcase,
                    if (isRoleId3) myPayouts,
                    'notificationbell',
                    'controls',
                    faqs,
                    contactUs,
                    about,
                    logout,
                  ];

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == (menuActions.length - 1) ? 24 : 0.0),
                    child: TabTiles(
                      icons: visibleIcons[index],
                      setting: true,
                      name: visibleTabs[index],
                      padding: EdgeInsets.only(
                          top: 2.h), // Changed 'custom' to 'top'
                      onTap: () {
                        if (index >= 0 && index < menuActions.length) {
                          menuActions[index]();
                        }
                      },
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
