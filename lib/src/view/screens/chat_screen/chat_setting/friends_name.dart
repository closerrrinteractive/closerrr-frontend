import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/constant.dart';
import '../../../../controller/chat/chat_controller.dart';
import '../../../widgets/custom_widgets/custom_text_formfield.dart';

class FriendName extends StatefulWidget {
  final dynamic chatId;
  final dynamic friendId;
  final ChatUser? chatUser;
  final ChatRowData? chat;

  const FriendName({
    super.key,
    this.chatId,
    this.friendId,
    this.chatUser,
    this.chat,
  });

  @override
  State<FriendName> createState() => _FriendNameState();
}

class _FriendNameState extends State<FriendName> {
  final TextEditingController nameController = TextEditingController();
  final ChatController chatController = Get.find();
  final isProfileName = true.obs;
  ChatRowData? chatRowData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatRowData = chatController.chats.firstWhereOrNull(
            (chat) => chat.id == widget.chatId,
          ) ??
          widget.chat;

      final existingName = widget.chatUser?.friendName?.value ?? '';
      if (existingName.isNotEmpty) {
        isProfileName.value = false;
        nameController.text = existingName;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomName() async {
    if (nameController.text.trim().isEmpty) {
      Helpers.toast('Friend name is required');
      return;
    }

    final success = await chatController.updateNickname(
      chatId: widget.chatId,
      isYours: false,
      nickname: nameController.text.trim(),
    );

    if (success && mounted) {
      widget.chatUser?.friendName?.value = nameController.text.trim();
      context.pop(nameController.text.trim());
    }
  }

  Future<void> _useProfileName() async {
    final success = await chatController.updateNickname(
      chatId: widget.chatId,
      isYours: false,
    );

    if (success && mounted) {
      widget.chatUser?.friendName?.value = '';
      context.pop('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Scaffold(
      appBar: ChatAppBar(
        isChatSetting: true,
        chatTitle: 'Friend Name',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'How would you like to ',
                    style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                      color: blackColor,
                      fontSize: (widthScale * kTextFormFactor) * 15,
                    ),
                  ),
                  TextSpan(
                    text: 'name this friend',
                    style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: (widthScale * kTextFormFactor) * 15,
                    ),
                  ),
                  TextSpan(
                    text: ' in your chat list?',
                    style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                      color: blackColor,
                      fontSize: (widthScale * kTextFormFactor) * 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Obx(
              () => _buildSwitchRow(
                widthScale: widthScale,
                title: 'Use Closerrr Profile Name',
                value: isProfileName.value,
                onChanged: (_) async {
                  isProfileName.value = true;
                  await _useProfileName();
                },
              ),
            ),
            SizedBox(height: 1.h),
            Obx(
              () => _buildSwitchRow(
                widthScale: widthScale,
                title: 'Use Custom Name',
                value: !isProfileName.value,
                onChanged: (_) {
                  isProfileName.value = false;
                },
              ),
            ),
            SizedBox(height: 2.h),
            Obx(() {
              if (isProfileName.value) return const SizedBox.shrink();
              return Column(
                children: [
                  CustomTextFormField(
                    hintText: 'Enter friend name',
                    controller: nameController,
                    borderColor: headingColor,
                    radius: 12,
                    svg: 'assets/svg/friends.svg',
                    fillColor: transparentColor,
                    containerWidget: const SizedBox(),
                  ),
                  SizedBox(height: 2.h),
                  CustomButton(
                    width: 100.w,
                    padding: const EdgeInsets.all(16),
                    buttonTitle: 'SAVE CHANGES',
                    backButtonColor: primaryColor,
                    isTextStyle: true,
                    onlyText: true,
                    onPress: _saveCustomName,
                    borderRadius: 10.sp,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required double widthScale,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: (widthScale * kTextFormFactor) * 16,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: whiteColor,
            activeTrackColor: primaryColor,
            inactiveThumbColor: whiteColor,
            trackOutlineWidth: const WidgetStatePropertyAll(0),
          ),
        ],
      ),
    );
  }
}
