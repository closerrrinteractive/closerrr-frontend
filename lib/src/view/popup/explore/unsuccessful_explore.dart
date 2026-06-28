import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../widgets/custom_widgets/custom_button.dart';

class UnsuccessfulExplore extends StatelessWidget {
  final VoidCallback onTryAgain;
  final VoidCallback onCancel;

  const UnsuccessfulExplore({
    super.key,
    required this.onTryAgain,
    required this.onCancel,
  });

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: popColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 1.5.h),
                Text(
                  'Sorry!',
                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: (widthScale * kTextFormFactor) * 19,
                  ),
                ),
                Text(
                  'Payment Unsuccessful.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                    color: failed,
                    fontWeight: FontWeight.w600,
                    fontSize: (widthScale * kTextFormFactor) * 14,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "We Couldn't Process Your Payment.\nPlease Try Again.",
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w600,
                    fontSize: (widthScale * kTextFormFactor) * 12,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6F7EC9).withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]),
                        child: CustomButton(
                          buttonTitle: 'TRY AGAIN',
                          height: 48,
                          borderRadius: 8.sp,
                          titleStyle: CustomTextStyle.styledTextWidget.titleSmall!.copyWith(
                            color: whiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: (widthScale * kTextFormFactor) * 12.5,
                          ),
                          backButtonColor: primaryColor,
                          isTextStyle: true,
                          onlyText: true,
                          onPress: () {
                            Navigator.of(context).pop();
                            onTryAgain();
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6F7EC9).withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]),
                        child: CustomButton(
                          buttonTitle: 'CANCEL',
                          height: 48,
                          borderRadius: 8.sp,
                          titleStyle: CustomTextStyle.styledTextWidget.titleSmall!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: (widthScale * kTextFormFactor) * 12.5,
                          ),
                          backButtonColor: transparentColor,
                          isTextStyle: true,
                          onlyText: true,
                          onPress: () {
                            Navigator.of(context).pop();
                            onCancel();
                          },
                          bordercolor: const BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
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
