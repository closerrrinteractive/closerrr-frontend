import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextStyle? hintStyle;
  final int? textLength;
  final InputBorder? isBorder;
  final IconData? suffixIcon;
  final String? prefixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function()? onTapSuffix;
  final EdgeInsetsGeometry? textFieldPadding;
  final Widget? containerWidget;
  final void Function(String)? onChanged;
  bool? backFilled = false;
  bool? fieldReadOnly;
  int? isMaxLine = 1;
  int? isMinLine = 1;
  VoidCallback? onTap;
  Color? fillColor;
  Color? borderColor;
  Color? cursorColor;
  Color? suffixColor;
  double? radius;
  TextStyle? style;
  final String? svg;
  FocusNode? focusNode;
  String? suffixSvg;
  double? suffixSvgHeight;

  CustomTextFormField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onTapSuffix,
    this.prefixIcon,
    this.textFieldPadding,
    this.onChanged,
    this.isBorder,
    this.backFilled = true,
    this.isMaxLine,
    this.isMinLine,
    this.fieldReadOnly,
    this.onTap,
    this.textLength,
    this.containerWidget,
    this.fillColor,
    this.borderColor,
    this.radius,
    this.hintStyle,
    this.cursorColor,
    this.style,
    this.svg,
    this.suffixColor,
    this.focusNode,
    this.suffixSvg,
    this.suffixSvgHeight,
  });

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final textLengthObs = 0.obs;

    controller.addListener(() {
      textLengthObs.value = controller.text.length;
    });

    return TextFormField(
      onTap: onTap,
      focusNode: focusNode,
      maxLength: textLength,
      minLines: isMinLine,
      maxLines: isMaxLine,
      controller: controller,
      obscureText: obscureText,
      cursorColor: cursorColor,
      cursorHeight: 18,
      style: style ??
          CustomTextStyle.styledTextWidget.displayMedium?.copyWith(
            color: headingColor,
            overflow: TextOverflow.ellipsis,
            height: 2,
          ),
      validator: validator,
      keyboardType: keyboardType,
      readOnly: fieldReadOnly ?? false,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: textFieldPadding ?? EdgeInsets.all(1.5.h),
        hintText: hintText,
        filled: backFilled,
        fillColor: fillColor ?? whiteColor,
        errorStyle: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
          color: logOutColor,
          fontSize: (widthScale * kTextFormFactor) * 12,
        ),
        hintStyle: hintStyle ??
            CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              color: headingColor.withOpacity(0.6),
              fontSize: 12.sp,
            ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 10.0),
          borderSide: BorderSide(
            color: borderColor ?? headingColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 10.0),
          borderSide: BorderSide(
            color: borderColor ?? headingColor,
            width: 1,
          ),
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: EdgeInsets.only(
                  left: 4.w,
                  right: 3.w,
                  top: 4.w,
                  bottom: 4.w,
                ),
                child: Image.asset(
                  prefixIcon ?? '',
                  height: 10,
                ),
              )
            : svg != null
                ? Padding(
                    padding: EdgeInsets.only(
                        left: 4.w, right: 3.w, top: 3.w, bottom: 3.w),
                    child: SvgPicture.asset(
                      svg ?? '',
                      height: 24,
                    ),
                  )
                : null,
        suffixIcon: suffixSvg != null
            ? GestureDetector(
                onTap: onTapSuffix,
                child: Padding(
                  padding: suffixSvgHeight != null
                      ? EdgeInsets.only(
                          top: 3.w,
                          bottom: 3.w,
                          right: 4.w,
                          left: 5.w,
                        )
                      : EdgeInsets.all(3.w),
                  child: SvgPicture.asset(
                    suffixSvg ?? '',
                    height: suffixSvgHeight ?? 26,
                    color: primaryColor,
                  ),
                ),
              )
            : suffixIcon != null
                ? IconButton(
                    onPressed: onTapSuffix,
                    icon: Icon(
                      suffixIcon,
                      size: 2.5.h,
                      color: suffixColor ?? headingColor,
                    ))
                : containerWidget,
        border: isBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor ?? headingColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10.sp),
            ),
        counterText: "",
      ),
    );
  }
}
