import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:closerrr/src/models/chat/story/story_model.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:story_view/story_view.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/themes/text_style.dart';
import '../../../../controller/chat/chat_controller.dart';
import '../../../popup/chat/story_popup.dart';
import '../../../widgets/custom_widgets/custom_text_formfield.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    required this.user,
    required this.chatId,
    this.chat,
  });
  final UserData user;
  final ChatRowData? chat;
  final int chatId;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with WidgetsBindingObserver {
  final ChatController chatController = Get.find();
  final UserInformationController uiController = Get.find();
  final TextEditingController storyTextController = TextEditingController();
  final StoryController storyController = StoryController();
  final FocusNode _focus = FocusNode();

  final RxString media = ''.obs;
  final RxInt storyId = 0.obs;
  final RxBool isLoading = false.obs;
  final loadStory = false.obs;

  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    _fetchStory();
  }

  _fetchStory() async {
    chatController.isStoryLoading.value = true;
    chatController.storyData.value.clear();
    loadStory.value = true;
    await chatController
        .getStory(userId: widget.user.chatUser.userId)
        .then((value) {
      loadStory.value = false;
    });

    _focus.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      storyController.pause();
    } else {
      storyController.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    storyTextController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset == 0 && _keyboardHeight != 0) {
      _focus.unfocus();
      storyController.play();
    }
    _keyboardHeight = bottomInset;
  }

  void _updateUnreadCount(dynamic story, int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatController.storyData.isNotEmpty) {
        final currentStory = chatController.storyData.first.stories[index];
        media.value = currentStory.mediaPath ?? '';
        storyId.value = currentStory.id;

        final chat = chatController.chats.firstWhere(
          (c) => c.id == widget.chatId,
          orElse: () => null as dynamic,
        );
        chatController.storyIndex.value = index;
        if (chat.unreadCount.value < (index + 1)) {
          chat.unreadCount.value = index + 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Scaffold(
      backgroundColor: blackColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Container(
                  height: 100.h,
                  width: 100.w,
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Obx(() {
                    if (chatController.isStoryLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (chatController.storyData.value.isEmpty) {
                      return Center(
                          child: Text(
                        "No story found",
                        style: CustomTextStyle.styledTextWidget.headlineLarge
                            ?.copyWith(color: whiteColor),
                      ));
                    }

                    return StoryView(
                      inline: true,
                      indicatorOuterPadding: const EdgeInsets.all(16),
                      indicatorColor: whiteColor.withOpacity(0.7),
                      indicatorForegroundColor: primaryColor,
                      indicatorHeight: IndicatorHeight.medium,
                      onComplete: () {
                        context.pop();
                      },
                      onStoryShow: _updateUnreadCount,
                      onVerticalSwipeComplete: (value) {
                        _focus.requestFocus();
                      },
                      repeat: false,
                      storyItems: chatController.storyData.value.first.stories
                          .map((story) {
                        if (story.mediaType == 'image' &&
                            story.mediaPath != null) {
                          return StoryItem.pageProviderImage(
                            CachedNetworkImageProvider(
                              ApiStrings.imageUrl + story.mediaPath!,
                            ),
                            duration: const Duration(seconds: 10),
                            caption: story.text ?? '',
                          );
                        } else if (story.mediaType == 'text') {
                          return StoryItem.text(
                            title: story.text ?? '',
                            backgroundColor: Colors.black,
                          );
                        }
                        return StoryItem.text(
                            title: '', backgroundColor: Colors.black);
                      }).toList(),
                      controller: storyController,
                    );
                  }),
                ),
              ),
            ),
            _buildTopBar(widthScale, chatController.storyData.value.isNotEmpty),
            if (_focus.hasFocus)
              GestureDetector(
                onTap: () => _focus.unfocus(),
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  color: blackColor.withOpacity(0.4),
                ),
              ),
            _buildBottomBar(widthScale),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double widthScale, [bool storyExits = false]) {
    return Positioned(
      top: 35,
      left: 10,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            topLeft: Radius.circular(28),
          ),
          gradient: LinearGradient(
            colors: [
              primaryColor,
              transparentColor,
            ],
          ),
        ),
        width: 95.w,
        child: Row(
          children: [
            _buildUserAvatar(),
            SizedBox(width: 2.w),
            _buildUserInfo(),
            const Spacer(),
            if (storyExits) _buildStoryPopupButton(),
            SizedBox(width: 2.w),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: whiteColor),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(
          ApiStrings.imageUrl +
              (widget.chat?.groupIcon?.value ??
                  widget.user.profile?.profilePic ??
                  ''),
        ),
        onBackgroundImageError: (_, __) => Image.asset(person),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Obx(() {
      if (chatController.storyData.isEmpty) return const SizedBox.shrink();
      final firstStory = chatController.storyData.value.first.stories.first;
      final duration = DateTime.now().difference(firstStory.createdAt);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.user.profile?.username ?? '',
            style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
              color: whiteColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            Helpers.getDuration(duration),
            style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
              color: whiteColor,
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStoryPopupButton() {
    return GestureDetector(
      onTap: () {
        storyController.pause();
        showDialog(
          context: context,
          builder: (_) => StoryPopup(
            media: media.value,
            storyId: storyId.value,
            chatId: widget.chatId,
          ),
        ).then((_) => storyController.play());
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(width: 1, color: primaryColor.withOpacity(0.4)),
        ),
        child: SvgPicture.asset('assets/svg/controls.svg'),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(width: 1, color: primaryColor.withOpacity(0.4)),
        ),
        child: SvgPicture.asset(
          'assets/svg/search_close.svg',
          height: 14,
        ),
      ),
    );
  }

  Widget _buildBottomBar(double widthScale) {
    return Obx(() {
      return Container(
        height: 80,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: uiController.isInfluencer.value
                  ? _buildInfluencerControls(widthScale)
                  : _buildUserReplyControls(),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      );
    });
  }

  List<Widget> _buildInfluencerControls(double widthScale) {
    // if (chatController.storyData.isEmpty ||
    //     chatController.storyData.first.stories.isEmpty) {
    //   return [];
    // }
    Story? story;
    if (chatController.storyData.isNotEmpty) {
      story = chatController
          .storyData.first.stories[chatController.storyIndex.value];
    }

    return [
      GestureDetector(
        onTap: _pickAndUploadStory,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Obx(() => Row(
                children: [
                  if (isLoading.value)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        color: whiteColor,
                        strokeWidth: 1,
                      ),
                    )
                  else
                    Image.asset(addIconPng, height: 2.h),
                  SizedBox(width: 3.w),
                  Text(
                    "ADD TO STORY",
                    style:
                        CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * widthScale,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              )),
        ),
      ),
      if (story != null) ...[
        SizedBox(width: 2.w),
        Row(
          children: [
            const Icon(Icons.favorite, size: 32, color: callHangColor),
            SizedBox(width: 2.w),
            Text(
              story.likeCount.toString(),
              style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                color: callHangColor,
                fontWeight: FontWeight.bold,
                fontSize: 18 * widthScale,
              ),
            ),
          ],
        )
      ]
    ];
  }

  List<Widget> _buildUserReplyControls() {
    if (chatController.storyData.isEmpty) return [];
    final story =
        chatController.storyData.first.stories[chatController.storyIndex.value];
    return [
      Expanded(
        child: SizedBox(
          height: 5.h,
          child: CustomTextFormField(
            focusNode: _focus,
            hintText: 'Reply to Story',
            hintStyle: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              color: headingColor,
              fontSize: 12.sp,
            ),
            controller: storyTextController,
            radius: 30,
            textFieldPadding: EdgeInsets.symmetric(horizontal: 4.w),
            suffixSvg: 'assets/svg/send_message.svg',
            onTapSuffix: _sendReply,
            borderColor: primaryColor,
            onTap: () {
              storyController.pause();
            },
          ),
        ),
      ),
      IconButton(
        onPressed: () async {
          final isLiked = await chatController
              .likeStory(storyId: storyId.value)
              .then((value) {
            if (value != null &&
                value['message'].contains('Story unliked successfully')) {
              return false;
            } else {
              return true;
            }
          });
          story.isLiked.value = isLiked;
        },
        icon: Icon(
          story.isLiked.value ? Icons.favorite : Icons.favorite_outline,
          size: 32,
          color: story.isLiked.value ? callHangColor : Colors.grey,
        ),
      ),
    ];
  }

  Future<void> _pickAndUploadStory() async {
    isLoading.value = true;
    storyController.pause();
    final XFile? story = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (story != null) {
      String type = story.path.split('.').last;
      String selectedMediaType = Helpers.extractMediaType(story.path);

      Map<String, dynamic> data = {
        'image': await d.MultipartFile.fromFile(
          story.path,
          filename: story.path.split('/').last,
          contentType: d.DioMediaType(selectedMediaType, type.toLowerCase()),
        ),
        'media_type': selectedMediaType,
      };

      final result =
          await chatController.addStory(data: data, chatId: widget.chatId);
      if (result) {
        chatController.storyData.refresh();
        await chatController.getStory(
            userId: uiController.userData.value['id']);
        Helpers.toast('Story Added Successfully');
      }
    }
    isLoading.value = false;
    storyController.play();
  }

  void _sendReply() {
    if (storyTextController.text.isEmpty) {
      Helpers.toast('Message Required!!');
      return;
    }
    final data = {
      'chat_id': widget.chatId,
      'type': 'group',
      'message_text': storyTextController.text,
      'story_id': storyId.value,
    };
    chatController.sendMessage(
      data: data,
      showProhibited: ({String? title, String? message}) =>
          _showBannedWordAlert(),
    );
    storyTextController.clear();

    showDialog(
      context: context,
      builder: (_) => StoryPopup(
        isMessageSent: true,
        storyId: storyId.value,
        chatId: widget.chatId,
      ),
    );
  }

  void _showBannedWordAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: transparentColor,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              SvgPicture.asset('assets/svg/banned_icon.svg', height: 62),
              SizedBox(height: 4.w),
              Text(
                "Your Message Contains One Or More Banned Words!",
                textAlign: TextAlign.center,
                style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                  color: failed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.w),
              Text(
                "Please Avoid Using Inappropriate Language To Keep This Space Safe And Friendly.",
                textAlign: TextAlign.center,
                style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                  color: headingColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
