import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/constant.dart';

class EventsGroup extends StatelessWidget {
  const EventsGroup({
    super.key,
    required this.title,
    this.showViewAll,
    required this.leadingIcon,
    required this.child,
    this.onTapShowAll,
  });

  final String title;
  final bool? showViewAll;
  final VoidCallback? onTapShowAll;
  final Widget leadingIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 1.w),
              leadingIcon,
              SizedBox(width: 0.5.h),
              Text(
                title,
                style: CustomTextStyle.styledTextWidget.titleLarge!.copyWith(
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  color: headingColor,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Circe',
                ),
              ),
              SizedBox(width: 2.w),
              if (showViewAll == true)
                InkWell(
                  onTap: () {
                    if (onTapShowAll != null) {
                      onTapShowAll!();
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: CustomTextStyle.styledTextWidget.bodyLarge!
                            .copyWith(
                          fontSize: (widthScale * kTextFormFactor) * 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'Circe',
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: primaryColor,
                        size: 20,
                      )
                    ],
                  ),
                )
            ],
          ),
          SizedBox(height: 2.h),
          child,
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
