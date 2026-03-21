import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';

class TermConditionsAndPrivacyPolicy extends StatelessWidget {
  const TermConditionsAndPrivacyPolicy({super.key});

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
          SizedBox(width: 100.w, height: 69.h),
          Container(
            width: 100.w,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: popColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Image(
                        image: const AssetImage(crossIcon),
                        height: 3.5.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Closerrr Terms And Conditions',
                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: (widthScale * kTextFormFactor) * 18,
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: 100.w,
                  child: ListView.builder(
                      itemCount: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Article ${index + 1} (Safe use):',
                              style: CustomTextStyle.styledTextWidget.bodyMedium
                                  ?.copyWith(
                                color: headingColor,
                                fontWeight: FontWeight.w600,
                                fontSize: (widthScale * kTextFormFactor) * 14,
                              ),
                            ),
                            SizedBox(
                              width: 55.w,
                              child: Text(
                                'Chat With Your Artist Safely And Securely',
                                style: CustomTextStyle
                                    .styledTextWidget.bodyMedium
                                    ?.copyWith(
                                  color: blackColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: (widthScale * kTextFormFactor) * 12,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h)
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0.h,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 62,
              child: Image.asset(
                mainLogo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
