import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/constant_string.dart';

class UpcomingEventCard extends StatelessWidget {
  const UpcomingEventCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.byAuthor,
    required this.time,
    required this.onTap,
  });

  final String title;
  final String posterUrl;
  final String byAuthor;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      width: double.maxFinite,
      height: 128,
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                posterUrl.contains('http')
                    ? posterUrl
                    : (ApiStrings.imageUrl + posterUrl),
                width: 112,
                height: 112,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    width: 112,
                    height: 112,
                    child: Image.asset(
                      Constants.eventImage,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                        fontSize: (widthScale * kTextFormFactor) * 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Hellix',
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: CustomTextStyle.styledTextWidget.titleSmall!.copyWith(
                        fontSize: (widthScale * kTextFormFactor) * 15,
                        color: blackColor,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      "By - $byAuthor",
                      style: CustomTextStyle.styledTextWidget.titleLarge!.copyWith(
                        fontSize: (widthScale * kTextFormFactor) * 12,
                        color: headingColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Hellix',
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
