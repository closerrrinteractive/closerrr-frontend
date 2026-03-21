import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/src/controller/navbar_cntrollers/navbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/text_style.dart';

class CustomNoChat extends StatelessWidget {
  const CustomNoChat({
    super.key,
    this.isChat = false,
    this.isEvent = false,
    required this.title,
    required this.subtitle,
    required this.navigationShell,
  });

  final bool isChat;
  final bool isEvent;
  final String title;
  final String subtitle;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    NavbarController navbarController = Get.find();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isChat || isEvent || title == "No Influencer Found")
          Image.asset(
            'assets/images/no_chat_icon.png',
            height: 70,
          ),
        SizedBox(height: 1.h),
        Text(
          title,
          style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
            fontFamily: 'AnnieUseYourTelescope',
            color: headingColor,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subtitle,
              style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
                fontFamily: 'AnnieUseYourTelescope',
                color: headingColor,
              ),
            ),
            if (isChat || isEvent)
              GestureDetector(
                onTap: () {
                  navbarController.selectIndex.value = 0;
                  navigationShell.goBranch(0);
                },
                child: Text(
                  'Explore',
                  style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
                    color: blueBack,
                    decoration: TextDecoration.underline,
                    height: 1.4,
                    decorationColor: blueBack,
                  ),
                ),
              ),
          ],
        ),
        if (isEvent) ...{
          SizedBox(height: 0.5.h),
          Text(
            'To see Exciting Updates.',
            style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
              fontFamily: 'AnnieUseYourTelescope',
              color: headingColor,
            ),
          ),
        }
      ],
    );
  }
}
