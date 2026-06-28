import 'dart:convert';

import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/services/live_stream_service.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/config/helpers.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/authentication/auth_controller.dart';
import '../../../controller/user_information/user_info_controller.dart';
import '../specific_widgets/chat/custom_story_view.dart';

class ChatTile extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onHold;
  final VoidCallback onTapChat;
  final ChatRowData chat;

  const ChatTile({
    super.key,
    required this.onTap,
    required this.onTapChat,
    required this.onHold,
    required this.chat,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  late final AuthController authController;
  UserInformationController uiController = Get.find();
  final RxString userId = ''.obs;
  double radius = 7.0;

  final Rx<UserData?> chatAdmin = Rx<UserData?>(null);
  final Rx<UserData?> loggedInUser = Rx<UserData?>(null);

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId.value = await Helpers.getUserId();
      chatAdmin.value = Helpers.getAdmin(users: widget.chat.users);
      loggedInUser.value =
          Helpers.getUser(users: widget.chat.users, userId: userId.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return GestureDetector(
      onTap: widget.onTapChat,
      onLongPress: widget.onHold,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.6.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16.sp),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.12),
              offset: const Offset(0, 4),
              spreadRadius: 0,
              blurRadius: 16,
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(widthScale),
                Obx(() {
                  RxList<LiveStreamM>? liveStreams =
                      chatAdmin.value?.liveStreams;
                  if (liveStreams?.isNotEmpty == true) {
                    return Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: logOutColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 0.0), // removes default padding
                          minimumSize: const Size(0, 0), // shrinks the tap area
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // removes extra touch space
                        ),
                        onPressed: () async {
                          LiveStreamM? liveStream = liveStreams?.first;
                          Map userData = {
                            "meta_data": jsonEncode({
                              "user_id": liveStream?.user_id,
                              "id": liveStream?.live_stream_id,
                              "chat_id": liveStream?.chat_id,
                              "Profile": {
                                "username": liveStream?.host_name,
                                "profile_pic": liveStream?.host_profile_pic
                              }
                            }),
                            "profile_pic": liveStream?.host_profile_pic,
                            "id": liveStream?.live_stream_id,
                            "type": "JOIN_LIVE_STREAM",
                            "username": liveStream?.host_name
                          };

                          final data = await LiveStreamService().startLivestream(
                              id: userData["id"],
                              join: true,
                              streamId: jsonDecode(userData["meta_data"])["id"]);
                          context.pushNamed("live_stream", extra: {
                            'call': data["call"],
                            'userData': userData
                          });
                        },
                        child: Text(
                          "Join Live",
                          style: CustomTextStyle.styledTextWidget.displayMedium
                              ?.copyWith(color: whiteColor),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
              ],
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildChatInfo(widthScale),
            ),
            SizedBox(width: 2.w),
            _buildChatDetails(widthScale),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(double widthScale) {
    RxString? groupIcon = widget.chat.groupIcon;
    return Obx(() => GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              StatusView(
                radius: 3.h,
                spacing: 15,
                strokeWidth: 4,
                indexOfSeenStatus: widget.chat.unreadCount.value,
                numberOfStatus: widget.chat.storyCount.value,
                padding: widget.chat.storyCount.value != 0 ? 3 : 0,
                centerImageUrl: ApiStrings.imageUrl +
                    (groupIcon?.value ??
                        chatAdmin.value?.profile?.profilePic ??
                        ''),
                seenColor: Colors.grey,
                unSeenColor: blueBack,
              ),
            ],
          ),
        ));
  }

  Widget _buildChatInfo(double widthScale) {
    return Obx(() {
      final profile = chatAdmin.value?.profile;
      RxString? groupName = widget.chat.groupName;
      final customFriendName = loggedInUser.value?.chatUser.friendName?.value;
      final creatorChatName = chatAdmin.value?.chatUser.nickname?.toString();
      final defaultName = groupName?.value ??
          profile?.fullname ??
          profile?.username ??
          "no name";

      final displayName = (customFriendName != null && customFriendName.isNotEmpty)
          ? customFriendName
          : (creatorChatName != null && creatorChatName.isNotEmpty)
              ? creatorChatName
              : defaultName;

      final double scale = widthScale * kTextFormFactor;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
              color: mainTextColor,
              fontWeight: FontWeight.bold,
              height: 1.1,
              fontSize: 16 * scale,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.chat.lastMessage.value.isNotEmpty &&
                    widget.chat.lastMessage.value.first.messageText != null
                ? widget.chat.lastMessage.value.first.messageText!
                            .contains('@@') &&
                        loggedInUser.value?.profile?.id != null &&
                        loggedInUser.value?.profile?.id !=
                            widget.chat.lastMessage.value.first.senderId
                    ? "@${loggedInUser.value?.profile?.username ?? ''}"
                    : widget.chat.lastMessage.value.first.messageText ??
                        'media file'
                : 'No Messages',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: CustomTextStyle.styledTextWidget.headlineLarge!.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              height: 1.1,
              fontSize: 11 * scale,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChatDetails(double widthScale) {
    return Obx(() {
      Rx<DateTime>? time = widget.chat.lastMessage.isNotEmpty
          ? widget.chat.lastMessage.last.updatedAt
          : null;
      String createdAt = "";
      if (time != null) {
        final DateTime messageTime = time.value;
        final DateTime now = DateTime.now();
        final difference = now.difference(messageTime);
        if (difference.inHours < 24) {
          createdAt = DateFormat('h:mm a').format(messageTime);
        } else {
          createdAt = DateFormat('dd/MM/yy').format(messageTime);
        }
      }
      final double scale = widthScale * kTextFormFactor;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (time != null)
            Text(
              createdAt,
              style: CustomTextStyle.styledTextWidget.headlineLarge?.copyWith(
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 11 * scale,
                height: 1.1,
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.chat.isFavourite?.value ?? false)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: SvgPicture.asset(
                    'assets/svg/favourite.svg',
                    width: 14,
                    height: 14,
                  ),
                ),
              if (widget.chat.isMute?.value ?? false)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: SvgPicture.asset(
                    'assets/svg/notificationbell.svg',
                    width: 14,
                    height: 14,
                  ),
                ),
              if (widget.chat.unreadCount.value > 0)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: blueBack,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}
