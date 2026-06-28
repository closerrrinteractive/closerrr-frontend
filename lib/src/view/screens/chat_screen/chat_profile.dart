import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/constant_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/services/live_stream_service.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/view/popup/chat/report_popup.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/constant.dart';
import '../../../controller/user_information/user_info_controller.dart';
import '../../../models/chat/chat_model.dart';
import '../../../models/explore/get_influencer_response.dart';
import '../../widgets/custom_widgets/custom_button.dart';
import '../../widgets/specific_widgets/custom_setting_tile.dart';

class ChatProfile extends StatefulWidget {
  const ChatProfile({
    super.key,
    required this.profile,
    required this.closerDays,
    required this.chatId,
    this.chatUser,
    this.chat,
  });

  final UserProfile profile;
  final ChatUser? chatUser;
  final String closerDays;
  final int chatId;
  final ChatRowData? chat;

  @override
  State<ChatProfile> createState() => _ChatProfileState();
}

class _ChatProfileState extends State<ChatProfile> {
  final uiController = Get.find<UserInformationController>();
  final chatController = Get.find<ChatController>();
  final settingController = Get.find<SettingScreenController>();
  final isEdit = false.obs;
  final _descriptionController = TextEditingController();
  late ChatRowData chat;
  bool _chatResolved = false;
  bool _chatMissing = false;

  @override
  void initState() {
    super.initState();
    _resolveChat();
    _descriptionController.text = widget.chat?.groupDescription != null &&
            (widget.chat?.groupDescription ?? '').isNotEmpty
        ? widget.chat?.groupDescription ?? ''
        : Constants.bio;
  }

