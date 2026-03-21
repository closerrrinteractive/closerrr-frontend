import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_popup_btn.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';

class ReportPopup extends StatefulWidget {
  final UserProfile user;
  const ReportPopup({
    super.key,
    required this.user,
  });

  @override
  State<ReportPopup> createState() => _ReportPopupState();
}

class _ReportPopupState extends State<ReportPopup> {
  final isReporting = false.obs;
  final reporteded = false.obs;
  final textReporting = false.obs;
  final isAlready = false.obs;
  final typedTextLength = 0.obs;
  final reportText = TextEditingController();

  final chatController = Get.find<ChatController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((value) {
      chatController.isDownloaded.value = false;
      chatController.isDownloading.value = false;
      chatController.isDownloadFailed.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Obx(() => _buildReporting()),
    );
  }

  Container _buildReporting() => Container(
        width: 100.w,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: popColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reporteded.value) ...{
                SvgPicture.asset(
                  'assets/svg/message_sent_icon.svg',
                  height: 64,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Thank You For Helping Us Make Closerrr Safer And Better For Everyone.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.labelSmall?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Obx(() => PopupCustomBtn(
                      isReporting: false,
                      isCenterTitle: true,
                      title:
                          '${isAlready.value ? 'Already' : 'Reported'} Successfully!',
                      ontap: () => Get.back(),
                    )),
              } else if (textReporting.value) ...{
                Text(
                  'Please Tell Us Your Reason For Reporting This Content',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Obx(() => Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CustomTextFormField(
                          hintText: '',
                          controller: reportText,
                          fillColor: headingColor.withOpacity(0.1),
                          borderColor: transparentColor,
                          isMaxLine: 6,
                          textLength: 100,
                          onChanged: (p0) {
                            typedTextLength.value = p0.length;
                          },
                          textFieldPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '$typedTextLength/100',
                            style: CustomTextStyle.styledTextWidget.bodySmall
                                ?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 2.h),
                PopupCustomBtn(
                  isReporting: false,
                  title: 'Submit Report',
                  isCenterTitle: true,
                  isLoading: chatController.loading.value,
                  ontap: () async {
                    chatController.loading.value = true;
                    await chatController
                        .report(
                      id: widget.user.id ?? 0,
                      text: reportText.text,
                      type: 'user',
                    )
                        .then((value) {
                      if (!value) {
                        isAlready.value = true;
                      }
                      chatController.loading.value = false;
                      reporteded.value = true;
                    });
                  },
                ),
              } else ...{
                Text(
                  'Reason For Reporting',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Please Let Us Know What’s Wrong With This Content To Help Us Make This App Safer And Better For Everyone. And Don’t Worry, Your Reports Are Anonymous.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.labelSmall?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Harassment/Bullying',
                  ontap: () => _onReportTap(
                    text: 'Harassment/Bullying',
                  ),
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Is A Scam/Fraud/Spam',
                  ontap: () => _onReportTap(
                    text: 'Is A Scam/Fraud/Spam',
                  ),
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Promotes Violence/Self Harm',
                  ontap: () => _onReportTap(
                    text: 'Promotes Violence/Self Harm',
                  ),
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Promoting Restricted Items',
                  ontap: () => _onReportTap(
                    text: 'Promoting Restricted Items',
                  ),
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Nudity/Sexual Activity',
                  ontap: () => _onReportTap(
                    text: 'Nudity/Sexual Activity',
                  ),
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Impersonating Someone Else',
                  ontap: () => _onReportTap(
                    text: 'Impersonating Someone Else',
                  ),
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Hate Speech',
                  ontap: () => _onReportTap(
                    text: 'Hate Speech',
                  ),
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: true,
                  title: 'Reason Not Listed Here',
                  ontap: () {
                    textReporting.value = true;
                  },
                ),
              }
            ],
          ),
        ),
      );

  _onReportTap({
    required String text,
  }) async {
    chatController.loading.value = true;
    await chatController
        .report(
      id: widget.user.id ?? 0,
      text: text,
      type: 'user',
    )
        .then((value) {
      if (!value) {
        isAlready.value = true;
      }
      chatController.loading.value = false;
      reporteded.value = true;
    });
  }
}
