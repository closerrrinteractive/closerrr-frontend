import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/custom_setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final UserInformationController userInfoController = Get.find();
    final Map userData = userInfoController.userData.value;
    final bool isRoleId3 = Helpers.isInfluencer(userData['role_id']);

    final TextStyle titleStyle = CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
      color: blueBack,
      fontSize: (widthScale * kTextFormFactor) * 24,
      fontWeight: FontWeight.w800,
      fontFamily: 'Hellix',
    );

    final TextStyle bodyStyle = CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
      fontFamily: 'Hellix',
      color: blackColor,
      fontSize: (widthScale * kTextFormFactor) * 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    final TextStyle bodyStyleThin = CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
      fontFamily: 'Hellix',
      color: blackColor,
      fontSize: (widthScale * kTextFormFactor) * 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
    );

    final TextStyle linkStyle = CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
      fontFamily: 'Hellix',
      color: blueBack,
      fontSize: (widthScale * kTextFormFactor) * 15,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      height: 1.4,
    );

    return Scaffold(
      backgroundColor: whiteColor,
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
                          'About',
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabTiles(
                          icons: termAndConditions,
                          setting: true,
                          name: 'Terms & Conditions',
                          padding: EdgeInsets.only(top: 2.h),
                          onTap: () => isRoleId3
                              ? Helpers.openLink(ApiStrings.creatorTermsCondtions)
                              : Helpers.openLink(ApiStrings.fanTermsCondtions),
                        ),
                        TabTiles(
                          icons: privacyPolicy,
                          setting: true,
                          name: 'Privacy Policy',
                          padding: EdgeInsets.only(top: 2.h),
                          onTap: () => isRoleId3
                              ? Helpers.openLink(ApiStrings.creatorPrivacyPolicy)
                              : Helpers.openLink(ApiStrings.fanPrivacyPolicy),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'About',
                          style: titleStyle,
                        ),
                        SizedBox(height: 2.5.h),
                        Text(
                          'Version 1.0',
                          style: bodyStyle,
                        ),
                        SizedBox(height: 2.5.h),
                        Text(
                          '© 2026 Closerrr Interactive Pvt. Ltd.',
                          style: bodyStyle,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Managed by Shark Brews International',
                          style: bodyStyleThin,
                        ),
                        SizedBox(height: 2.5.h),
                        Text(
                          'Open Source Licenses',
                          style: linkStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