  Future<void> _resolveChat() async {
    ChatRowData? resolved =
        widget.chat ?? chatController.chats.firstWhereOrNull(
              (c) => c.id == widget.chatId,
            );
    if (resolved == null) {
      await chatController.getChats(page: 1);
      resolved = chatController.chats.firstWhereOrNull(
        (c) => c.id == widget.chatId,
      );
    }
    if (mounted) {
      setState(() {
        if (resolved != null) {
          chat = resolved;
          _chatMissing = false;
        } else {
          _chatMissing = true;
        }
        _chatResolved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_chatResolved) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }
    if (_chatMissing) {
      return Scaffold(
        body: Center(
          child: Text(
            'Could not load chat profile',
            style: CustomTextStyle.styledTextWidget.bodyMedium,
          ),
        ),
      );
    }

    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    widget.profile.username = widget.profile.fullname;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(widthScale),
            SizedBox(height: 1.h),
            _buildCloserDays(widthScale),
            SizedBox(height: 1.5.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Obx(() {
                final List<_ProfileOption> options = [
                  _ProfileOption(
                    icon: 'memories',
                    title: 'Memories',
                    onTap: () => context.pushNamed('chat_memories', extra: {
                      'chat_id': widget.chatId.toString(),
                    }),
                  ),
                  _ProfileOption(
                    icon: 'view_media',
                    title: 'View All Media',
                    onTap: () =>
                        context.pushNamed('profile_chat_media_screen', extra: {
                      'chat_id': widget.chatId,
                      'user': widget.chatUser,
                      'profile': widget.profile,
                      'chat': widget.chat,
                    }),
                  ),
                  _ProfileOption(
                    icon: 'events',
                    title: 'See Events',
                    onTap: () =>
                        context.pushNamed('chat_friends_events', extra: {
                      'chat_user': widget.chatUser?.toJson() ?? {},
                      'friend': Profile(
                        id: widget.profile.id ?? 0,
                        username: widget.profile.username ?? '',
                        profilePic: ApiStrings.imageUrl +
                            (widget.profile.profilePic ?? ''),
                      ),
                      'chat_id': widget.chatId,
                      'chat': widget.chat,
                    }),
                  ),
                  _ProfileOption(
                    icon: 'notificationbell',
                    title: 'Notifications',
                    onTap: () =>
                        context.pushNamed('chat_message_notifications', extra: {
                      'influencer_id': widget.profile.id ?? 0,
                    }),
                  ),
                  if (!uiController.isInfluencer.value)
                    _ProfileOption(
                      icon: 'chat_type',
                      title: chat.isFavourite?.value == true
                          ? 'Remove From Favorite Chats'
                          : 'Add To Favorite Chats',
                      onTap: _toggleFavourite,
                    ),
                  _ProfileOption(
                    icon: 'setting',
                    title: 'Chat Settings',
                    onTap: () => {
                      context.pushNamed('chat_setting', extra: {
                        'chat_id': widget.chatId,
                        'friend_id': widget.chatUser?.userId ?? 0,
                        'chat_user': widget.chatUser,
                        'profile': widget.profile,
                        'chat': widget.chat,
                      })
                    },
                  ),
                  if (uiController.isInfluencer.value)
                    _ProfileOption(
                      icon: 'manage_stories',
                      title: 'Manage Stories',
                      onTap: () {
                        print("damn!!!!");
                        print(chatController.storyData.isNotEmpty);
                        // if (chatController.storyData.isNotEmpty) {
                          final admin = Helpers.getAdmin(
                            users: chat.users,
                          );

                          context.go('/chat/story_screen', extra: {
                            'user': admin,
                            'chat_id': chat.id,
                            'chat': widget.chat,
                          });
                        // }
                      },
                    ),
                  if (uiController.isInfluencer.value)
                    _ProfileOption(
                        icon: 'start_closerrr_live',
                        title: 'Start Closerrr Live',
                        onTap: () async {
                          // intilize getStream.io and start the live stream
                          final data =
                              await LiveStreamService().startLivestream();

                          context.pushNamed("live_stream", extra: {
                            'call': data["call"],
                            'host': uiController.userData,
                            'id': data["id"],
                            'chat_id': chat.id
                          });
                        }),
                  if (!uiController.isInfluencer.value)
                    _ProfileOption(
                        icon: 'report',
                        title: 'Report ${widget.profile.username}',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ReportPopup(
                              user: widget.profile,
                            ),
                          );
                        }),
                ];
                chat.isFavourite!.value;
                return ListView.separated(
                  itemCount: options.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  separatorBuilder: (_, __) => SizedBox(height: 2.h),
                  itemBuilder: (_, index) {
                    final option = options[index];
                    return TabTiles(
                      padding: const EdgeInsets.only(),
                      icons: option.icon,
                      name: option.title,
                      setting: true,
                      onTap: option.onTap,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double widthScale) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Obx(() {
          isEdit.value;
          return GestureDetector(
            onTap: (chat.groupIcon?.value ?? widget.profile.profilePic ?? '')
                    .isNotEmpty
                ? () {
                    context.pushNamed('chat_image_preview_screen', extra: {
                      'imagesToPreview': [
                        ApiStrings.imageUrl +
                            (chat.groupIcon?.value ??
                                widget.profile.profilePic ??
                                '')
                      ],
                      'chatAdmin': widget.profile,
                      'chat': chat,
                      'isProfile': true,
                    });
                  }
                : () {},
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: CachedNetworkImage(
                imageUrl: ApiStrings.imageUrl +
                    (chat.groupIcon?.value ?? widget.profile.profilePic ?? ''),
                fit: BoxFit.cover,
                width: 100.w,
                errorWidget: (_, __, ___) => Image.asset(person),
              ),
            ),
          );
        }),
        Positioned(
          top: 56,
          left: 24,
          child: CustomIconButton(
            height: 48,
            width: 48,
            borderRadius: BorderRadius.circular(22),
            icon: Icons.arrow_back_rounded,
            svgSize: 20,
            onTap: () => context.pop(),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 40.h),
            Obx(() => Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 2,
                        color: blackColor.withOpacity(0.2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              final friendNameVal = widget.chatUser?.friendName?.value;
                              final groupNameVal = chat.groupName?.value;
                              return Text(
                                uiController.isInfluencer.value
                                    ? (groupNameVal != null && groupNameVal.isNotEmpty
                                        ? groupNameVal
                                        : widget.profile.fullname ?? widget.profile.username ?? '')
                                    : (friendNameVal != null && friendNameVal.isNotEmpty)
                                        ? friendNameVal
                                        : (groupNameVal != null && groupNameVal.isNotEmpty)
                                            ? groupNameVal
                                            : widget.profile.fullname ?? widget.profile.username ?? '',
                                style: CustomTextStyle
                                    .styledTextWidget.bodyLarge!
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: (widthScale * kTextFormFactor) * 24,
                                ),
                              );
                            }),
                            SizedBox(height: 1.h),
                            CustomTextFormField(
                              hintText: 'Bio',
                              controller: _descriptionController,
                              borderColor: whiteColor,
                              // fillColor: blueBack,
                              textFieldPadding: const EdgeInsets.all(0),
                              isMaxLine: 4,
                              fieldReadOnly: !isEdit.value,
                              style: CustomTextStyle
                                  .styledTextWidget.labelMedium!
                                  .copyWith(
                                fontWeight: FontWeight.w600,
                                color: blackColor,
                                fontSize: (widthScale * kTextFormFactor) * 14,
                              ),
                            ),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                      if (isEdit.value) ...{
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    isEdit.value = false;
                                  },
                                  child: SvgPicture.asset(
                                    crossProfileIcon,
                                    height: 28,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (_descriptionController.text
                                        .contains(Constants.bio)) {
                                      Helpers.toast('Please Add your bio!');
                                      return;
                                    }
                                    await chatController
                                        .updateChatSettings(
                                      chatId: widget.chatId,
                                      groupDescription:
                                          _descriptionController.text,
                                    )
                                        .then((value) {
                                      widget.chat?.groupDescription =
                                          _descriptionController.text;
                                      return isEdit.value = false;
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    checkProfileIcon,
                                    height: 28,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      } else if (uiController.isInfluencer.value)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              isEdit.value = true;
                            },
                            child: Image.asset(
                              editPngIcon,
                              height: 28,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildCloserDays(double widthScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/svg/hand_shake.svg', height: 24),
        SizedBox(width: 1.w),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Closerrr For ',
                style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: (widthScale * kTextFormFactor) * 16,
                  fontFamily: 'Hellix',
                ),
              ),
              TextSpan(
                text: '${widget.closerDays} ',
                style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: (widthScale * kTextFormFactor) * 16,
                ),
              ),
              TextSpan(
                text: 'Days',
                style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: (widthScale * kTextFormFactor) * 16,
                  fontFamily: 'Hellix',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavourite() async {
    chat.isFavourite?.toggle();
    await chatController.addAndRemoveFavouriteChat(chatId: chat.id);

    Helpers.toast(
      chat.isFavourite?.value == true
          ? "Added to favourites"
          : "Removed from favourites",
    );

    sortAllChatsByFavorite();
  }

  void sortAllChatsByFavorite() {
    final sortedChats = [...chatController.chats];
    sortedChats.sort((a, b) {
      final aFav = a.isFavourite?.value ?? false;
      final bFav = b.isFavourite?.value ?? false;
      return aFav == bFav ? 0 : (aFav ? -1 : 1);
    });
    chatController.chats.assignAll(sortedChats);
  }
}

/// Helper model for cleaner list building
class _ProfileOption {
  final String icon;
  final String title;
  final VoidCallback? onTap;

  _ProfileOption({required this.icon, required this.title, this.onTap});
}
