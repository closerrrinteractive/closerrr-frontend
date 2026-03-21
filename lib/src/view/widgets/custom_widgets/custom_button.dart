import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/constant.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.buttonTitle,
      required this.backButtonColor,
      required this.onlyText,
      required this.onPress,
      this.isTextStyle = true,
      this.iconType,
      this.buttonSize,
      this.bordercolor,
      this.padding,
      this.textColor = whiteColor,
      this.width,
      this.height,
      this.borderRadius,
      this.isLoading = false,
      this.loadingColor,
      this.titleStyle,
      this.isExplore = false,
      this.price = '0',
      this.textDirection,
      this.iconColor,
      this.svg,
      this.preffixIcon});

  final String? svg;
  final TextDirection? textDirection;
  final String buttonTitle;
  final Color backButtonColor;
  final Color? textColor;
  final bool isTextStyle;
  final bool onlyText;
  final AssetImage? iconType;
  final Size? buttonSize;
  final VoidCallback onPress;
  final EdgeInsets? padding;
  final BorderSide? bordercolor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final Color? loadingColor;
  final TextStyle? titleStyle;
  final bool isExplore;
  final String price;
  final Color? iconColor;
  final Widget? preffixIcon;

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: padding,
          side: bordercolor,
          elevation: bordercolor?.color == primaryColor ? 0 : 4,
          shadowColor: bordercolor?.color == primaryColor
              ? null
              : primaryColor.withAlpha(100),
          backgroundColor: backButtonColor,
          minimumSize: buttonSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 6.sp),
          ),
        ),
        onPressed: onPress,
        child: _buildChild(widthScale),
      ),
    );
  }

  Widget _buildChild(double widthScale) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: Center(
          child: CircularProgressIndicator(
            color: loadingColor ?? primaryColor,
            strokeWidth: 1,
          ),
        ),
      );
    }

    if (onlyText) {
      return Text(
        buttonTitle,
        style: isTextStyle
            ? titleStyle ??
                CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                  color: textColor,
                  fontSize: (widthScale * kTextFormFactor) * 14,
                  letterSpacing: 2,
                )
            : CustomTextStyle.styledTextWidget.displayMedium,
      );
    }

    if (isExplore) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _exploreText(buttonTitle, widthScale),
          _exploreText(price, widthScale),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: textDirection,
      children: [
        if (preffixIcon != null) preffixIcon!,
        Text(
          buttonTitle,
          style: isTextStyle
              ? titleStyle ??
                  CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                    color: textColor,
                  )
              : CustomTextStyle.styledTextWidget.displayMedium?.copyWith(
                  color: textColor,
                ),
        ),
        SizedBox(width: 3.w),
        if (svg != null)
          SvgPicture.asset(svg!, height: 20)
        else if (iconType != null)
          ImageIcon(iconType, color: iconColor, size: 2.3.h),
      ],
    );
  }

  Widget _exploreText(String text, double widthScale) {
    return Text(
      text,
      style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
        color: textColor,
        fontSize: (widthScale * kTextFormFactor) * 16,
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.onTap,
    this.icon,
    this.svg,
    this.svgSize = 24,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.text,
  });

  final IconData? icon;
  final String? svg;
  final double svgSize;
  final double? height;
  final double? width;
  final Function() onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: borderRadius ?? BorderRadius.circular(24),
          border: Border.all(width: 1, color: borderColor),
        ),
        child: _buildChild(widthScale),
      ),
    );
  }

  Widget _buildChild(double widthScale) {
    if (text != null) {
      return Text(
        text!,
        style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
          color: primaryColor.withOpacity(0.5),
          fontSize: (widthScale * kTextFormFactor) * 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      );
    }

    if (icon != null) {
      return Icon(icon, size: svgSize);
    }

    return SvgPicture.asset(svg ?? 'assets/svg/search.svg', height: svgSize);
  }
}
