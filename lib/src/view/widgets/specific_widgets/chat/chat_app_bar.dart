// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/themes/text_style.dart';
import '../../../../../core/utils/constant.dart';
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
  });

  ChatController chatController = Get.find<ChatController>();
  // final FocusNode _focusNode = FocusNode();
  final name = ''.obs;
  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    Timer? debounce;

    return AppBar(
      toolbarHeight: 10.h,
      leadingWidth: 0,
      leading: Container(),
      backgroundColor: whiteColor,
      shadowColor: blueBack.withOpacity(0.1),
      title: Obx(
        () => chatController.isChatMessageSearching.value
            ? Row(
                children: [
                  InkWell(
                    onTap: () {
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
                      hintStyle: CustomTextStyle.styledTextWidget.labelMedium!
                          .copyWith(
                        fontSize: (widthScale * kTextFormFactor) * 12,
                        color: primaryColor.withOpacity(0.6),
                      ),
                      style: CustomTextStyle.styledTextWidget.labelMedium!
                          .copyWith(
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
                    onTap: () {
                      // chatController.isChatMessageSearching.value = false;
                      // chatController.searchController.clear();
                    },
                    child: Image(
                      image: const AssetImage(searchIcon),
                      height: 5.5.h,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  if (isChatSetting ?? false) ...{
                    InkWell(
                      onTap: backTap ?? () => RouterController.current.pop(),
                      overlayColor:
                          const WidgetStatePropertyAll(transparentColor),
                      child: Image(
                        image: const AssetImage(backIcon),
                        height: 5.5.h,
                      ),
                    ),
                  },
                  if (isMediaScreen ??
                      false ||
                          (isChatMessageView ?? false) ||
                          (isChatSetting ?? false)) ...{
                    if (!(isChatSetting ?? false))
                      InkWell(
                        onTap: () => RouterController.current.pop(),
                        overlayColor:
                            const WidgetStatePropertyAll(transparentColor),
                        child: Image(
                          image: const AssetImage(
                            backIcon,
                          ),
                          height: 3.h,
                        ),
                      ),
                    if (isMediaScreen ?? false || (isChatSetting ?? false)) ...{
                      SizedBox(width: 1.w),
                      Text(
                        chatTitle ?? 'All Media',
                        style: CustomTextStyle.styledTextWidget.bodyLarge
                            ?.copyWith(
                          color: primaryColor,
                          fontSize: (widthScale * kTextFormFactor) * 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    },
                  },
                  if (!(isChatSetting ?? false) &&
                      !(isMediaScreen ?? false)) ...{
                    SizedBox(width: 1.w),
                    Obx(() {
                      // Do not remove this becuase this will be use if chatIcon is null
                      return GestureDetector(
                        onTap: profileTap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: ApiStrings.imageUrl +
                                (chatIcon?.value ??
                                    chatAdmin?.profilePic ??
                                    ''),
                            height: 40,
                            fit: BoxFit.cover,
                            width: 40,
                            errorWidget: (context, url, error) {
                              return Image.asset(person);
                            },
                          ),
                        ),
                      );
                    }),
                  },
                  if (isMediaView ?? false || (isChatMessageView ?? false)) ...{
                    SizedBox(width: 2.w),
                    Expanded(
                      flex: 6,
                      child: GestureDetector(
                        onTap: profileTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              // Do not remove this becuase this will be use if ChatName is null
                              name.value;
                              return Text(
                                "${(loggedInUser?.friendName?.value != null && loggedInUser!.friendName!.value.isNotEmpty) ? loggedInUser?.friendName?.value : chatName?.value ?? chatAdmin?.fullname ?? chatAdmin?.username ?? 'NA'} ${isAdmin ?? ''}",
                                overflow: TextOverflow.ellipsis,
                                style: CustomTextStyle
                                    .styledTextWidget.labelLarge
                                    ?.copyWith(
                                  color: primaryColor,
                                  fontSize: (widthScale * kTextFormFactor) * 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                            if (isChatMessageView ?? false) ...{
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/hand_shake.svg',
                                    height: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  RichText(
                                    text: TextSpan(text: '', children: [
                                      TextSpan(
                                        text: 'Closerrr For ',
                                        style: CustomTextStyle
                                            .styledTextWidget.labelSmall
                                            ?.copyWith(
                                          color: headingColor,
                                          fontSize:
                                              (widthScale * kTextFormFactor) *
                                                  10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: closerDays.toString(),
                                        style: CustomTextStyle
                                            .styledTextWidget.labelSmall
                                            ?.copyWith(
                                          color: headingColor,
                                          fontSize:
                                              (widthScale * kTextFormFactor) *
                                                  10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Days',
                                        style: CustomTextStyle
                                            .styledTextWidget.labelSmall
                                            ?.copyWith(
                                          color: headingColor,
                                          fontSize:
                                              (widthScale * kTextFormFactor) *
                                                  10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ]),
                                  )
                                ],
                              )
                            } else ...{
                              Text(
                                DateFormat('dd MMMM, yyyy | hh:mm:aa')
                                    .format(DateTime.now())
                                    .toString(),
                                style: CustomTextStyle
                                    .styledTextWidget.labelSmall
                                    ?.copyWith(
                                  color: headingColor,
                                  fontSize: (widthScale * kTextFormFactor) * 12,
                                ),
                              )
                            },
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isChatMessageView ?? false) ...{
                      CustomIconButton(
                        height: 42,
                        width: 42,
                        borderRadius: BorderRadius.circular(18),
                        svg: 'assets/svg/search.svg',
                        padding: const EdgeInsets.all(10),
                        onTap: () {
                          chatController.isChatMessageSearching.value = true;
                          // chatController.searchController.
                          chatController.searchInputFieldFocusNode
                              .requestFocus();
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
                          return showDialog(
                            context: context,
                            builder: (ctx) => ChatControls(
                              ctx: context,
                              chatAdmin: chatAdmin,
                              loggedInUser: loggedInUser,
                              closerDays: closerDays ?? 0,
                              chatId: chatId,
                              chat: chat,
                            ),
                          ).then((value) {
                            loggedInUser?.chatBackground = value.toString();
                          });
                        },
                      ),
                    } else ...{
                      CustomIconButton(
                          height: 42,
                          width: 42,
                          borderRadius: BorderRadius.circular(18),
                          svg: 'assets/svg/chat_control.svg',
                          padding: const EdgeInsets.all(10),
                          onTap: controlTap ??
                              () {
                                return showDialog(
                                    context: context,
                                    builder: (ctx) => ChatControls(
                                          ctx: context,
                                          closerDays: 0,
                                          chat: chat,
                                          chatAdmin: chatAdmin,
                                          loggedInUser: loggedInUser,
                                          chatId: chatId,
                                        ));
                              }),
                      SizedBox(width: 1.w),
                      InkWell(
                        onTap: () => RouterController.current.pop(),
                        child: Image(
                          image: const AssetImage(
                            crossIcon,
                          ),
                          height: 5.5.h,
                        ),
                      ),
                    },
                  },
                ],
              ),
      ),
      surfaceTintColor: transparentColor,
      elevation: 12,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(8.h);
}
