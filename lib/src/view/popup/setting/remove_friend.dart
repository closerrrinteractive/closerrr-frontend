// ignore_for_file: must_be_immutable

import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/settings_controller/settings_controller.dart';

class RemoveFriends extends StatefulWidget {
  final int id;
  const RemoveFriends({super.key, required this.id});

  @override
  State<RemoveFriends> createState() => _RemoveFriendsState();
}

class _RemoveFriendsState extends State<RemoveFriends> {
  SettingScreenController controller = Get.find();
  final TextEditingController _confirmController = TextEditingController();
  bool _showSecondPrompt = false;
  bool _isGoodbyeEntered = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      final text = _confirmController.text.trim();
      final isGoodbye = text == 'GOODBYE';
      if (_isGoodbyeEntered != isGoodbye) {
        setState(() {
          _isGoodbyeEntered = isGoodbye;
        });
      }
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 100.w,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Container(
                width: 100.w,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: popColor,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 2.5.h),
                      if (!_showSecondPrompt) ...[
                        Center(
                          child: Text(
                            'It’s No Fun Without Friends!',
                            textAlign: TextAlign.center,
                            style:
                                CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: (widthScale * kTextFormFactor) * 19,
                            ),
                          ),
                        ),
                        Text(
                          '''By Removing The Friend, You Will No Longer Be Able To Send Or Receive Messages From Them, And Your Closerrr Streak Will Be Broken As Well.''',
                          textAlign: TextAlign.center,
                          style:
                              CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                            color: headingColor,
                            fontWeight: FontWeight.w600,
                            fontSize: (widthScale * kTextFormFactor) * 12,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          '''Are You Sure You Don’t Want\nTo Be Friends Anymore?''',
                          textAlign: TextAlign.center,
                          style:
                              CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                            color: logOutColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Hellix',
                            fontSize: (widthScale * kTextFormFactor) * 14,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6F7EC9).withOpacity(0.25),
                              blurRadius: 13.88,
                              offset: const Offset(0, 4),
                            ),
                          ]),
                          child: CustomButton(
                            buttonTitle: 'STAY FRIENDS',
                            backButtonColor: primaryColor,
                            isTextStyle: true,
                            onlyText: true,
                            onPress: () => Navigator.pop(context),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                            titleStyle:
                                CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                              color: whiteColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                              fontSize: (widthScale * kTextFormFactor) * 14,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showSecondPrompt = true;
                            });
                          },
                          child: Text(
                            'Yes, I’m Sure I Want To\nRemove Them As My Friend.',
                            textAlign: TextAlign.center,
                            style:
                                CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: Text(
                            'Some Goodbyes Are Hard!',
                            textAlign: TextAlign.center,
                            style:
                                CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: (widthScale * kTextFormFactor) * 19,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                              color: headingColor,
                              fontWeight: FontWeight.w600,
                              fontSize: (widthScale * kTextFormFactor) * 12,
                            ),
                            children: [
                              const TextSpan(text: "If You're Sure, Type "),
                              TextSpan(
                                text: "GOODBYE",
                                style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                                  color: headingColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (widthScale * kTextFormFactor) * 12,
                                ),
                              ),
                              const TextSpan(text: " to Remove This Friend."),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        CustomTextFormField(
                          hintText: "One Last Confirmation...",
                          controller: _confirmController,
                          fillColor: whiteColor,
                          borderColor: primaryColor.withOpacity(0.5),
                          radius: 12,
                          cursorColor: primaryColor,
                          style: CustomTextStyle.styledTextWidget.displayMedium?.copyWith(
                            color: headingColor,
                            fontSize: (widthScale * kTextFormFactor) * 14,
                          ),
                          hintStyle: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                            color: headingColor.withOpacity(0.4),
                            fontSize: (widthScale * kTextFormFactor) * 12,
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(
                                    color: _isGoodbyeEntered ? primaryColor : primaryColor.withOpacity(0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.sp),
                                  ),
                                  elevation: 0,
                                  backgroundColor: popColor,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  if (_isGoodbyeEntered) {
                                    controller.removeFriend(id: widget.id);
                                  }
                                },
                                child: Text(
                                  'REMOVE',
                                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                                    color: _isGoodbyeEntered ? primaryColor : primaryColor.withOpacity(0.5),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                    fontSize: (widthScale * kTextFormFactor) * 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: primaryColor,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.sp),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'STAY',
                                  style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                    fontSize: (widthScale * kTextFormFactor) * 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
             Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: SizedBox(
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(settingHeartBreakLeft).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ).slideX(
                      begin: 0,
                      end: -0.06,
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ).rotate(
                      begin: 0,
                      end: -0.04,
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ),
                    SvgPicture.asset(settingHeartBreakRight).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ).slideX(
                      begin: 0,
                      end: 0.06,
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ).rotate(
                      begin: 0,
                      end: 0.04,
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
