// ignore_for_file: must_be_immutable

import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/settings_controller/settings_controller.dart';

class RemoveFriends extends StatefulWidget {
  final int id;
  const RemoveFriends({super.key, required this.id});

  @override
  State<RemoveFriends> createState() => _RemoveFriendsState();
}

class _RemoveFriendsState extends State<RemoveFriends> {
  SettingScreenController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 100.w,
        height: 49.h,
        padding: const EdgeInsets.all(24),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 100.w,
              height: 41.h,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: popColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 2.5.h),
                  Center(
                    child: Text(
                      'It’s No Fun Without Friends!',
                      textAlign: TextAlign.center,
                      style:
                          CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: (widthScale * kTextFormFactor) * 19,
                      ),
                    ),
                  ),
                  Text(
                    '''By Removing The Friend, You Will No Longer Be Able To Send Or Receive Messages From Them, And Your Closerrr Streak Will Be Broken As Well.''',
                    textAlign: TextAlign.center,
                    style:
                        CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                      color: headingColor,
                      fontWeight: FontWeight.w600,
                      fontSize: (widthScale * kTextFormFactor) * 12,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    '''Are You Sure You Don’t Want\nTo Be Friends Anymore?''',
                    textAlign: TextAlign.center,
                    style:
                        CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                      color: logOutColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Hellix',
                      fontSize: (widthScale * kTextFormFactor) * 14,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6F7EC9).withOpacity(0.25),
                        blurRadius: 13.88,
                        offset: const Offset(0, 4),
                      ),
                    ]),
                    child: CustomButton(
                      buttonTitle: 'STAY FRIENDS',
                      backButtonColor: primaryColor,
                      isTextStyle: true,
                      onlyText: true,
                      onPress: () {},
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      titleStyle:
                          CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                        color: whiteColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        fontSize: (widthScale * kTextFormFactor) * 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  GestureDetector(
                    onTap: () => controller.removeFriend(id: widget.id),
                    child: Text(
                      'Yes, I’m Sure I Want To\nRemove Them As My Friend.',
                      textAlign: TextAlign.center,
                      style:
                          CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: (widthScale * kTextFormFactor) * 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: SizedBox(
                height: 72,
                child: SvgPicture.asset(settingHeartBreak),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
