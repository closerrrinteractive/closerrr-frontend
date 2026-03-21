// ignore_for_file: must_be_immutable

import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../../controller/settings_controller/settings_controller.dart';

class DeleteAccount extends StatefulWidget {
  final int id;
  const DeleteAccount({super.key, required this.id});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  SettingScreenController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(width: 100.w, height: 370),
          Container(
            width: 100.w,
            height: 43.h,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: popColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 2.5.h),
                Center(
                  child: Text(
                    'Every Goodbye Is Tough!',
                    style:
                        CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: (widthScale * kTextFormFactor) * 19,
                    ),
                  ),
                ),
                Text(
                  '''Deleting Your Account Means Losing\nAll Your Chats, Streaks, And Most Importantly, The Precious Memories Shared With Your Friends. Once Gone, They Can Never Be Recovered Again.''',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w600,
                    fontSize: (widthScale * kTextFormFactor) * 12,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  '''Are You Sure You Want To Delete Your Account Permanently?''',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                    color: logOutColor,
                    fontWeight: FontWeight.w600,
                    fontSize: (widthScale * kTextFormFactor) * 14,
                  ),
                ),
                SizedBox(height: 1.5.h),
                CustomButton(
                  buttonTitle: 'STAY CLOSERRR',
                  backButtonColor: primaryColor,
                  isTextStyle: true,
                  onlyText: true,
                  onPress: () => context.pop(),
                  // height: 40,
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
                SizedBox(height: 1.5.h),
                GestureDetector(
                  onTap: () => controller.deleteAccount(id: widget.id),
                  child: Text(
                    '''Yes, I’m Sure I Want To\nDelete My Account Permanently.''',
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
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 72,
              child: SvgPicture.asset(settingHeartBreak),
            ),
          ),
        ],
      ),
    );
  }
}
