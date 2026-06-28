import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/debug_log.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
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
      // #region agent log
      DebugLog.write(
        location: 'chat_tile_hold.dart:initState',
        message: 'ChatTileHold built',
        hypothesisId: 'A',
        data: {
          'chatId': widget.chatId,
          'title': widget.text,
          'userCount': widget.chat.users.length,
        },
      );
      // #endregion
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: transparentColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 6.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
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
                textAlign: TextAlign.center,
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
                widget.onTapChangeIsFavorite();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
