import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/constant.dart';

class FriendEventCard extends StatelessWidget {
  const FriendEventCard({
    super.key,
    required this.profileUrl,
    required this.name,
    required this.onTap,
  });
  final String profileUrl;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      width: double.maxFinite,
      height: 72,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(2, 2),
              blurRadius: 2),
          BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(-1, 1),
              blurRadius: 2),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: 1.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(74),
                  child: Image.network(
                    profileUrl,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      person,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  name,
                  style: CustomTextStyle.styledTextWidget.titleLarge!.copyWith(
                    fontSize: (widthScale * kTextFormFactor) * 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: Color(0xFFC1A0DD),
                  size: 20,
                ),
                SizedBox(width: 1.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
