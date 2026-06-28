import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../widgets/custom_widgets/custom_button.dart';

class CongratsExplore extends StatelessWidget {
  const CongratsExplore({super.key});

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Dialog(
      backgroundColor: transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(width: 100.w, height: 30.h),
          Container(
            width: 100.w,
            height: 27.h,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: popColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 1.h),
                Text(
                  'Congratulations!',
                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: (widthScale * kTextFormFactor) * 19,
                  ),
                ),
                Text(
                  'Payment Successful.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                    color: buttonColor,
                    fontWeight: FontWeight.w600,
                    fontSize: (widthScale * kTextFormFactor) * 14,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Now Enjoy One-On-One Chat With Your Favorite Artist, Privately And Securely.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w600,
                    fontSize: (widthScale * kTextFormFactor) * 12,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6F7EC9).withOpacity(0.25),
                      blurRadius: 13.88,
                      offset: const Offset(0, 4),
                    ),
                  ]),
                  child: CustomButton(
                    buttonTitle: 'CHAT NOW',
                    buttonSize: Size(30.w, 48),
                    titleStyle:
                        CustomTextStyle.styledTextWidget.titleSmall!.copyWith(
                      color: whiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: (widthScale * kTextFormFactor) * 14,
                    ),
                    backButtonColor: primaryColor,
                    isTextStyle: true,
                    onlyText: true,
                    onPress: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 62,
              child: Image.asset(mainLogo),
            ),
          ),
        ],
      ),
    );
  }
}
