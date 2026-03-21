import 'dart:developer';

import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart'
    as LocalChatController;
import 'package:closerrr/src/models/chat/chat_memories.dart' show MemoriesData;
import 'package:closerrr/src/models/chat/chat_messages_model.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_popup_btn.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/custom_chat_bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../controller/authentication/auth_controller.dart';
import '../../../../models/chat/chat_model.dart';

class Memories extends StatefulWidget {
  const Memories({super.key, required this.chatId});
  final int chatId;

  @override
  State<Memories> createState() => _MemoriesState();
}

class _MemoriesState extends State<Memories> {
  LocalChatController.ChatController chatController = Get.find();
  final Rx<InMemoryChatController> _chatController =
      InMemoryChatController(messages: []).obs;
  AuthController authController = Get.find();
  String userId = '';
  Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  Rx<ChatUser?> chatUser = Rx<ChatUser?>(null);
  final isRepling = false.obs;
  final replyId = 0.obs;
  final reply = {}.obs;

  // Reply

  final messageController = TextEditingController();
  // final AutoScrollController _scrollController = AutoScrollController();
  XFile? media;
  String selectedMediaType = 'image';
  FilePickerResult? audio;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((value) {
      // chatController.getStarredMessages(chatId: widget.chatId);
      _getMemoriesMessages();
    });

    // chatController.chatMemories.value.

