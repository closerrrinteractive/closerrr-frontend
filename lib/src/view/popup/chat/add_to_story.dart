import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/utils/constant.dart';
import '../../widgets/custom_widgets/custom_popup_btn.dart';

class AddStoryPopup extends StatelessWidget {
  final BuildContext ctx;
  const AddStoryPopup({
    super.key,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    // final userInfo = Get.find<UserInformationController>();
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Container(
        width: 100.w,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: popColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Options',
                style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: (widthScale * kTextFormFactor) * 20,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            PopupCustomBtn(
              isActions: true,
              title: 'Download Story',
              svg: downloadIcon,
              isChat: true,
              ontap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
            PopupCustomBtn(
              isActions: true,
              title: 'Add New Story',
              svg: addStoryIcon,
              isChat: true,
              ontap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
            PopupCustomBtn(
              isActions: true,
              title: 'Delete Story',
              svg: trashIcons,
              isChat: true,
              ontap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
