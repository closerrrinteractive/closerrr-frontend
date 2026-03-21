import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/utils/img_string.dart';
import '../../../../../controller/routing/routing_controller.dart';

class AccountAndProfile extends StatefulWidget {
  const AccountAndProfile(
      {super.key, required this.categoryId, required this.title});
  final int categoryId;
  final String title;

  @override
  State<AccountAndProfile> createState() => _AccountAndProfileState();
}

class _AccountAndProfileState extends State<AccountAndProfile> {
  final selectedIndex = 0.obs;
  SettingScreenController settingScreenController = Get.find();

  @override
  void initState() {
    super.initState();
    settingScreenController.getFaq(categoryId: widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        toolbarHeight: 8.h,
        surfaceTintColor: transparentColor,
        elevation: 12,
        backgroundColor: whiteColor,
        shadowColor: blueBack.withOpacity(0.1),
        title: Row(
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
              'FAQ & About',
              style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                color: headingColor,
                fontSize: (widthScale * kTextFormFactor) * 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Circe',
              ),
            ),
          ],
        ),
      ),
      body: Obx(() => Padding(
            padding: const EdgeInsets.all(0.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      widget.title,
                      style:
                          CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                        color: blueBack,
                        fontSize: (widthScale * kTextFormFactor) * 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Circe',
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...List.generate(
                    settingScreenController.faqs.length,
                    (index) => Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ExpansionTile(
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          childrenPadding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          onExpansionChanged: (value) {
                            if (value) {
                              selectedIndex.value = index;
                            } else {
                              selectedIndex.value = -1;
                            }
                          },
                          trailing: Icon(
                            selectedIndex.value == index
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 26,
                            color: selectedIndex.value == index
                                ? primaryColor
                                : primaryColor.withOpacity(0.2),
                          ),
                          title: Text(
                            settingScreenController.faqs[index].question,
                            style: CustomTextStyle.styledTextWidget.bodyLarge
                                ?.copyWith(
                              color: headingColor,
                              fontSize: (widthScale * kTextFormFactor) * 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Hellix',
                            ),
                          ),
                          backgroundColor:
                              expansionBackgroundColor.withOpacity(0.4),
                          shape: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          children: [
                            Text(
                              settingScreenController.faqs[index].answer,
                              style: CustomTextStyle.styledTextWidget.bodyMedium
                                  ?.copyWith(
                                color: blackColor,
                                fontSize: (widthScale * kTextFormFactor) * 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Hellix',
                              ),
                            ),
                            SizedBox(height: 2.h)
                          ],
                        ),
                        Container(
                          width: 88.w,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0xFFF0F0F8),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Still Stuck? ',
                        style: CustomTextStyle.styledTextWidget.bodyLarge
                            ?.copyWith(
                          color: blueBack,
                          fontSize: (widthScale * kTextFormFactor) * 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hellix',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => RouterController.current
                            .goNamed('faq_contact_us', extra: {}),
                        child: Text(
                          "We're Just A Mail Away!",
                          style: CustomTextStyle.styledTextWidget.bodyLarge
                              ?.copyWith(
                            color: blueBack,
                            height: 1,
                            fontSize: (widthScale * kTextFormFactor) * 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Hellix',
                            decoration: TextDecoration.underline,
                            decorationColor: blueBack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
