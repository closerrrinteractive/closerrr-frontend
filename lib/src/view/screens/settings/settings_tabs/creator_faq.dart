import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/custom_setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
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
    settingScreenController.getFaqCategories();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        toolbarHeight: 8.h,
        surfaceTintColor: transparentColor,
        elevation: 12,
        backgroundColor: whiteColor,
        shadowColor: blueBack.withOpacity(0.1),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            SizedBox(width: 1.w),
            Text(
              'Creator FAQs',
              style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                color: primaryColor,
                fontSize: (widthScale * kTextFormFactor) * 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Circe',
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => RouterController.current.pop(),
              child: Image(
                image: const AssetImage(
                  searchIcon,
                ),
                height: 5.5.h,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
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
    );
  }
}
