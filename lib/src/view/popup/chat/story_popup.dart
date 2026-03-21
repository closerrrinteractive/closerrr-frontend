import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';
import 'package:closerrr/src/view/popup/event/delete_popup.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_popup_btn.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/api_string.dart';

class StoryPopup extends StatefulWidget {
  final bool? isMessageSent;
  final bool? isDownloading;
  final String? media;
  final int storyId;
  final int chatId;

  const StoryPopup({
    super.key,
    this.isMessageSent,
    this.isDownloading,
    this.media,
    required this.chatId,
    required this.storyId,
  });

  @override
  State<StoryPopup> createState() => _StoryPopupState();
}

class _StoryPopupState extends State<StoryPopup> {
  final isReporting = false.obs;
  final reporteded = false.obs;
  final isAlready = false.obs;
  final typedTextLength = 0.obs;
  final reportText = TextEditingController();

  final textReporting = false.obs;

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
      content: Obx(
        () => isReporting.value
            ? _buildReporting()
            : chatController.isDownloading.value ||
                    chatController.isDownloaded.value
                ? _buildDownloading()
                : widget.isMessageSent ?? false
                    ? _buildMessageSent()
                    : _buildActions(),
      ),
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
                PopupCustomBtn(
                  isReporting: false,
                  isCenterTitle: true,
                  title: 'Reported Successfully!',
                  ontap: () => Get.back(),
                ),
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
                      id: widget.storyId,
                      text: reportText.text,
                      type: 'story',
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
      id: widget.storyId,
      text: text,
      type: 'story',
    )
        .then((value) {
      if (!value) {
        isAlready.value = true;
      }
      chatController.loading.value = false;
      reporteded.value = true;
    });
  }

  _buildDownloading() => Obx(() => SizedBox(
        height: chatController.isDownloaded.value ? 26.h : 22.h,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (chatController.isDownloaded.value) ...{
              Container(
                width: 100.w,
                padding: const EdgeInsets.all(24),
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: popColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/message_sent_icon.svg',
                      height: 76,
                    ),
                    SizedBox(height: 2.h),
                    PopupCustomBtn(
                      title: 'Download Complete',
                      isCenterTitle: true,
                      ontap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              )
            } else ...{
              ValueListenableBuilder(
                valueListenable: chatController.progressNotifier,
                builder: (context, value, child) {
                  return Container(
                    width: 100.w,
                    padding: const EdgeInsets.all(24),
                    margin: EdgeInsets.only(top: 5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: popColor,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 2.h),
                        Text(
                          'Downloading...',
                          style: CustomTextStyle.styledTextWidget.titleMedium
                              ?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        LinearProgressIndicator(
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(12),
                          value: value,
                          backgroundColor: headingColor.withOpacity(0.1),
                          color: headingColor,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '${(value * 100).floor()}%',
                          style: CustomTextStyle.styledTextWidget.labelMedium
                              ?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Image.asset(
                'assets/images/main-closer.png',
                height: 80,
              ),
            }
          ],
        ),
      ));

  Container _buildActions() => Container(
        width: 100.w,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: popColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions',
              style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            PopupCustomBtn(
              isActions: true,
              title: 'Download Story',
              ontap: () async {
                if (widget.media == null) return;
                chatController.isDownloading.value = true;
                await chatController.downloadMedia(
                  mediaUrl: ApiStrings.imageUrl + widget.media!,
                );
              },
              icon: Icons.file_download_rounded,
            ),
            if (userInformationController.isInfluencer.value) ...[
              SizedBox(height: 1.h),
              PopupCustomBtn(
                isActions: true,
                title: 'Delete Story',
                ontap: () async {
                  Get.back();
                  showDialog(
                      context: context,
                      builder: (ctx) => DeletePopup(
                            title: 'Story',
                            delete: () async {
                              await chatController
                                  .deleteStory(
                                storyId: widget.storyId,
                                chatId: widget.chatId,
                              )
                                  .then((value) {
                                if (value) {
                                  Get.back();
                                  if (chatController
                                      .storyData.value.first.stories.isEmpty) {
                                    Get.find<RouterController>().router.pop();
                                  } else {
                                    chatController.storyData.value.first.stories
                                        .removeWhere(
                                      (element) {
                                        return element.id == widget.storyId;
                                      },
                                    );
                                    chatController.storyIndex.value -= 1;

                                    chatController.storyData.refresh();
                                  }
                                }
                              });
                            },
                          ));
                },
                isChat: true,
                svg: trashIcons,
              )
            ],
            if (!userInformationController.isInfluencer.value) ...[
              SizedBox(height: 1.h),
              PopupCustomBtn(
                isActions: true,
                title: 'Report Story',
                ontap: () {
                  isReporting.value = true;
                },
                icon: Icons.report,
              ),
            ]
          ],
        ),
      );

  Container _buildMessageSent() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: popColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/message_sent_icon.svg',
            height: 76,
          ),
          SizedBox(height: 2.h),
          PopupCustomBtn(
            title: 'Message Sent',
            ontap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
