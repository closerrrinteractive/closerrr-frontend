import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomGreenButton extends StatelessWidget {
  const CustomGreenButton(
      {super.key,
      required this.onTap,
      required this.buttonText,
      required this.buttonWidth,
      this.imageIcon,
      required this.isImage,
      this.backButtonColor,
      this.borderRad,
      this.textColor,
      this.vertPad,
      this.textSize});
  final void Function() onTap;
  final String buttonText;
  final Color? textColor;
  final double buttonWidth;
  final String? imageIcon;
  final bool isImage;
  final Color? backButtonColor;
  final double? borderRad;
  final double? vertPad;
  final double? textSize;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: buttonWidth,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backButtonColor ?? buttonColor,
            padding: EdgeInsets.symmetric(
                vertical: vertPad ?? 1.2.h, horizontal: 5.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRad ?? 1.h),
            ),
            side: isImage
                ? BorderSide(width: 1, color: underAgeColor.withOpacity(0.5))
                : null,
            alignment: Alignment.center,
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment:
                isImage ? MainAxisAlignment.start : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isImage
                  ? Image(
                      image: AssetImage(imageIcon!),
                      height: 3.5.h,
                    )
                  : const SizedBox(),
              isImage
                  ? SizedBox(
                      width: 4.w,
                    )
                  : const SizedBox(),
              Text(
                buttonText,
                style: CustomTextStyle.styledTextWidget.labelMedium,
              ),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
