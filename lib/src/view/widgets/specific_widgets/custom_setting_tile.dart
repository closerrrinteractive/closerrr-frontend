import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool)? onChanged;
  const SettingTile({
    super.key,
    required this.title,
    this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: CustomTextStyle.styledTextWidget.bodySmall!.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'Hellix',
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: whiteColor,
            activeTrackColor: primaryColor,
            inactiveThumbColor: whiteColor,
            // inactiveTrackColor: primary.withOpacity(0.2),
            trackOutlineWidth: const WidgetStatePropertyAll(0),
          )
        ],
      ),
    );
  }
}

class TabTiles extends StatelessWidget {
  const TabTiles({
    super.key,
    this.icons,
    this.name,
    this.onTap,
    this.setting,
    this.notification,
    this.secondary,
    this.isLoading,
    required this.padding,
  });

  final String? icons;
  final String? name;
  final String? secondary;
  final Function()? onTap;
  final bool? setting;
  final bool? isLoading;
  final bool? notification;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            Row(
              children: [
                if (setting ?? false)
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: settingCircle,
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/$icons.svg',
                      color: primaryColor,
                    ),
                  ),
                Expanded(
                  child: Container(
                    padding: setting ?? false
                        ? const EdgeInsets.only(right: 12, top: 12, bottom: 12)
                        : const EdgeInsets.symmetric(vertical: 12),
                    margin: setting ?? false
                        ? const EdgeInsets.only(left: 8)
                        : null,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: setting ?? true ? null : 50.w,
                              child: Text(
                                name ?? '',
                                maxLines: 2,
                                softWrap: true,
                                style: CustomTextStyle
                                    .styledTextWidget.labelLarge
                                    ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: (widthScale * kTextFormFactor) * 18,
                                  fontFamily: 'Hellix',
                                ),
                              ),
                            ),
                            if (notification ?? false)
                              Text(
                                secondary ?? '',
                                style: CustomTextStyle
                                    .styledTextWidget.labelMedium
                                    ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w300,
                                  fontSize: (widthScale * kTextFormFactor) * 12,
                                ),
                              ),
                          ],
                        ),
                        if (isLoading ?? false)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: primaryColor.withOpacity(0.2),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.6.h),
          ],
        ),
      ),
    );
  }
}
