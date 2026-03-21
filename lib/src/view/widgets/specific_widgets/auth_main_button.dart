import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AuthMainButton extends StatelessWidget {
  const AuthMainButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    required this.buttonColor,
  });
  final void Function() onTap;
  final String buttonText;
  final Color buttonColor;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 90.w,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.5.h),
            ),
            side: BorderSide(width: 1, color: underAgeColor.withOpacity(0.5)),
            alignment: Alignment.center,
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(),
              Text(
                buttonText,
                style: CustomTextStyle.styledTextWidget.displayLarge
                    ?.copyWith(fontSize: 15.sp, color: whiteColor),
              ),
              Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                padding: EdgeInsets.all(5.sp),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: buttonColor,
                  size: 3.h,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
