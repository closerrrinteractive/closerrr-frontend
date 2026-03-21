import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/services/live_stream_service.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/utils/constant.dart';
import '../../widgets/custom_widgets/custom_popup_btn.dart';
import 'chat_background.dart';

class ChatControls extends StatelessWidget {
  final BuildContext ctx;
  final UserProfile? chatAdmin;
  final ChatUser? loggedInUser;
  final int closerDays;
  final dynamic chatId;
  final ChatRowData? chat;
  const ChatControls({
    super.key,
    this.chatId,
    this.chatAdmin,
    this.loggedInUser,
    this.chat,
    required this.ctx,
    required this.closerDays,
  });

  @override
  Widget build(BuildContext context) {
    final userInfo = Get.find<UserInformationController>();
    final chatController = Get.find<ChatController>();
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Container(
        width: 100.w,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: popColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Options',
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
              title: 'View Profile',
              icon: Icons.explore_outlined,
              ontap: () {
                Navigator.pop(context);
                return ctx.pushNamed(
                  'chat_profile',
                  extra: {
                    'profile': chatAdmin?.toJson(),
                    'chat_user': loggedInUser?.toJson(),
                    'closer_days': closerDays.toString(),
                    'chat_id': chatId,
                  },
                );
              },
            ),
            if (userInfo.isInfluencer.value) ...{
              SizedBox(height: 1.h),
              PopupCustomBtn(
                isActions: true,
                title: 'Start Closerrr Live',
                icon: Icons.video_call_outlined,
                ontap: () async {
                  // intilize getStream.io and start the live stream
                  final data = await LiveStreamService().startLivestream();
                  var cameraStatus = await Permission.camera.status;
                  var microphoneStatus = await Permission.microphone.status;
                  if (cameraStatus.isDenied ||
                      microphoneStatus.isDenied ||
                      cameraStatus.isPermanentlyDenied ||
                      microphoneStatus.isPermanentlyDenied) {
                    return showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(
                          'Permissions Required',
                          style: CustomTextStyle.styledTextWidget.headlineLarge,
                        ),
                        content: Text(
                          'Camera and Microphone permissions are required to go live. Please enable them in your device settings.',
                          style:
                              CustomTextStyle.styledTextWidget.headlineMedium,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                AppSettings.openAppSettings();
                              },
                              child: Text(
                                'Open Settings',
                                style: CustomTextStyle
                                    .styledTextWidget.labelMedium!
                                    .copyWith(color: primaryColor),
                              )),
                        ],
                      ),
                    );
                  } else {
                    ctx.pushNamed("live_stream", extra: {
                      'call': data["call"],
                      'host': userInfo.userData,
                      'id': data["id"],
                      'chat_id': chatId
                    });
                  }
                },
              ),
            },
            SizedBox(height: 1.h),
            PopupCustomBtn(
              isActions: true,
              title: 'View Media',
              icon: Icons.image_outlined,
              ontap: () {
                Navigator.pop(context);
                return ctx.pushNamed('chat_media_screen', extra: {
                  'chat_id': chatId,
                  'user': loggedInUser,
                  'profile': chatAdmin,
                  'chat': chat,
                });
              },
            ),
            SizedBox(height: 1.h),
            PopupCustomBtn(
              isActions: true,
              title: 'Chat Background',
              icon: Icons.flip_to_back_rounded,
              ontap: () {
                Navigator.pop(context);
                RxString tempBg = ''.obs;
                showDialog(
                  context: context,
                  builder: (_) => ChatBackground(
                    chatId: chatId,
                    loggedInUser: loggedInUser,
                    chatAdmin: chatAdmin,
                  ),
                ).then((value) {
                  if (value != null) {
                    tempBg.value = value;
                    Navigator.pop(context, tempBg.value);
                  }
                });
              },
            ),
            SizedBox(height: 1.h),
            const PopupCustomBtn(
              isActions: true,
              isChat: true,
              title: 'Add Chat Shortcut',
              svg: 'assets/svg/add_shortcut.svg',
            ),
            SizedBox(height: 1.h),
            if (!userInfo.isInfluencer.value) ...{
              PopupCustomBtn(
                isActions: true,
                isChat: true,
                title: 'Notifications',
                svg: 'assets/svg/notification_settings.svg',
                ontap: () {
                  Navigator.pop(context);
                  return ctx.pushNamed(
                    'chat_message_notifications',
                    extra: {
                      'influencer_id': chatAdmin?.id,
                    },
                  );
                },
              ),
              SizedBox(height: 1.h),
            },
            PopupCustomBtn(
              isActions: true,
              title: 'View Chat Settings',
              icon: Icons.settings_outlined,
              ontap: () {
                Navigator.pop(context);
                return ctx.pushNamed('chat_setting', extra: {
                  'chat_id': chatId,
                  'friend_id': loggedInUser?.userId ?? 0,
                  'chat_user': loggedInUser,
                  'profile': chatAdmin,
                  'chat': chat,
                });
              },
            ),
            SizedBox(height: 1.h),
            // PopupCustomBtn(
            //   isActions: true,
            //   title: 'Go Live',
            //   icon: Icons.video_call_outlined,
            //   ontap: () async {
            //     Navigator.pop(context);
            //     final call = await LiveStreamService().startLivestream();
            //     ctx.pushNamed("live_stream", extra: {
            //       'call': call,
            //       'host': userInformationController.userData
            //     });
            //   },
            // ),
            // SizedBox(height: 1.h),
            if (userInfo.isInfluencer.value)
              PopupCustomBtn(
                isActions: true,
                title: 'Add To Story',
                svg: 'assets/svg/add_story.svg',
                isChat: true,
                ontap: () async {
                  final story = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                  );

                  Map<String, dynamic> data = {};

                  if (story != null) {
                    String type = story.path.split('.').last;
                    String path = story.path;
                    String selectedMediaType = Helpers.extractMediaType(path);
                    data['image'] = await d.MultipartFile.fromFile(
                      path,
                      filename: path.split('/').last,
                      contentType: d.DioMediaType(
                        selectedMediaType,
                        type.toLowerCase(),
                      ),
                    );

                    data['media_type'] = selectedMediaType;

                    final result = await chatController.addStory(
                      data: data,
                      chatId: chatId,
                    );
                    if (result) {
                      chatController.storyData.refresh();
                      await chatController.getStory(
                        userId: userInfo.userData.value['id'],
                      );
                      Helpers.toast('Story Added Successfully');
                      Get.back();
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
