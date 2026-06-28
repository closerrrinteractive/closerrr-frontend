// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/config/helpers.dart';
import '../../../../../core/config/haptic_helper.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/themes/text_style.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/debug_log.dart';
import '../../../../../core/utils/img_string.dart';
import '../../../../controller/chat/chat_controller.dart';
import '../../../../controller/routing/routing_controller.dart';
import '../../../../models/chat/chat_model.dart';
import '../../../popup/chat/chat_control.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_formfield.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? isMediaScreen;
  final bool? isMediaView;
  final bool? isChatMessageView;
  final bool? isChatSetting;
  final String? chatTitle;
  final RxString? chatName;
  final RxString? chatIcon;
  final int? closerDays;
  final Function()? profileTap;
  final UserProfile? chatAdmin;
  final ChatUser? loggedInUser;
  final String? isAdmin;
  final dynamic chatId;
  final Function()? controlTap;
  final Function()? backTap;
  final ChatRowData? chat;
  final bool? isEventPreview;
  final String? eventName;
  final String? eventTime;
  final String? influencerProfilePic;
  Function()? buildMessage = () {};

  ChatAppBar({
    super.key,
    this.isMediaScreen,
    this.isMediaView,
    this.isChatMessageView,
    this.isChatSetting,
    this.chatTitle,
    this.chatName,
    this.chatIcon,
    this.closerDays,
    this.profileTap,
    this.chatAdmin,
    this.loggedInUser,
    this.isAdmin,
    this.chatId,
    this.controlTap,
    this.backTap,
    this.buildMessage,
    this.chat,
    this.isEventPreview,
    this.eventName,
    this.eventTime,
    this.influencerProfilePic,
  });

  ChatController chatController = Get.find<ChatController>();
  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    Timer? debounce;

    return AppBar(
      toolbarHeight: 10.h,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      backgroundColor: whiteColor,
      shadowColor: blueBack.withOpacity(0.1),
      title: Obx(
        () {
          if (chatController.isChatMessageSearching.value) {
            return _buildSearchTitle(widthScale, debounce);
          }
          if (isChatMessageView == true) {
            return _buildChatMessageTitle(context, widthScale);
          }
          return _buildDefaultTitle(widthScale, context);
        },
      ),
      surfaceTintColor: transparentColor,
      elevation: 12,
    );
  }

  Widget _buildChatMessageTitle(BuildContext context, double widthScale) {
    final customFriendName = loggedInUser?.friendName?.value;
    final adminUser = chat != null ? Helpers.getAdmin(users: chat!.users) : null;
    final creatorChatName = adminUser?.chatUser.nickname?.toString();
    final defaultName = (chatName?.value != null && chatName!.value.isNotEmpty)
        ? chatName!.value
        : chatAdmin?.fullname ?? chatAdmin?.username ?? 'Chat';

    final displayName = (customFriendName != null && customFriendName.isNotEmpty)
        ? customFriendName
        : (creatorChatName != null && creatorChatName.isNotEmpty)
            ? creatorChatName
            : defaultName;

    // #region agent log
    DebugLog.write(
      location: 'chat_app_bar.dart:_buildChatMessageTitle',
      message: 'chat message app bar render',
      hypothesisId: 'B',
      data: {
        'displayName': displayName,
        'hasAdminProfile': chatAdmin != null,
        'hasChatIcon': (chatIcon?.value ?? '').isNotEmpty,
        'closerDays': closerDays,
      },
    );
    // #endregion

    return Row(
      children: [
        InkWell(
          onTap: () {
            HapticHelper.trigger(type: HapticFeedbackType.light);
            RouterController.current.pop();
          },
          child: Image.asset(backIcon, height: 3.h),
        ),
        SizedBox(width: 2.w),
        GestureDetector(
          onTap: profileTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: _buildProfileAvatar(chatIcon, chatAdmin),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: GestureDetector(
            onTap: profileTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: CustomTextStyle.styledTextWidget.labelLarge?.copyWith(
                    color: primaryColor,
                    fontSize: (widthScale * kTextFormFactor) * 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svg/hand_shake.svg',
                      height: 14,
                    ),
                    SizedBox(width: 1.w),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Closerrr For ',
                            style: CustomTextStyle.styledTextWidget.labelSmall
                                ?.copyWith(
                              color: headingColor,
                              fontSize: (widthScale * kTextFormFactor) * 10,
                            ),
                          ),
                          TextSpan(
                            text: closerDays.toString(),
                            style: CustomTextStyle.styledTextWidget.labelSmall
                                ?.copyWith(
                              color: headingColor,
                              fontSize: (widthScale * kTextFormFactor) * 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' Days',
                            style: CustomTextStyle.styledTextWidget.labelSmall
                                ?.copyWith(
                              color: headingColor,
                              fontSize: (widthScale * kTextFormFactor) * 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        CustomIconButton(
          height: 42,
          width: 42,
          borderRadius: BorderRadius.circular(18),
          svg: 'assets/svg/search.svg',
          padding: const EdgeInsets.all(10),
          onTap: () {
            chatController.isChatMessageSearching.value = true;
            chatController.searchInputFieldFocusNode.requestFocus();
          },
        ),
        SizedBox(width: 2.w),
        CustomIconButton(
          height: 42,
          width: 42,
          borderRadius: BorderRadius.circular(18),
          svg: 'assets/svg/chat_control.svg',
          padding: const EdgeInsets.all(10),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => ChatControls(
                ctx: ctx,
                chatAdmin: chatAdmin,
                loggedInUser: loggedInUser,
                closerDays: closerDays ?? 0,
                chatId: chatId,
                chat: chat,
              ),
            ).then((value) {
              if (value != null) {
                loggedInUser?.chatBackground = value.toString();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchTitle(double widthScale, Timer? debounce) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            HapticHelper.trigger(type: HapticFeedbackType.light);
            chatController.isChatMessageSearching.value = false;
            chatController.searchController.clear();
          },
          child: Image(
            image: const AssetImage(crossIcon),
            height: 5.5.h,
          ),
        ),
        Expanded(
          child: CustomTextFormField(
            hintText: 'Search Chat',
            focusNode: chatController.searchInputFieldFocusNode,
            fillColor: blueBack.withOpacity(0.1),
            controller: chatController.searchController,
            hintStyle: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
              fontSize: (widthScale * kTextFormFactor) * 12,
              color: primaryColor.withOpacity(0.6),
            ),
            style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
              fontSize: (widthScale * kTextFormFactor) * 12,
              color: primaryColor,
            ),
            isBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            borderColor: whiteColor,
            radius: 24,
            onChanged: (value) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 800), () {
                chatController
                    .getChatMessages(
                      search: chatController.searchController.text,
                      chatId: chatId,
                    )
                    .then((value) => buildMessage!());
              });
            },
          ),
        ),
        InkWell(
          onTap: () {},
          child: Image(
            image: const AssetImage(searchIcon),
            height: 5.5.h,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultTitle(double widthScale, BuildContext context) {
    final showBack = (isMediaScreen == true) ||
        (isChatMessageView == true) ||
        (isChatSetting == true);
    final showMediaTitle =
        (isMediaScreen == true) || (isChatSetting == true);
    final showAvatar =
        (isChatSetting != true) && (isMediaScreen != true);
    final showMediaMeta =
        (isMediaView == true) || (isChatMessageView == true);

    return Row(
      children: [
        if (isChatSetting == true)
          InkWell(
            onTap: () {
              HapticHelper.trigger(type: HapticFeedbackType.light);
              if (backTap != null) {
                backTap!();
              } else {
                RouterController.current.pop();
              }
            },
            overlayColor: const WidgetStatePropertyAll(transparentColor),
            child: Image(
              image: const AssetImage(backIcon),
              height: 5.5.h,
            ),
          ),
        if (showBack && isChatSetting != true)
          InkWell(
            onTap: () {
              HapticHelper.trigger(type: HapticFeedbackType.light);
              RouterController.current.pop();
            },
            overlayColor: const WidgetStatePropertyAll(transparentColor),
            child: Image(
              image: const AssetImage(backIcon),
              height: 3.h,
            ),
          ),
        if (showMediaTitle) ...{
          SizedBox(width: 1.w),
          Text(
            chatTitle ?? 'All Media',
            style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
              color: primaryColor,
              fontSize: (widthScale * kTextFormFactor) * 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        },
        if (showAvatar) ...{
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: profileTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: _buildProfileAvatar(chatIcon, chatAdmin),
            ),
          ),
        },
        if (showMediaMeta && isChatMessageView != true) ...{
          SizedBox(width: 2.w),
          Expanded(
            child: GestureDetector(
              onTap: profileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEventPreview == true
                        ? (eventName ?? '')
                        : (chatName?.value != null && chatName!.value.isNotEmpty)
                            ? chatName!.value
                            : chatAdmin?.fullname ??
                                chatAdmin?.username ??
                                'NA',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: CustomTextStyle.styledTextWidget.labelLarge?.copyWith(
                      color: primaryColor,
                      fontSize: (widthScale * kTextFormFactor) * 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isEventPreview == true
                        ? (eventTime ?? '')
                        : DateFormat('dd MMMM, yyyy | hh:mm:aa').format(DateTime.now()),
                    style: CustomTextStyle.styledTextWidget.labelSmall?.copyWith(
                      color: headingColor,
                      fontSize: (widthScale * kTextFormFactor) * 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isEventPreview == true) ...[
            InkWell(
              onTap: controlTap,
              child: SvgPicture.asset(
                picoptionsSvgIcon,
                height: 5.5.h,
                width: 5.5.h,
              ),
            ),
          ] else ...[
            CustomIconButton(
              height: 42,
              width: 42,
              borderRadius: BorderRadius.circular(18),
              svg: 'assets/svg/chat_control.svg',
              padding: const EdgeInsets.all(10),
              onTap: controlTap ??
                  () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ChatControls(
                        ctx: ctx,
                        closerDays: 0,
                        chat: chat,
                        chatAdmin: chatAdmin,
                        loggedInUser: loggedInUser,
                        chatId: chatId,
                      ),
                    );
                  },
            ),
          ],
          SizedBox(width: 1.w),
          InkWell(
            onTap: () {
              HapticHelper.trigger(type: HapticFeedbackType.light);
              RouterController.current.pop();
            },
            child: SvgPicture.asset(
              isEventPreview == true ? piccrossSvgIcon : icrossSvgIcon,
              height: 5.5.h,
              width: 5.5.h,
            ),
          ),
        },
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(10.h);

  Widget _buildProfileAvatar(RxString? chatIcon, UserProfile? chatAdmin) {
    if (isEventPreview == true) {
      final pic = influencerProfilePic;
      if (pic == null || pic.isEmpty) {
        return Image.asset(person, height: 50, width: 50, fit: BoxFit.cover);
      }
      return CachedNetworkImage(
        imageUrl: pic.contains('http') ? pic : ApiStrings.imageUrl + pic,
        height: 50,
        fit: BoxFit.cover,
        width: 50,
        errorWidget: (context, url, error) {
          return Image.asset(person, height: 50, width: 50, fit: BoxFit.cover);
        },
      );
    }
    final pic = chatIcon?.value ?? chatAdmin?.profilePic;
    if (pic == null || pic.toString().isEmpty) {
      return Image.asset(person, height: 40, width: 40, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: ApiStrings.imageUrl + pic.toString(),
      height: 40,
      fit: BoxFit.cover,
      width: 40,
      errorWidget: (context, url, error) {
        return Image.asset(person, height: 40, width: 40, fit: BoxFit.cover);
      },
    );
  }
}
