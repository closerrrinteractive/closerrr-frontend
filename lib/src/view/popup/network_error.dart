import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/colors.dart';
import '../../../core/themes/text_style.dart';

class NetworkError extends StatelessWidget {
  const NetworkError({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparentColor,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 100.w,
            padding: const EdgeInsets.all(24),
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: popColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 2.h),
                Text(
                  'Sorry!',
                  style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SizedBox(height: 0.5.h),
                Text(
                  'Network Error!',
                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                    color: failed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.8.h),
                SizedBox(
                  width: 70.w,
                  child: Text(
                    'The Story Could Not Be Downloaded. Please Check Your Internet Connection And Try Again.',
                    textAlign: TextAlign.center,
                    style:
                        CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                      color: headingColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/main-closer.png',
            height: 80,
          )
        ],
      ),
    );
  }
}
