// ignore_for_file: must_be_immutable

import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../controller/authentication/auth_controller.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../widgets/custom_widgets/custom_popup_btn.dart';

class ChatBackground extends StatefulWidget {
  ChatBackground({
    super.key,
    required this.chatId,
    this.loggedInUser,
    this.chatAdmin,
  });
  final int chatId;
  ChatUser? loggedInUser;
  UserProfile? chatAdmin;

  @override
  State<ChatBackground> createState() => _ChatBackgroundState();
}

class _ChatBackgroundState extends State<ChatBackground> {
  ChatController chatController = Get.find();
  AuthController authController = Get.find();

  final isPickImage = false.obs;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: PopScope(
        child: Container(
          width: 100.w,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: popColor,
          ),
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Chat Background',
                      style: CustomTextStyle.styledTextWidget.titleMedium
                          ?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  if (isPickImage.value) ...{
                    PopupCustomBtn(
                      isChat: true,
                      title: 'From Gallery',
                      svg: 'assets/svg/change_background.svg',
                      ontap: () async {
                        final image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (image == null) {
                          Helpers.toast('Image can\'t be null');
                        } else {
                          chatController.updateChatBackground(
                            chatId: widget.chatId,
                            type: 'custom',
                            background: image,
                          );
                          // Both of the lines need to set the new background
                          widget.loggedInUser?.chatBackground = image.path;
                          chatController.activeChatBackground.value =
                              image.path;
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(height: 1.h),
                    PopupCustomBtn(
                      isChat: true,
                      title: 'From Camera',
                      icon: Icons.camera,
                      ontap: () async {
                        final image = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (image == null) {
                          Helpers.toast('Image is Required');
                        } else {
                          chatController.updateChatBackground(
                            chatId: widget.chatId,
                            type: 'custom',
                            background: image,
                          );
                          // Both of the lines need to set the new background
                          widget.loggedInUser?.chatBackground = image.path;
                          chatController.activeChatBackground.value =
                              image.path;
                          Navigator.pop(context);
                        }
                      },
                    ),
                  } else ...{
                    PopupCustomBtn(
                      isChat: true,
                      title: 'Use Closerrr Default',
                      svg: 'assets/svg/view_media.svg',
                      ontap: () {
                        chatController.updateChatBackground(
                          chatId: widget.chatId,
                          type: 'closerrr_default',
                        );
                        chatController.activeChatBackground.value =
                            "closerrr_default";
                        Navigator.pop(context, '');
                      },
                    ),
                    SizedBox(height: 1.h),
                    if ((widget.chatAdmin?.id) !=
                        authController
                            .userInformationController.userData.value['id'])
                      PopupCustomBtn(
                        isChat: true,
                        title: 'Use Chat Default',
                        svg: 'assets/svg/chat_default_icon.svg',
                        ontap: () {
                          chatController.updateChatBackground(
                            chatId: widget.chatId,
                            type: 'chat_default',
                          );
                          chatController.activeChatBackground.value =
                              "chat_default";
                          Navigator.pop(context, 'chat_default');
                        },
                      ),
                    if (!userInformationController.isInfluencer.value) ...{
                      SizedBox(height: 1.h),
                      PopupCustomBtn(
                        isChat: true,
                        title: 'Set Your Own',
                        svg: 'assets/svg/edit.svg',
                        ontap: () {
                          isPickImage.value = true;
                        },
                      ),
                    }
                  }
                ],
              )),
        ),
      ),
    );
  }
}
