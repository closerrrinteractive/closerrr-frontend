import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BackButtonAndTitleAppBar extends StatelessWidget {
  const BackButtonAndTitleAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF752277).withAlpha(40),
              offset: const Offset(0, 2),
              blurRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: primaryColor.withAlpha(100)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            title,
            style: CustomTextStyle.styledTextWidget.titleLarge!.copyWith(
              fontSize: 14.sp,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
