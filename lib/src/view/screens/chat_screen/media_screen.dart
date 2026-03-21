import 'dart:typed_data';

import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/models/chat/chat_media_model.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_square_shimmer.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../../models/chat/chat_model.dart';
import '../../widgets/specific_widgets/chat/custom_no_chat.dart';

class ChatMediaScreen extends StatefulWidget {
  const ChatMediaScreen({
    super.key,
    this.chatUser,
    this.profile,
    this.chat,
    required this.chatId,
    required this.navigationShell,
  });
  final int chatId;
  final ChatUser? chatUser;
  final UserProfile? profile;
  final ChatRowData? chat;
  final StatefulNavigationShell navigationShell;

  @override
  State<ChatMediaScreen> createState() => _ChatMediaScreenState();
}

class _ChatMediaScreenState extends State<ChatMediaScreen> {
  ChatController chatController = Get.find();
  final Map<int, Map<String, dynamic>> videoThumbnails = {};
  final isLoadingThumbs = false.obs;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final activeTab = chatController.selectedSection.value;
    await chatController.getChatMedia(
      page: 1,
      limit: 10,
      mediaType: (activeTab == 'Photos'
              ? 'image'
              : activeTab == 'Videos'
                  ? 'video'
                  : 'audio')
          .toLowerCase(),
      chatId: widget.chatId,
    );
    if (chatController.selectedSection.value == 'Videos') {
      await _preloadVideoThumbnails();
    }
  }

  Future<void> _preloadVideoThumbnails() async {
    isLoadingThumbs.value = true;
    final mediaList = chatController.chatMedia.value.first.rows
        .where((e) => e.category == 'video')
        .toList();
    for (var media in mediaList) {
      try {
        final details = await Helpers.getVideoDetails(
          ApiStrings.s3ImageUrl + media.path,
        );
        videoThumbnails[media.id] = details;
      } catch (e) {
        debugPrint('Error loading thumbnail: $e');
      }
    }
    isLoadingThumbs.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      appBar: ChatAppBar(isMediaScreen: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaTabs(widthScale),
              SizedBox(height: 2.h),
              Obx(() {
                if (chatController.chatMediaCount.value == 0) {
                  return SizedBox(
                    height: 60.h,
                    child: CustomNoChat(
                      isChat: false,
                      title: 'Sorry! No content Found',
                      subtitle: 'Your Friend Will Share Something Soon!',
                      navigationShell: widget.navigationShell,
                    ),
                  );
                } else {
                  return _buildMediaViewCard(widthScale);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTabs(double widthScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        3,
        (index) => GestureDetector(
          onTap: () async {
            chatController.selectedSection.value = mediaType[index];
            await chatController.getChatMedia(
              page: 1,
              limit: 10,
              mediaType: ['image', 'video', 'audio'][index],
              chatId: widget.chatId,
            );
            if (chatController.selectedSection.value == 'Videos') {
              await _preloadVideoThumbnails();
            }
          },
          child: Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  chatController.selectedSection.value == mediaType[index]
                      ? 10
                      : 8,
                ),
                color: chatController.selectedSection.value == mediaType[index]
                    ? primaryColor
                    : whiteColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: blackColor.withOpacity(0.2),
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/${['image', 'video', 'audio'][index]}.svg',
                    color:
                        chatController.selectedSection.value == mediaType[index]
                            ? whiteColor
                            : headingColor,
                    height: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    mediaType[index],
                    style:
                        CustomTextStyle.styledTextWidget.labelLarge?.copyWith(
                      color: chatController.selectedSection.value ==
                              mediaType[index]
                          ? whiteColor
                          : headingColor,
                      fontWeight: chatController.selectedSection.value ==
                              mediaType[index]
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: chatController.selectedSection.value ==
                              mediaType[index]
                          ? (widthScale * kTextFormFactor) * 20
                          : (widthScale * kTextFormFactor) * 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaViewCard(double widthScale) {
    final mediaByDate = <String, List<MediaRow>>{};
    if (chatController.chatMedia.isEmpty) {
      return SizedBox(
        height: 60.h,
        child: Center(
          child: Text('No ${chatController.selectedSection.value} found'),
        ),
      );
    }

    for (var media in chatController.chatMedia.value.first.rows) {
      final date = DateFormat('MMMM dd, yyyy').format(media.createdAt);
      mediaByDate.putIfAbsent(date, () => []).add(media);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mediaByDate.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                color: headingColor,
                fontWeight: FontWeight.bold,
                fontSize: (widthScale * kTextFormFactor) * 16,
              ),
            ),
            SizedBox(height: 1.h),
            Obx(() {
              isLoadingThumbs.value;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 1 / 1,
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) {
                  final media = entry.value[index];
                  if (media.category == 'image') {
                    return GestureDetector(
                      onTap: () => mediaOnTap(media),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ApiStrings.s3ImageUrl + media.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: backScreenColor),
                        ),
                      ),
                    );
                  }

                  if (media.category == 'audio') {
                    return GestureDetector(
                      onTap: () => mediaOnTap(media),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: backScreenColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: primaryColor.withOpacity(0.05),
                              backgroundImage: NetworkImage(
                                ApiStrings.imageUrl +
                                    (widget.chat?.groupIcon?.value ??
                                        widget.profile?.profilePic ??
                                        ''),
                              ),
                              onBackgroundImageError: (exception, stackTrace) =>
                                  const AssetImage(
                                person,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  Helpers.formatDuration(
                                      media.audioPlayer.value.duration ??
                                          const Duration(seconds: 0)),
                                  style: CustomTextStyle
                                      .styledTextWidget.labelSmall
                                      ?.copyWith(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        (widthScale * kTextFormFactor) * 8,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: SvgPicture.asset(
                                audioIcon,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // VIDEO
                  final details = videoThumbnails[media.id];
                  if (isLoadingThumbs.value && details == null) {
                    return const SquareShimmer();
                  }

                  if (details == null) {
                    return _buildErrorVideoBox();
                  }

                  return GestureDetector(
                    onTap: () => mediaOnTap(media),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: Image.memory(
                                  details['thumb'] as Uint8List,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ).image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ).animate().fadeIn(),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              details['duration'] ?? "",
                              style: CustomTextStyle.styledTextWidget.labelSmall
                                  ?.copyWith(
                                color: whiteColor,
                                fontSize: (widthScale * kTextFormFactor) * 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }),
            SizedBox(height: 2.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildErrorVideoBox() {
    return Container(
      height: 14.h,
      width: 14.h,
      color: primaryColor.withOpacity(0.05),
      child: const Center(
        child: Icon(Icons.error, size: 32, color: Colors.red),
      ),
    );
  }

  void mediaOnTap(MediaRow media) {
    chatController.mediaActiveIndex.value = media.id;
    context.pushNamed(
      'media_view_screen',
      extra: {
        'type': chatController.selectedSection.value,
        'media': media,
        'media_list': chatController.chatMedia.value,
        'user': widget.chatUser,
        'profile': widget.profile,
        'chat': widget.chat,
      },
    );
  }
}
