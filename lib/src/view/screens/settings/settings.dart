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
      if (isRoleId3)
        () => RouterController.current.goNamed('notification_settings'),
      if (isRoleId3) () => RouterController.current.goNamed('my_payouts'),
      // if (isRoleId3)
      //   () => RouterController.current.goNamed('dashboard_and_analytics'),
      () => RouterController.current.goNamed('faqs_and_about'),
      () => isRoleId3
          ? Helpers.openLink(ApiStrings.creatorTermsCondtions)
          : Helpers.openLink(ApiStrings.fanTermsCondtions),
      () => isRoleId3
          ? Helpers.openLink(ApiStrings.creatorPrivacyPolicy)
          : Helpers.openLink(ApiStrings.fanPrivacyPolicy),
      () => RouterController.current.goNamed('contact_us'),
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
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: ApiStrings.imageUrl + profilePic,
                  fit: BoxFit.cover,
                  width: 140,
                  height: 140,
                  errorWidget: (context, url, error) {
                    return Image.asset(person);
                  },
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
                  fontFamily: 'Hellix',
                ),
              ),
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
                    if (isRoleId3) 'Notification Settings',
                    if (isRoleId3) 'My Payouts',
                    'FAQs & About',
                    'Terms & Conditions',
                    'Privacy Policy',
                    'Contact Us',
                    'Logout',
                  ];

                  final List<String> visibleIcons = [
                    manageAccount,
                    if (!isRoleId3) friends,
                    if (isRoleId3) manageShowcase,
                    if (isRoleId3) notificationSettings,
                    if (isRoleId3) myPayouts,
                    faqAbout,
                    termAndConditions,
                    privacyPolicy,
                    contactUs,
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
