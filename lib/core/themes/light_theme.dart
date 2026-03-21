import 'dart:io';

import 'package:closerrr/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../config/responsive.dart';

class CloserrrTheme {
  static ThemeData lightTheme = ThemeData(
    textTheme: TextTheme(
      // for large large heading
      titleLarge: GoogleFonts.fredoka(
          fontSize: Responsive.isTablet() ? 12.sp : 30.sp,
          fontWeight: FontWeight.w600,
          color: whiteColor),
      // for large medium heading
      titleMedium: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 10.sp : 20.sp,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Platform.isIOS
            ? Responsive.isTablet()
                ? 8.sp
                : 12.sp
            : 14.sp,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      displayLarge: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 10.sp : 19.sp,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Platform.isIOS
            ? Responsive.isTablet()
                ? 8.sp
                : 10.sp
            : 12.sp,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 8.sp : 14.sp,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 6.sp : 8.sp,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 8.sp : 10.sp,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 8.sp : 14.sp,
        fontWeight: FontWeight.w400,
        color: blackColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 10.sp : 16.sp,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 9.sp : 13.sp,
        fontWeight: FontWeight.w400,
        color: whiteColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 10.sp : 20.sp,
        fontWeight: FontWeight.w600,
        color: whiteColor,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 9.sp : 14.sp,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Platform.isIOS
            ? Responsive.isTablet()
                ? 6.sp
                : 9.sp
            : 10.sp,
        fontWeight: FontWeight.w400,
        color: blackColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Hellix',
        fontSize: Responsive.isTablet() ? 8.sp : 11.sp,
        fontWeight: FontWeight.w700,
        color: whiteColor,
      ),
    ),
  );
}
