import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/custom_setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../controller/routing/routing_controller.dart';

class CreatorFaq extends StatefulWidget {
  const CreatorFaq({super.key});

  @override
  State<CreatorFaq> createState() => _CreatorFaqState();
}

class _CreatorFaqState extends State<CreatorFaq> {
  SettingScreenController settingScreenController = Get.find();

  @override
  void initState() {
    super.initState();
    settingScreenController.getFaqCategories(audience: "creator");
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
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
                          'Creator FAQs',
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
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text(
                    'FAQs By Category',
                    style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                      color: blueBack,
                      fontSize: (widthScale * kTextFormFactor) * 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Circe',
                    ),
                  ),
                  SizedBox(height: 2.5.h),
                  Text(
                    '''Have Questions About Closerrr? Find Quick Answers To The Most Common Queries About Using the App, Features, Subscriptions, And Much More!''',
                    style:
                        CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                      color: blackColor,
                      fontSize: (widthScale * kTextFormFactor) * 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ...List.generate(
                      settingScreenController.faqCategories.length,
                      (index) => TabTiles(
                            name: settingScreenController
                                .faqCategories[index].name,
                            onTap: () => RouterController.current
                                .pushNamed('faq_account_profile', extra: {
                              'category_id': settingScreenController
                                  .faqCategories[index].id,
                              'title': settingScreenController
                                  .faqCategories[index].name,
                            }),
                            letterSpacing: -0.3,
                            padding: EdgeInsets.only(bottom: 2.h),
                          )),
                  // TabTiles(
                  //   name: 'Account & Profile',
                  //   onTap: () => RouterController.current.pushNamed('faq_account_profile'),
                  //   padding: EdgeInsets.only(bottom: 2.h),
                  // ),
                  // TabTiles(
                  //   name: 'Subscriptions & Payments',
                  //   onTap: () {},
                  //   padding: EdgeInsets.only(bottom: 2.h),
                  // ),
                  // TabTiles(
                  //   name: 'Using The App',
                  //   onTap: () {},
                  //   padding: EdgeInsets.only(bottom: 2.h),
                  // ),
                  // TabTiles(
                  //   name: 'Chats & Closerrr Live',
                  //   onTap: () {},
                  //   padding: EdgeInsets.only(bottom: 2.h),
                  // ),
                  // TabTiles(
                  //   name: 'Miscellaneous',
                  //   onTap: () {},
                  //   padding: EdgeInsets.only(bottom: 2.h),
                  // ),
                  SizedBox(height: 2.h),
                  Text(
                    'About',
                    style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                      color: blueBack,
                      fontSize: (widthScale * kTextFormFactor) * 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Circe',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '''Version 1.0''',
                    style:
                        CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                      color: blackColor,
                      fontSize: (widthScale * kTextFormFactor) * 14,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '''© 2025 Shark Brews International''',
                    style:
                        CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                      color: blackColor,
                      fontSize: (widthScale * kTextFormFactor) * 14,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Open Source Licenses',
                    style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                      color: blueBack,
                      fontSize: (widthScale * kTextFormFactor) * 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Hellix',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              )),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}
