import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/src/controller/navbar_cntrollers/navbar_controller.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        if (title == "No Upcoming Events!")
          SvgPicture.asset(
            'assets/svg/cheerful_event_icon.svg',
            height: 70,
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).rotate(
            begin: -0.05,
            end: 0.05,
            duration: 1000.ms,
            curve: Curves.easeInOut,
          ).scale(
            begin: const Offset(0.94, 0.94),
            end: const Offset(1.06, 1.06),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          )
        else if (isChat || isEvent || title == "No Influencer Found" || title == "No Creators Found" || title == "No Creators Found!" || title == "No Friends Found!" || title == "No Favorites Found!")
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
            fontWeight: FontWeight.w900,
            letterSpacing: 0.15,
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
                fontWeight: FontWeight.w900,
                letterSpacing: 0.15,
              ),
            ),
            if (isChat || isEvent)
              GestureDetector(
                onTap: () {
                  try {
                    final exploreController = Get.find<ExploreScreenController>();
                    exploreController.changeCategory('All');
                  } catch (e) {
                    debugPrint("Could not set Explore category to All: $e");
                  }
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
            'To See Their Exciting Updates.',
            style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
              fontFamily: 'AnnieUseYourTelescope',
              color: headingColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.15,
            ),
          ),
        }
      ],
    );
  }
}
