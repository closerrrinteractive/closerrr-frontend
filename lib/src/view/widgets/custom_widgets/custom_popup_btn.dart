import 'package:closerrr/core/config/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';

class PopupCustomBtn extends StatelessWidget {
  final bool? isActions;
  final bool? isChat;
  final bool? isReporting;
  final String title;
  final Function()? ontap;
  final IconData? icon;
  final String? svg;
  final bool? isChatHold;
  final bool? isCenterTitle;
  final bool? isLoading;
  const PopupCustomBtn({
    super.key,
    this.isActions,
    required this.title,
    this.isChat,
    this.isReporting,
    this.ontap,
    this.icon,
    this.svg,
    this.isChatHold,
    this.isCenterTitle,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return ElevatedButton(
      onPressed: ontap,
      style: ButtonStyle(
        backgroundColor:
            headingColor.withOpacity(0.1).asWidgetStatePropertyAll(),
        elevation: 0.0.asWidgetStatePropertyAll(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ).asWidgetStatePropertyAll(),
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 12,
        ).asWidgetStatePropertyAll(),
      ),
      child: Container(
        width: 100.w,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 55.w,
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (isChat ?? false) ...{
                    SvgPicture.asset(
                      svg ?? 'assets/svg/chat_type.svg',
                      height: 16,
                      color: headingColor,
                    ),
                    SizedBox(width: 2.w),
                  },
                  if (isActions ?? false) ...{
                    if (icon != null) ...{
                      Icon(
                        icon ?? Icons.report,
                        color: headingColor,
                      ),
                      SizedBox(width: 2.w),
                    },
                  },
                  Expanded(
                    child: isLoading ?? false
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: primaryColor,
                            ),
                          )
                        : Text(
                            title,
                            maxLines: 1,
                            textAlign:
                                isCenterTitle == true ? TextAlign.center : null,
                            overflow: TextOverflow.ellipsis,
                            style: CustomTextStyle.styledTextWidget.titleSmall
                                ?.copyWith(
                              color: headingColor,
                              fontSize: (widthScale * kTextFormFactor) * 16,
                              height: 1.3,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
