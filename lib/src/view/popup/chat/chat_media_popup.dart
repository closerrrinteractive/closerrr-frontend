import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:closerrr/src/view/popup/chat/confirmation_popup.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_popup_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/api_string.dart';
import '../../../../core/utils/constant.dart';

class MediaPopup extends StatefulWidget {
  final String? media;
  final String mediaDownloadTitle;
  final int id;
  final int? chatId;
  final ChatRowData? chat;

  const MediaPopup({
    super.key,
    this.media,
    this.chatId,
    this.chat,
    required this.id,
    required this.mediaDownloadTitle,
  });

  @override
  State<MediaPopup> createState() => _MediaPopupState();
}

class _MediaPopupState extends State<MediaPopup> {
  final chatController = Get.find<ChatController>();
  final profileImage = Rxn<XFile>();
  final reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.isMediaDownloaded.value = false;
      chatController.isMediaDownloading.value = false;
      chatController.isMediaDownloadFailed.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Obx(
        () => chatController.isMediaDownloading.value ||
                chatController.isMediaDownloaded.value
            ? _buildDownloading(widthScale)
            : _buildActions(widthScale),
      ),
    );
  }

  /// 📥 Downloading UI
  Widget _buildDownloading(double widthScale) {
    return Obx(
      () => SizedBox(
        height: chatController.isMediaDownloaded.value ? 26.h : 22.h,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (chatController.isMediaDownloaded.value)
              _buildDownloadCompleteUI()
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/main-closer.png', height: 80),
                  _buildProgressBar(widthScale),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCompleteUI() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.only(top: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: popColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/svg/message_sent_icon.svg', height: 64),
          SizedBox(height: 2.h),
          PopupCustomBtn(
            title: 'Download Complete',
            isCenterTitle: true,
            ontap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double widthScale) {
    return ValueListenableBuilder<double>(
      valueListenable: chatController.mediaProgressNotifier,
      builder: (context, value, _) {
        return Container(
          width: 100.w,
          padding: const EdgeInsets.all(24),
          margin: EdgeInsets.only(top: 4.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: popColor,
          ),
          child: Column(
            children: [
              Text(
                'Downloading...',
                style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
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
                style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ⚡ Actions UI
  Widget _buildActions(double widthScale) {
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
          Text(
            'Actions',
            style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: (widthScale * kTextFormFactor) * 20,
            ),
          ),
          SizedBox(height: 2.h),
          if (widget.chatId != null &&
              widget.chatId != 0 &&
              widget.id == 0 &&
              userInformationController.isInfluencer.value) ...[
            PopupCustomBtn(
              isActions: true,
              title: 'Change Picture',
              ontap: _openImagePicker,
              icon: Icons.photo_camera_back_rounded,
            ),
            SizedBox(height: 1.h),
          ],
          PopupCustomBtn(
            isActions: true,
            title:
                'Download ${widget.mediaDownloadTitle == 'Image' ? 'Picture' : widget.mediaDownloadTitle}',
            ontap: _startDownload,
            icon: Icons.file_download_rounded,
          ),
        ],
      ),
    );
  }

  void _openImagePicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: popColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Choose Option",
          style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
            color: primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPickerOption(
              label: 'Gallery',
              icon: SvgPicture.asset(selectImage, height: 7.h),
              source: ImageSource.gallery,
            ),
            _buildPickerOption(
              label: 'Camera',
              icon: Icon(Icons.camera, color: primaryColor, size: 4.h),
              source: ImageSource.camera,
            ),
          ],
        ),
      ),
    ).then((_) {
      if (profileImage.value != null) _confirmChangePicture();
    });
  }

  Widget _buildPickerOption({
    required String label,
    required Widget icon,
    required ImageSource source,
  }) {
    return InkWell(
      overlayColor: const WidgetStatePropertyAll(transparentColor),
      onTap: () async {
        final picked = await ImagePicker().pickImage(
          source: source,
          imageQuality: 50,
          maxHeight: 1080,
          maxWidth: 1920,
        );
        if (picked != null) {
          profileImage.value = picked;
          Get.back();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding:
                  label.contains('Camera') ? const EdgeInsets.all(10) : null,
              decoration: label.contains('Camera')
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(width: 1, color: borderColor),
                      color: whiteColor,
                    )
                  : null,
              child: icon),
          SizedBox(height: 1.h),
          Text(
            label,
            style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
              color: primaryColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Confirm picture change
  void _confirmChangePicture() {
    final isLoading = false.obs;
    showDialog(
      context: context,
      builder: (ctx) => Obx(
        () => ConfirmationPopup(
          title: 'Are you sure you want to change picture?',
          isLoading: isLoading.value,
          onTapYes: () async {
            if (profileImage.value == null) return;
            isLoading.value = true;

            final success = await chatController.updateChatSettings(
              chatId: widget.chatId ?? 0,
              groupIcon: XFile(profileImage.value!.path),
            );

            if (success['status'] == 'SUCCESS') {
              widget.chat?.groupIcon?.value = success['data']['group_icon'];
              Get.back();
            } // close popup
            isLoading.value = false;
          },
        ),
      ),
    );
  }

  /// 📥 Start download
  Future<void> _startDownload() async {
    if (widget.media == null) return;
    chatController.isMediaDownloading.value = true;
    await chatController.downloadMedia(
      mediaUrl: widget.media!.contains('https')
          ? widget.media!
          : ApiStrings.s3ImageUrl + widget.media!,
      isMedia: true,
    );
  }
}
