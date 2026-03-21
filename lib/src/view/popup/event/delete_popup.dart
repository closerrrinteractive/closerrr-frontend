// ignore_for_file: must_be_immutable

import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../../controller/authentication/auth_controller.dart';

class DeletePopup extends StatefulWidget {
  const DeletePopup({
    super.key,
    required this.delete,
    this.title = 'Event',
  });
  final String title;

  final Function() delete;
  @override
  State<DeletePopup> createState() => _DeletePopupState();
}

class _DeletePopupState extends State<DeletePopup> {
  AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Dialog(
      backgroundColor: transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(width: 100.w, height: 216),
            Container(
              width: 100.w,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: popColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    'Are You Sure You Want\nDelete This ${widget.title}?',
                    textAlign: TextAlign.center,
                    style:
                        CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: (widthScale * kTextFormFactor) * 18,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        buttonTitle: 'CANCEL',
                        backButtonColor: popColor,
                        isTextStyle: true,
                        onlyText: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        onPress: () {
                          // authController.logout();
                          Get.back();
                        },
                        bordercolor: const BorderSide(color: primaryColor),
                        titleStyle: CustomTextStyle.styledTextWidget.titleSmall
                            ?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          fontSize: (widthScale * kTextFormFactor) * 14,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF752277).withOpacity(0.25),
                              offset: const Offset(0, 4),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: CustomButton(
                          buttonTitle: 'DELETE',
                          backButtonColor: failed,
                          isTextStyle: true,
                          onlyText: true,
                          onPress: widget.delete,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                          titleStyle: CustomTextStyle
                              .styledTextWidget.titleSmall
                              ?.copyWith(
                            color: whiteColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            fontSize: (widthScale * kTextFormFactor) * 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              child: SizedBox(
                height: 72,
                child: Image.asset(mainLogo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
