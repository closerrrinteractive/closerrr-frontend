import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/view/popup/event/delete_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../../controller/user_information/user_info_controller.dart';
import '../../widgets/custom_widgets/custom_popup_btn.dart';
import '../../widgets/custom_widgets/custom_text_formfield.dart';

class ChatMessageAction extends StatefulWidget {
  const ChatMessageAction({
    super.key,
    required this.messageId,
    required this.createdAt,
    required this.replyTo,
    this.senderId,
    required this.onTapCopyMessage,
    required this.onMessageDelete,
  });

  final int messageId;
  final DateTime createdAt;
  final String? senderId;
  final VoidCallback replyTo;
  final VoidCallback onTapCopyMessage;
  final VoidCallback onMessageDelete;

  @override
  State<ChatMessageAction> createState() => _ChatMessageActionState();
}

class _ChatMessageActionState extends State<ChatMessageAction> {
  final ChatController chatController = Get.find();
  final UserInformationController uiController = Get.find();
  final reportMessageTextController = TextEditingController();

  final isReporting = false.obs;
  final isAddedToMemoriesDone = false.obs;

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Container(
        width: 100.w,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: popColor,
        ),
        child: Obx(() => isReporting.value
            ? _buildReporting()
            : isAddedToMemoriesDone.value
                ? _buildAddedToMemories()
                : _buildActions(context, widthScale)),
      ),
    );
  }

  Widget _buildActions(BuildContext context, double widthScale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            'Actions',
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
          title: 'Reply',
          icon: Icons.reply_all_rounded,
          ontap: () {
            Get.back();
            widget.replyTo();
          },
        ),
        SizedBox(height: 1.h),
        PopupCustomBtn(
          isActions: true,
          title: 'Copy Message',
          icon: Icons.copy_rounded,
          ontap: () {
            widget.onTapCopyMessage();
            Get.back();
          },
        ),
        SizedBox(height: 1.h),
        PopupCustomBtn(
          isActions: true,
          isChat: true,
          title: 'Add to Memories',
          svg: 'assets/svg/memories.svg',
          ontap: () async {
            await chatController.addAndRemoveStarredMessage(
              messageId: widget.messageId,
            );
            isAddedToMemoriesDone.value = true;
          },
        ),
        SizedBox(height: 1.h),
        if (widget.senderId !=
            uiController.userData.value['id'].toString()) ...[
          PopupCustomBtn(
            isActions: true,
            title: 'Report',
            icon: Icons.report,
            ontap: () {
              isReporting.value = true;
            },
          ),
          SizedBox(height: 1.h),
        ],
        if ((widget.senderId ==
            uiController.userData.value['id'].toString())) ...[
          PopupCustomBtn(
            isActions: true,
            title: 'Delete Message',
            icon: Icons.delete,
            ontap: () async {
              Get.back();
              showDialog(
                context: context,
                builder: (ctx) => DeletePopup(
                  title: 'Message',
                  delete: () async {
                    await chatController.deleteMessage(
                      messageId: widget.messageId,
                    );
                    Get.back();
                    widget.onMessageDelete();
                  },
                ),
              );
            },
          ),
          SizedBox(height: 1.h),
        ],
        Text(
          DateFormat('dd MMMM, yyyy | hh:mm aa').format(widget.createdAt),
          style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
            color: headingColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAddedToMemories() {
    return Container(
      constraints: BoxConstraints(maxHeight: 18.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/message_sent_icon.svg',
            height: 64,
          ),
          SizedBox(height: 3.h),
          PopupCustomBtn(
            isReporting: false,
            isCenterTitle: true,
            title: 'Added To Memories!',
            ontap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReporting() {
    final reasons = [
      'Harassment/Bullying',
      'Is A Scam/Fraud/Spam',
      'Promotes Violence/Self Harm',
      'Promoting Restricted Items',
      'Nudity/Sexual Activity',
      'Impersonating Someone Else',
      'Hate Speech'
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: 60.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            ...reasons.map((reason) => Column(
                  children: [
                    PopupCustomBtn(
                      isReporting: true,
                      title: reason,
                      ontap: () => _submitReport(reason),
                    ),
                    SizedBox(height: 1.h),
                  ],
                )),
            PopupCustomBtn(
              isReporting: true,
              title: 'Reason Not Listed Here',
              ontap: () {
                Get.back();
                _showSubmitReportAlert();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport(String reason) async {
    await chatController.report(
      id: widget.messageId,
      text: reason,
      type: "chat_message",
    );
    Get.back();
    isReporting.value = false;
    _showSubmitReportAlert(isReported: true);
  }

  void _showSubmitReportAlert({bool isReported = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubmitReportAlertWidget(
        messageId: widget.messageId,
        isReported: isReported,
      ),
    );
  }
}

class SubmitReportAlertWidget extends StatefulWidget {
  const SubmitReportAlertWidget(
      {super.key, required this.messageId, required this.isReported});

  final int messageId;
  final bool isReported;

  @override
  State<SubmitReportAlertWidget> createState() =>
      _SubmitReportAlertWidgetState();
}

class _SubmitReportAlertWidgetState extends State<SubmitReportAlertWidget> {
  final ChatController chatController = Get.find();
  final reportMessageTextController = TextEditingController();
  final typedTextLength = 0.obs;
  final isReported = false.obs;

  @override
  void initState() {
    super.initState();
    isReported.value = widget.isReported;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Container(
        width: 100.w,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: popColor,
        ),
        child: Obx(() {
          if (isReported.value) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              ],
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please Tell Us Your Reporting This Content',
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CustomTextFormField(
                      hintText: '',
                      controller: reportMessageTextController,
                      fillColor: headingColor.withOpacity(0.1),
                      borderColor: transparentColor,
                      isMaxLine: 6,
                      textLength: 100,
                      onChanged: (p0) => typedTextLength.value = p0.length,
                      textFieldPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Obx(() => Text(
                            '${typedTextLength.value}/100',
                            style: CustomTextStyle.styledTextWidget.bodySmall
                                ?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                PopupCustomBtn(
                  isReporting: false,
                  isCenterTitle: true,
                  title: 'Submit Report',
                  ontap: () async {
                    await chatController.report(
                      id: widget.messageId,
                      text: reportMessageTextController.text,
                      type: "chat_message",
                    );
                    isReported.value = true;
                  },
                ),
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isReporting: false,
                  isCenterTitle: true,
                  title: 'Cancel',
                  ontap: () => Get.back(),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
