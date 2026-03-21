import 'package:closerrr/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomToggleButton extends StatelessWidget {
  const CustomToggleButton(
      {super.key, required this.onToggle, required this.isToggle});
  final VoidCallback onToggle;
  final bool isToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.all(0.5.sp),
        width: 10.w,
        height: 3.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: (isToggle) ? blueBack : underAgeColor,
        ),
        child: Row(
          mainAxisAlignment:
              (isToggle) ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: 15.sp,
              height: 15.sp,
              margin: const EdgeInsets.all(2.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