    super.initState();
  }

  _getMemoriesMessages() async {
    userId = await Helpers.getUserId();
    await chatController.getStarredMessages(chatId: widget.chatId);
    List<Message> listOfMessages = [];

    chatController.chatMemories
        .sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (var memoriesMessage in chatController.chatMemories) {
      listOfMessages.add(mapMemoriesToMessage(memoriesMessage));
    }

    _chatController.value.insertAllMessages(listOfMessages);
  }

  Message mapMemoriesToMessage(MemoriesData memories) {
    return TextMessage(
      id: memories.id.toString(),
      authorId: memories.senderId.toString(),
      text: memories.messageText ?? "",
      createdAt: memories.createdAt,
      $type: "text",
      metadata: {
        "author": {
          "id": memories.user.id.toString(),
          "name":
              memories.user.profile.fullname ?? memories.user.profile.username,
          "imageSource": memories.user.profile.profilePic,
          "media": memories.media,
        },
      },
      // If you want to handle media, add it like this:
      // source: memories.media.isNotEmpty ? memories.media.first.toJson() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      appBar: ChatAppBar(
        chatTitle: 'Memories',
        isChatSetting: true,
      ),
      body: Stack(
        children: [
          // Pattern Background
          Positioned.fill(
            child: Helpers.defaultChatBackground(),
          ),
          Chat(
            backgroundColor: Colors.transparent,
            currentUserId: userId,
            resolveUser: (UserID id) async {
              return User(
                  id: id, name: 'John Doe', metadata: {"name": "John Doe"});
            },
            chatController: _chatController.value,
            builders: Builders(
              textMessageBuilder: (context, message, index,
                  {required isSentByMe, groupStatus}) {
                return _buildBubble(message, widthScale);
              },
              imageMessageBuilder: (context, message, index,
                  {required isSentByMe, groupStatus}) {
                return _buildBubble(message, widthScale);
              },
              audioMessageBuilder: (context, message, index,
                  {required isSentByMe, groupStatus}) {
                return _buildBubble(message, widthScale);
              },
              videoMessageBuilder: (context, message, index,
                  {required isSentByMe, groupStatus}) {
                return _buildBubble(message, widthScale);
              },
              fileMessageBuilder: (context, message, index,
                  {required isSentByMe, groupStatus}) {
                return Text(message.toJson().toString());
              },
              // Hide the default composer completely
              composerBuilder: (context) => const SizedBox.shrink(),
              emptyChatListBuilder: (context) => _emptyState(context),
              systemMessageBuilder: (context, message, index,
                  {required isSentByMe, groupStatus}) {
                return _buildDateHeader(
                  message.text,
                );
              },
              chatAnimatedListBuilder: (context, itemBuilder) {
                return ChatAnimatedList(
                  itemBuilder: itemBuilder,
                  onEndReached: () async {
                    // _paginationControl();
                  },
                  initialScrollToEndMode: InitialScrollToEndMode.none,
                );
              },
            ),
            onMessageLongPress: _handleMessageLongPress,
          ),
        ],
      ),
    );
  }

  _buildBubble(Message message, double widthScale) {
    final msg = message.toJson();
    final createdAt = DateFormat('hh:mm aa').format(
      DateTime.fromMillisecondsSinceEpoch(
        msg['createdAt'],
      ),
    );

    final author = msg['metadata']['author'];
    final isUser = author['id'] != userId;
    List<Media> listOfMedia = author["media"];
    String mediaType = listOfMedia.isNotEmpty ? listOfMedia.first.category : "";
    String? mediaUrl = listOfMedia.isNotEmpty ? listOfMedia.first.path : null;

    // log(msg.toString());

    return BubbleSpecialOne(
      id: msg['id'].toString(),
      isFavoriteMessage: true,
      type: mediaType.isNotEmpty ? mediaType : msg['type'],
      // type: "video",
      textMessage: msg['text'] ?? msg['name'] ?? '',
      createdAt: createdAt,
      profilePic: author['imageSource'] ?? "",
      fullName: author['name'],
      userId: userId,
      nameColor: isUser ? primaryColor : whiteColor,
      timeColor: isUser ? primaryColor : whiteColor,
      textStyle: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
        color: isUser ? blackColor : whiteColor,
        fontWeight: FontWeight.w500,
        fontSize: (widthScale * kTextFormFactor) * 16,
      ),
      color: isUser ? const Color(0xFFF9F1FF) : primaryColor,
      // repliedMessage: msg['metadata']['repliedMessage'] != null
      //     ? TextMessage.fromJson(msg['metadata']['repliedMessage'])
      //     : null,
      isSender: !isUser,
      mediaUrl: mediaUrl,
    );
  }

  void _handleMessageLongPress(
    BuildContext context,
    Message message, {
    int? index,
    LongPressStartDetails? details,
  }) {
    final msg = message.toJson();
    showDialog(
      context: context,
      builder: (context) {
        return ChatMessageAction(
          messageId: int.parse(message.id),
          createdAt: message.createdAt ?? DateTime.now(),
          onTapRemoveFromMemories: () {
            _chatController.value.removeMessage(message);
          },
          onTapCopyMessage: () {
            log("message");
            Clipboard.setData(ClipboardData(text: msg['text']));
          },
          senderId: msg['authorId'],
        );
      },
    );
  }

  _buildDateHeader(date) {
    final formatDate = DateFormat('MMMM dd, yyyy').format(date);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          formatDate.toString(),
          style: CustomTextStyle.styledTextWidget.labelSmall!.copyWith(
            color: whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Stack _emptyState(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/svg/no_chat_icon.svg',
                height: 200,
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatMessageAction extends StatefulWidget {
  const ChatMessageAction({
    super.key,
    this.senderId,
    required this.messageId,
    required this.createdAt,
    required this.onTapRemoveFromMemories,
    required this.onTapCopyMessage,
  });
  final int messageId;
  final DateTime createdAt;
  final String? senderId;

  final VoidCallback onTapRemoveFromMemories;
  final VoidCallback onTapCopyMessage;

  @override
  State<ChatMessageAction> createState() => _ChatMessageActionState();
}

class _ChatMessageActionState extends State<ChatMessageAction> {
  LocalChatController.ChatController chatController = Get.find();

  final isRemoveFromMemoriesDone = false.obs;
  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
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
        child: Obx(() => isRemoveFromMemoriesDone.value
            ? _buildRemoveFromMemories()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Actions',
                      style: CustomTextStyle.styledTextWidget.titleMedium
                          ?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: (widthScale * kTextFormFactor) * 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  PopupCustomBtn(
                    isActions: true,
                    title: 'Copy Message',
                    icon: Icons.copy_rounded,
                    ontap: () {
                      widget.onTapCopyMessage();
                      Get.back();
                    },
                  ),
                  SizedBox(height: 1.h),
                  PopupCustomBtn(
                    isActions: true,
                    isChat: true,
                    title: 'Remove from Memories',
                    svg: 'assets/svg/memories.svg',
                    ontap: () async {
                      chatController
                          .addAndRemoveStarredMessage(
                        messageId: widget.messageId,
                      )
                          .then(
                        (value) {
                          widget.onTapRemoveFromMemories();
                          isRemoveFromMemoriesDone.value = true;
                        },
                      );
                      // Get.back();
                    },
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    DateFormat('dd MMMM, yyyy | hh:mm aa')
                        .format(widget.createdAt)
                        .toString(),
                    style:
                        CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                      color: headingColor,
                    ),
                  ),
                ],
              )),
      ),
    );
  }

  _buildRemoveFromMemories() {
    return Container(
      constraints: BoxConstraints(maxHeight: 18.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/message_sent_icon.svg',
            height: 64,
          ),
          SizedBox(height: 3.h),
          PopupCustomBtn(
            isReporting: false,
            isCenterTitle: true,
            title: 'Removed From Memories',
            ontap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
