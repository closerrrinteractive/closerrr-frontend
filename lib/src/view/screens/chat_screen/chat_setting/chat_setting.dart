import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/themes/text_style.dart';
import '../../../../../core/utils/constant.dart';
import '../../../popup/chat/chat_background.dart';
import '../../../widgets/specific_widgets/custom_setting_tile.dart';

class ChatSetting extends StatefulWidget {
  final dynamic chatId;
  final dynamic friendId;
  final ChatUser? chatUser;
  final ChatRowData? chat;
  final UserProfile? profile;

  const ChatSetting(
      {super.key,
      this.chatId,
      this.friendId,
      this.chatUser,
      this.profile,
      this.chat});

  @override
  State<ChatSetting> createState() => _ChatSettingState();
}

class _ChatSettingState extends State<ChatSetting> {
  final UserInformationController userInformationController = Get.find();
  final ChatController chatController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blueBack.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => RouterController.current.pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withOpacity(0.08),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            backSvgIcon,
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Chat Settings',
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: (widthScale * kTextFormFactor) * 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final chatIndex = chatController.chats.indexWhere((c) => c.id == (widget.chat?.id ?? widget.chatId));
        final ChatRowData? chat = chatIndex != -1 ? chatController.chats[chatIndex] : widget.chat;
        
        final userId = userInformationController.userData.value['id'].toString();
        final UserData? loggedInUser = chat?.users.firstWhereOrNull((user) => user.id.toString() == userId);
        final ChatUser? currentChatUser = loggedInUser?.chatUser;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: ApiStrings.imageUrl +
                      (chat?.groupIcon?.value ??
                          widget.profile?.profilePic ??
                          ''),
                  height: 96,
                  width: 96,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Image.asset(person, height: 96, width: 96),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                (currentChatUser?.friendName?.value != null &&
                        currentChatUser!.friendName!.value.isNotEmpty)
                    ? currentChatUser.friendName!.value
                    : (chat?.groupName?.value != null &&
                            chat!.groupName!.value.isNotEmpty)
                        ? chat.groupName!.value
                        : widget.profile?.fullname ??
                            widget.profile?.username ??
                            '',
                style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: widthScale * kTextFormFactor * 20,
                ),
              ),
              SizedBox(height: 4.h),

              /// Settings list
              ListView.builder(
                shrinkWrap: true,
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  // Skip Friend Name if influencer
                  if (userInformationController.isInfluencer.value &&
                      index == 0) {
                    return const SizedBox.shrink();
                  }

                  if (userInformationController.isInfluencer.value &&
                      name[index].contains('Your Nickname')) {
                    name[index] = 'Your Chat Name';
                  }

                  final option = icons[index];
                  return TabTiles(
                    icons: option,
                    name: name[index],
                    setting: true,
                    padding: EdgeInsets.only(bottom: 2.h),
                    onTap: () => {
                      _handleTap(index, context, chat, currentChatUser,
                          isInfluencer:
                              userInformationController.isInfluencer.value)
                    },
                  );
                },
              )
            ],
          ),
        );
      }),
    );
  }

  void _handleTap(int index, BuildContext context, ChatRowData? chat, ChatUser? chatUser, {isInfluencer = false}) {
    switch (index) {
      case 0:
        context.pushNamed('friend_name', extra: {
          'chat_id': chat?.id ?? widget.chatId,
          'friend_id': widget.friendId,
          'chat_user': chatUser,
          'chat': chat
        }).then((value) {
          if (!(value.isBlank ?? false)) {
            chatUser?.friendName?.value = value.toString();
          } else {
            chatUser?.friendName = null;
          }
        });
        break;

      case 1:
        context.pushNamed('nick_name', extra: {
          'chat_id': chat?.id ?? widget.chatId,
          'friend_id': widget.friendId,
          'chat_user': chatUser,
          'is_influencer': isInfluencer,
          'chat': chat
        });
        break;

      case 2:
        showDialog(
          context: context,
          builder: (context) => ChatBackground(
            chatId: chat?.id ?? widget.chatId,
            chatAdmin: widget.profile,
            loggedInUser: chatUser,
          ),
        );
        break;

      case 3:
        context.pushNamed('chat_notifications', extra: {
          'influencerId': widget.friendId,
        });
        break;
    }
  }
}
