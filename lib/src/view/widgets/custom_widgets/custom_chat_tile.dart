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
        padding: EdgeInsets.only(bottom: 2.5.h),
        margin: EdgeInsets.only(bottom: 2.5.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: textColor.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Column(
              children: [
                _buildAvatar(widthScale),
                Obx(() {
                  RxList<LiveStreamM>? liveStreams =
                      chatAdmin.value?.liveStreams;
                  if (liveStreams?.isNotEmpty == true) {
                    return TextButton(
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
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
              ],
            ),
            SizedBox(width: 4.w),
            _buildChatInfo(widthScale),
            const Spacer(),
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
                radius: 30,
                spacing: 15,
                strokeWidth: 4,
                indexOfSeenStatus: widget.chat.unreadCount.value,
                numberOfStatus: widget.chat.storyCount.value,
                padding: widget.chat.storyCount.value != 0 ? 5 : 2,
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50.w,
            child: Text(
              (loggedInUser.value?.chatUser.friendName?.value != null &&
                      loggedInUser.value!.chatUser.friendName!.value.isNotEmpty)
                  ? loggedInUser.value!.chatUser.friendName!.value
                  : groupName?.value ??
                      profile?.fullname ??
                      profile?.username ??
                      "no name",
              //     +
              // (chatAdmin.value?.id.toString() == userId.value
              //     ? ' (Broadcast)'
              //     : ''),
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                color: blackColor,
                fontSize: (widthScale * kTextFormFactor) * 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 45.w,
            child: Text(
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
              style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                color: textColor,
                fontSize: (widthScale * kTextFormFactor) * 12.63,
                fontWeight: FontWeight.w100,
              ),
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
      final createdAt =
          time != null ? DateFormat('hh:mm').format(time.value) : "";

      return Column(
        children: [
          if (widget.chat.unreadCount.value > 0)
            const CircleAvatar(
              backgroundColor: blueBack,
              radius: 7,
              child: SizedBox(),
              // child: Text(
              //   widget.chat.unreadCount.value.toString(),
              //   style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
              //     color: whiteColor,
              //     fontSize: (widthScale * kTextFormFactor) * 12.63,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
            ),
          SizedBox(height: 2.w),
          if (time != null)
            Text(
              createdAt.toString(),
              style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                color: textColor.withOpacity(0.6),
                fontWeight: FontWeight.w100,
                fontSize: (widthScale * kTextFormFactor) * 14,
              ),
            ),
          SizedBox(height: 1.w),
          Row(
            children: [
              if (widget.chat.isFavourite?.value ?? false) ...{
                SvgPicture.asset('assets/svg/favourite.svg'),
              },
              SizedBox(width: 1.w),
              if (widget.chat.isMute?.value ?? false) ...{
                SvgPicture.asset('assets/svg/notification.svg'),
              },
            ],
          ),
        ],
      );
    });
  }
}
