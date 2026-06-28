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
  final bool simulateError;

  const MediaPopup({
    super.key,
    this.media,
    this.chatId,
    this.chat,
    required this.id,
    required this.mediaDownloadTitle,
    this.simulateError = false,
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Obx(
        () {
          if (chatController.isMediaDownloading.value) {
            return _buildDownloadingProgressUI(widthScale);
          } else if (chatController.isMediaDownloaded.value) {
            return _buildDownloadCompleteUI();
          } else if (chatController.isMediaDownloadFailed.value) {
            return _buildDownloadErrorUI();
          } else {
            return _buildActions(widthScale);
          }
        },
      ),
    );
  }

  Widget _buildCardWrapper({required Widget child, bool showLogo = true}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 100.w,
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: popColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
        if (showLogo)
          Positioned(
            top: 0,
            child: Image.asset(
              'assets/images/main-closer.png',
              height: 80,
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadingProgressUI(double widthScale) {
    return _buildCardWrapper(
      showLogo: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 42, left: 24, right: 24, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Downloading...',
              style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                color: headingColor,
                fontSize: (widthScale * kTextFormFactor) * 16,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<double>(
              valueListenable: chatController.mediaProgressNotifier,
              builder: (context, value, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: 0.0, end: value),
                      builder: (context, animatedValue, _) {
                        return LinearProgressIndicator(
                          minHeight: 12,
                          value: animatedValue,
                          backgroundColor: headingColor.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(headingColor),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<double>(
              valueListenable: chatController.mediaProgressNotifier,
              builder: (context, value, _) {
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0.0, end: value),
                  builder: (context, animatedValue, _) {
                    return Text(
                      '${(animatedValue * 100).floor()}%',
                      style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                        color: headingColor,
                        fontSize: (widthScale * kTextFormFactor) * 14,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCompleteUI() {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return _buildCardWrapper(
      showLogo: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              completeSvgIcon,
              height: 72,
              width: 72,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                chatController.isMediaDownloaded.value = false;
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: headingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Download Complete',
                    style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                      color: headingColor,
                      fontSize: (widthScale * kTextFormFactor) * 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadErrorUI() {
    return GestureDetector(
      onTap: () {
        chatController.isMediaDownloadFailed.value = false;
        Navigator.pop(context);
      },
      child: _buildCardWrapper(
        showLogo: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 42, left: 24, right: 24, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sorry!',
                style: TextStyle(
                  fontFamily: 'Hellix',
                  color: headingColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Network Error!',
                style: TextStyle(
                  fontFamily: 'Hellix',
                  color: const Color(0xFFFF3B30),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The Picture Could Not Be Downloaded.\nPlease Check Your Internet Connection\nAnd Try Again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Hellix',
                  color: headingColor,
                  height: 1.4,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ⚡ Actions UI
  Widget _buildActions(double widthScale) {
    return _buildCardWrapper(
      showLogo: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 16),
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
            SizedBox(height: 1.5.h),
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
    if (widget.simulateError) {
      chatController.isMediaDownloading.value = true;
      chatController.mediaProgressNotifier.value = 0.0;
      await Future.delayed(const Duration(milliseconds: 400));
      chatController.mediaProgressNotifier.value = 0.35;
      await Future.delayed(const Duration(milliseconds: 500));
      chatController.isMediaDownloading.value = false;
      chatController.isMediaDownloadFailed.value = true;
      return;
    }

    if (widget.media == null) return;
    chatController.isMediaDownloading.value = true;
    
    String mediaUrl = widget.media!;
    if (!mediaUrl.contains('http')) {
      if (mediaUrl.contains('uploads/')) {
        mediaUrl = ApiStrings.s3ImageUrl + mediaUrl;
      } else {
        mediaUrl = ApiStrings.imageUrl + mediaUrl;
      }
    }
    
    await chatController.downloadMedia(
      mediaUrl: mediaUrl,
      isMedia: true,
    );
  }
}
