import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../widgets/custom_widgets/custom_popup_btn.dart';

class ChatTileHold extends StatefulWidget {
  final String secondaryText;
  final String text;
  final ChatRowData chat;
  final int chatId;
  final int index;
  final VoidCallback onTapChangeIsFavorite;
  const ChatTileHold({
    super.key,
    required this.secondaryText,
    required this.text,
    required this.chat,
    required this.chatId,
    required this.onTapChangeIsFavorite,
    required this.index,
  });

  @override
  State<ChatTileHold> createState() => _ChatTileHoldState();
}

class _ChatTileHoldState extends State<ChatTileHold> {
  final dio = d.Dio();

  ChatController chatController = Get.find<ChatController>();
  UserInformationController uiController =
      Get.find<UserInformationController>();
  RxString userId = ''.obs;

  final Rx<UserData?> chatAdmin = Rx<UserData?>(null);
  final Rx<UserData?> loggedInUser = Rx<UserData?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userId.value = await Helpers.getUserId();
      chatAdmin.value = Helpers.getAdmin(users: widget.chat.users);
      loggedInUser.value = Helpers.getUser(
        users: widget.chat.users,
        userId: userId.value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                widget.text,
                style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            PopupCustomBtn(
              isChat: widget.chat.isFavourite?.value ?? false ? false : true,
              isChatHold: false,
              title: widget.secondaryText,
              ontap: () {
                //
                // if (widget.chat.isFavourite?.value ?? false) {
                //   // widget.chat.isFavourite!.value = false;
                //   chatController.chats[widget.index].isFavourite!.value = false;
                // } else {
                //   // widget.chat.isFavourite!.value = true;
                //   chatController.chats[widget.index].isFavourite!.value = true;
                // }
                // chatController.addAndRemoveFavouriteChat(chatId: widget.chatId).then(
                //   (value) {
                //     // chatController.chats.refresh();
                //   },
                // );
                widget.onTapChangeIsFavorite();
                Navigator.pop(context);
              },
            ),
            // SizedBox(height: 2.h),
            // Obx(() {
            //   return (chatAdmin.value?.id.toString() == userId.value)
            //       ? PopupCustomBtn(
            //           isChat: widget.chat.isFavourite?.value ?? false
            //               ? false
            //               : true,
            //           isChatHold: false,
            //           title: "Add Story",
            //           ontap: () async {
            //             final story = await ImagePicker()
            //                 .pickImage(source: ImageSource.gallery);

            //             Map<String, dynamic> data = {};

            //             if (story != null) {
            //               String type = story.path.split('.').last;
            //               String path = story.path;
            //               String selectedMediaType =
            //                   Helpers.extractMediaType(path);
            //               data['image'] = await d.MultipartFile.fromFile(
            //                 path,
            //                 filename: path.split('/').last,
            //                 contentType: d.DioMediaType(
            //                   selectedMediaType,
            //                   type.toLowerCase(),
            //                 ),
            //               );

            //               data['media_type'] = selectedMediaType;

            //               await chatController
            //                   .addStory(
            //                 data: data,
            //                 chatId: widget.chatId,
            //               )
            //                   .then((value) async {
            //                 if (value) {
            //                   await chatController.getStory(
            //                     userId: uiController.userData.value['id'],
            //                   );
            //                   Navigator.pop(context);
            //                 } else {
            //                   Helpers.toast('Something went wrong');
            //                 }
            //               });
            //             }
            //           })
            //       : Container();
            // }),
          ],
        ),
      ),
    );
  }
}
