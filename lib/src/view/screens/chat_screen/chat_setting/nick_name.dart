// ignore_for_file: use_build_context_synchronously

import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/constant.dart';
import '../../../../controller/chat/chat_controller.dart';
import '../../../../models/chat/chat_model.dart';
import '../../../widgets/custom_widgets/custom_text_formfield.dart';

class YourNickName extends StatefulWidget {
  final dynamic chatId;
  final dynamic friendId;
  final ChatUser? chatUser;
  final bool? isInfluencer;
  final ChatRowData? chat;
  const YourNickName(
      {super.key,
      this.chatId,
      this.friendId,
      this.chatUser,
      this.isInfluencer,
      this.chat});

  @override
  State<YourNickName> createState() => _YourNickNameState();
}

class _YourNickNameState extends State<YourNickName> {
  TextEditingController nameController = TextEditingController();
  ChatController chatController = Get.find();
  late final ChatRowData? chatRowData;
  final isProfileName = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((value) async {
      chatRowData = chatController.chats.value.firstWhere((chat) {
        return chat.id == widget.chatId;
      });
      if (widget.chatUser?.nickname != null && widget.friendId != null) {
        isProfileName.value = false;
      } else {
        isProfileName.value = true;
      }

      if (chatRowData?.groupName?.value != null) {
        isProfileName.value = false;
        nameController.text = chatRowData?.groupName?.value ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      appBar: ChatAppBar(
        isChatSetting: true,
        chatTitle: widget.isInfluencer == true ? "Your Chat Name" : "Nick Name",
      ),
      body: Container(
        width: 100.w,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: widget.isInfluencer == true
                        ? 'How Would You Like Your Fans To'
                        : 'How Would You Like Your Friend To',
                    style:
                        CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                      color: blackColor,
                      fontSize: (widthScale * kTextFormFactor) * 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: widget.isInfluencer == true
                        ? ' See Your Name '
                        : ' Call You ',
                    style:
                        CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                      color: primaryColor,
                      fontSize: (widthScale * kTextFormFactor) * 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        widget.isInfluencer == true ? 'As In The Chat?' : 'As?',
                    style:
                        CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                      color: blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: (widthScale * kTextFormFactor) * 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    widget.isInfluencer == true
                        ? 'Use Original Name'
                        : 'Use Closerrr Profile Name',
                    style: CustomTextStyle.styledTextWidget.bodySmall!.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: (widthScale * kTextFormFactor) * 18,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Switch(
                        value: isProfileName.value,
                        onChanged: (_) async {
                          isProfileName.value = !isProfileName.value;
                          if (isProfileName.value) {
                            if (widget.isInfluencer == true) {
                              await chatController.updateChatSettings(
                                  chatId: widget.chatId, groupName: null);
                            } else {
                              await chatController.updateNickname(
                                chatId: widget.chatId,
                                isYours: true,
                              );
                            }
                          }
                        },
                        activeColor: whiteColor,
                        activeTrackColor: primaryColor,
                        inactiveThumbColor: whiteColor,
                        trackOutlineWidth: const WidgetStatePropertyAll(0),
                      ))
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: dividerColor,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.isInfluencer == true
                            ? 'Use Custom Name'
                            : 'Use Custom Nickname',
                        style: CustomTextStyle.styledTextWidget.bodySmall!
                            .copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: (widthScale * kTextFormFactor) * 18,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Switch(
                            value: !isProfileName.value,
                            onChanged: (_) async {
                              isProfileName.value = !isProfileName.value;
                              if (isProfileName.value) {
                                if (widget.isInfluencer == true) {
                                  await chatController.updateChatSettings(
                                      chatId: widget.chatId, groupName: null);
                                } else {
                                  await chatController.updateNickname(
                                    chatId: widget.chatId,
                                    isYours: true,
                                  );
                                }
                              }
                            },
                            activeColor: whiteColor,
                            activeTrackColor: primaryColor,
                            inactiveThumbColor: whiteColor,
                            trackOutlineWidth: const WidgetStatePropertyAll(0),
                          ))
                    ],
                  ),
                  // SizedBox(height: 2.h),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Obx(() {
              if (!isProfileName.value) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: CustomTextFormField(
                        hintText: widget.isInfluencer == true
                            ? 'Enter Custom name'
                            : 'Enter your Nickname',
                        cursorColor: headingColor,
                        hintStyle: CustomTextStyle.styledTextWidget.bodyMedium
                            ?.copyWith(
                          fontSize: (widthScale * kTextFormFactor) * 14,
                          color: primaryColor.withOpacity(0.6),
                        ),
                        style: CustomTextStyle.styledTextWidget.bodyMedium
                            ?.copyWith(
                          color: primaryColor,
                          fontSize: (widthScale * kTextFormFactor) * 14,
                        ),
                        controller: nameController,
                        borderColor: headingColor,
                        radius: 12,
                        svg: 'assets/svg/friends.svg',
                        fillColor: transparentColor,
                        containerWidget: const SizedBox(),
                      ),
                    ),
                    const Divider(
                      color: dividerColor,
                    ),
                    SizedBox(height: 1.h),
                    Obx(() => CustomButton(
                          width: 100.w,
                          padding: const EdgeInsets.all(16),
                          buttonTitle: 'SAVE CHANGES',
                          backButtonColor: isProfileName.value
                              ? primaryColor.withOpacity(0.5)
                              : primaryColor,
                          isTextStyle: true,
                          onlyText: true,
                          onPress: () async {
                            if (!isProfileName.value) {
                              if (nameController.text.isEmpty) {
                                Helpers.toast('Nickname is Required!!');
                                return;
                              }
                              if (widget.isInfluencer == true) {
                                await chatController.updateChatSettings(
                                    chatId: widget.chatId,
                                    groupName: nameController.text);
                                chatRowData?.groupName?.value =
                                    nameController.text;
                              } else {
                                await chatController
                                    .updateNickname(
                                  chatId: widget.chatId,
                                  isYours: true,
                                  nickname: nameController.text,
                                )
                                    .then((value) {
                                  if (value) {
                                    Helpers.toast('Nick Name Updated!');
                                  }
                                });
                              }

                              context.pop();
                              context.pop();
                            }
                          },
                          borderRadius: 10.sp,
                        ))
                  ],
                );
              }
              return const SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}
