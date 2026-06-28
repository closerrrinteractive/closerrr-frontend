import 'dart:io';

import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/services/local_notification_service.dart';
import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/debug_log.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart'
    as LocalChatController;
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_messages_model.dart';
import 'package:closerrr/src/view/popup/chat/audio_selector.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/authentication/auth_controller.dart';
import '../../../models/chat/chat_model.dart';
import '../../popup/chat/chat_action.dart';
import '../../widgets/custom_widgets/custom_text_formfield.dart';
import '../../widgets/specific_widgets/chat/custom_chat_bubble.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key, required this.chat});
  final ChatRowData chat;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  final LocalChatController.ChatController chatController = Get.find();
  final AuthController authController = Get.find();
  final UserInformationController uiController = Get.find();
  final CoreSocketServices socketService = Get.find();
  final Rx<InMemoryChatController> _chatController =
      InMemoryChatController(messages: []).obs;

  final Rx<UserData?> chatAdmin = Rx<UserData?>(null);
  final Rx<UserData?> loggedInUser = Rx<UserData?>(null);
  final Rx<FilePickerResult?> audio = Rx<FilePickerResult?>(null);
  final RxList<XFile?> media = RxList<XFile?>([]);
  final RxList<String> videoThumbnail = RxList<String>([]);

  final isRepling = false.obs;
  final replyId = 0.obs;
  final reply = {}.obs;
  final selectedMediaType = 'image'.obs;
  final messageText = ''.obs;

  final showMedia = false.obs;

  final messageController = TextEditingController();
  late String userId;
  late double widthScale;
  final pinUsers = <UserData>[].obs;
  late final ChatRowData? chat;

  _initChatSocket() {
    // join the chat room
    socketService.joinChatRoom({"chatId": widget.chat.id});
    // listen to s3 lambda compression status for media update
    socketService.updateCompressedMediaPath();
    // recieve incoming messaged from other user
    socketService.recieveMessage(widget.chat.id);
    // listen for new message
    chatController.newMessageEvent.listen((data) {
      if (data != null && data["chat_id"] == widget.chat.id) {
        if (data["isDelete"] == true) {
          final messages = _chatController.value.messages;
          Message? oldMessage = messages.firstWhereOrNull(
              (message) => message.id == data["id"].toString());
          _chatController.value.removeMessage(oldMessage!);
        } else {
          // Only push if same chat
          data["status"] = "initiated";
          final convertedMessages =
              _buildMessages([MessagesRow.fromJson(data)]);
          _chatController.value.insertMessage(convertedMessages[0]);
        }
      }
    });
    // listen for new compress media event
    chatController.newCompressMediaEvent.listen((data) {
      final messages = _chatController.value.messages;
      if (data != null && data["message_id"] != null) {
        Message? oldMessage = messages.firstWhereOrNull(
            (message) => message.id == data["message_id"].toString());

        if (oldMessage != null) {
          String media = '${ApiStrings.s3ImageUrl}${data["key"]}';

          if (oldMessage is ImageMessage) {
            ImageMessage newMessage = oldMessage.copyWith(
                source: media,
                metadata: {...?oldMessage.metadata, "status": data["status"]});
            _chatController.value.updateMessage(oldMessage, newMessage);
          }

          if (oldMessage is VideoMessage) {
            VideoMessage newMessage = oldMessage.copyWith(
                source: media,
                metadata: {...?oldMessage.metadata, "status": data["status"]});
            _chatController.value.updateMessage(oldMessage, newMessage);
          }

          if (oldMessage is AudioMessage) {
            AudioMessage newMessage = oldMessage.copyWith(
                source: media,
                metadata: {...?oldMessage.metadata, "status": data["status"]});
            _chatController.value.updateMessage(oldMessage, newMessage);
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    LocalNotificationService.activeChatId = widget.chat.id;
    _initialize();
    _initChatSocket();
    messageController.addListener(() {
      messageText.value = messageController.text;
    });
    _loadMessages();
    _addAllUsers();
  }

  _addAllUsers() {
    pinUsers.addAll(widget.chat.users);
  }

  void _initialize() async {
    chatController.currentPage.value = 1;
    chatController.loading.value = false;
    chatController.isLastMessage.value = false;
    userId = uiController.userData.value['id'].toString();
    chatAdmin.value = Helpers.getAdmin(users: widget.chat.users);
    loggedInUser.value =
        Helpers.getUser(users: widget.chat.users, userId: userId);
    loadAndSetCurrentChatBackground();
    // #region agent log
    DebugLog.write(
      location: 'chat_message.dart:_initialize',
      message: 'chat message initialized',
      hypothesisId: 'B',
      data: {
        'chatId': widget.chat.id,
        'adminName': chatAdmin.value?.profile?.fullname ??
            chatAdmin.value?.profile?.username,
        'userCount': widget.chat.users.length,
      },
    );
    // #endregion
    if (mounted) setState(() {});
  }

  void loadAndSetCurrentChatBackground() {
    chatController.activeChatBackground.value =
        loggedInUser.value?.chatUser.chatBackground ?? "";
  }

  Future<void> _loadMessages() async {
    chatController.searchController.text = '';
    chatController.isChatMessageSearching.value = false;
    await chatController.getChatMessages(
      chatId: widget.chat.id,
      page: 1,
      limit: 10,
    );
    await chatController.updateSeenStatus(chatId: widget.chat.id);
    final convertedMessages =
        _buildMessages(chatController.messages.value.reversed.toList());
    _chatController.value.insertAllMessages(convertedMessages);
  }

  Future<void> _paginationControl() async {
    final newRows = await chatController.getChatMessages(
      chatId: widget.chat.id,
      page: chatController.currentPage.value += 1,
      limit: 10,
      isOwn: chatController.ownMessages.value ? true : null,
    );

    final convertedMessages = _buildMessages(newRows);
    _chatController.value
        .insertAllMessages(convertedMessages.reversed.toList(), index: 0);
  }

  List<Message> _buildMessages(List<MessagesRow> messageRows) {
    return messageRows.map<Message>((messageRow) {
      final author = _buildUser(messageRow.user);
      // if (messageRow.type == "loading") {
      //   return Message.custom(
      //       id: messageRow.id.toString(),
      //       authorId: messageRow.senderId.toString(),
      //       metadata: {"loading": true});
      // }
      if (messageRow.media.isEmpty) {
        return TextMessage(
          id: messageRow.id.toString(),
          text: messageRow.messageText ?? '',
          authorId: messageRow.senderId.toString(),
          createdAt: messageRow.createdAt,
          metadata: {
            "repliedMessage": _buildRepliedMessage(messageRow),
            "author": author,
            "seenBy": messageRow.seenBy,
            "is_favourite": messageRow.isFavourite,
          },
        );
      }
      final media = messageRow.media.first;
      final source = '${ApiStrings.s3ImageUrl}${media.path}';
      final size = media.size != null ? (media.size! / 1024).ceil() : 0;
      if (media.category == 'image') {
        return ImageMessage(
          authorId: messageRow.senderId.toString(),
          createdAt: messageRow.createdAt,
          id: messageRow.id.toString(),
          source: source,
          size: size,
          height: media.height?.toDouble() ?? 0,
          width: media.width?.toDouble() ?? 0,
          text: messageRow.messageText ?? '',
          metadata: {
            "author": author,
            "seenBy": messageRow.seenBy,
            "status": messageRow.status,
            "is_favourite": messageRow.isFavourite,
          },
        );
      } else if (media.category == 'video') {
        return VideoMessage(
          authorId: messageRow.senderId.toString(),
          createdAt: messageRow.createdAt,
          id: messageRow.id.toString(),
          name: media.path,
          source: source,
          size: size,
          text: messageRow.messageText ?? '',
          metadata: {
            "author": author,
            "seenBy": messageRow.seenBy,
            "type": messageRow.type,
            "status": messageRow.status,
            "is_favourite": messageRow.isFavourite,
          },
        );
      }
      return AudioMessage(
        authorId: messageRow.senderId.toString(),
        createdAt: messageRow.createdAt,
        id: messageRow.id.toString(),
        text: messageRow.messageText ?? '',
        source: source,
        size: size,
        duration: const Duration(seconds: 3),
        metadata: {
          "author": author,
          "seenBy": messageRow.seenBy,
          "status": messageRow.status,
          "is_favourite": messageRow.isFavourite,
        },
      );
    }).toList();
  }

  Message? _buildRepliedMessage(MessagesRow messageRow) {
    if (messageRow.story != null) {
      return TextMessage(
        id: messageRow.story!.id.toString(),
        text: messageRow.story!.text ?? '',
        authorId: messageRow.story!.userId.toString(),
        linkPreviewData: LinkPreviewData(
          link: '${ApiStrings.imageUrl}${messageRow.story?.mediaPath ?? ''}',
          image: ImagePreviewData(
            height: 250,
            width: 250,
            url: '${ApiStrings.imageUrl}${messageRow.story?.mediaPath ?? ''}',
          ),
        ),
        metadata: {
          "author": User(
            id: messageRow.story!.userId.toString(),
            name: messageRow.user.profile?.username ?? '',
          ),
        },
      );
    } else if (messageRow.replyTo != null) {
      return TextMessage(
        id: messageRow.replyTo!.id.toString(),
        replyToMessageId: messageRow.replyTo!.id.toString(),
        text: messageRow.replyTo!.messageText ?? '',
        authorId: messageRow.replyTo!.senderId.toString(),
        metadata: {
          "author": User(
            id: messageRow.replyTo!.user.id.toString(),
            name: messageRow.replyTo!.user.profile?.username ?? 'Unknown',
          ),
        },
      );
    }
    return null;
  }

  User _buildUser(ChatMessageUser user) {
    final isAdmin = user.chats.first.chatUser.isAdmin;
    final groupAdmin = Helpers.getAdmin(users: user.chats.first.users);
    final loggedInUser = uiController.isInfluencer.value
        ? null
        : Helpers.getUser(users: user.chats.first.users, userId: userId);
    final chatGroupName = widget.chat.groupName?.value;

    return User(
      id: user.id.toString(),
      name: Helpers.isInfluencer(uiController.userData['role_id'])
          ? user.profile?.username ?? 'No Name'
          : isAdmin
              ? (loggedInUser?.chatUser.friendName?.value != null &&
                      loggedInUser!.chatUser.friendName!.value.isNotEmpty)
                  ? loggedInUser.chatUser.friendName!.value
                  : (chatGroupName != null && chatGroupName.isNotEmpty)
                      ? chatGroupName
                      : groupAdmin?.profile?.fullname ??
                          groupAdmin?.profile?.username ??
                          ''
              : 'Unknown',
      imageSource: '${ApiStrings.s3ImageUrl}${user.profile?.profilePic ?? ''}',
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    if (LocalNotificationService.activeChatId == widget.chat.id) {
      LocalNotificationService.activeChatId = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      appBar: ChatAppBar(
        isChatMessageView: true,
        closerDays: widget.chat.closerrrDays,
        chatAdmin: uiController.isInfluencer.value
            ? loggedInUser.value?.profile
            : chatAdmin.value?.profile,
        loggedInUser: loggedInUser.value?.chatUser,
        chatId: widget.chat.id,
        chatName: chat?.groupName,
        chatIcon: chat?.groupIcon,
        isAdmin: '',
        buildMessage: () {
          final newMessages = _buildMessages(chatController.messages.value);

          final existingIds =
              _chatController.value.messages.map((m) => m.id).toSet();

          final uniqueMessages = newMessages
              .where((msg) => !existingIds.contains(msg.id))
              .toList();

          if (uniqueMessages.isNotEmpty) {
            _chatController.value.insertAllMessages(uniqueMessages);
          }
          _chatController.refresh();
        },
        chat: widget.chat,
        profileTap: () {
          context.pushNamed(
            'chat_profile',
            extra: {
              'profile': uiController.isInfluencer.value
                  ? loggedInUser.value?.profile?.toJson()
                  : chatAdmin.value?.profile?.toJson(),
              'closer_days': widget.chat.closerrrDays.toString(),
              'chat_id': widget.chat.id,
              'chat_user': loggedInUser.value?.chatUser.toJson(),
              'chat': widget.chat,
            },
          );
        },
      ),
      body: SafeArea(
        child: Obx(() => Stack(
              children: [
                _buildBackgroundImage(),
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Chat(
                            backgroundColor: Colors.transparent,
                            currentUserId: userId,
                            resolveUser: (UserID id) async => User(
                              id: id,
                              name: 'John Doe',
                              metadata: {"name": "John Doe"},
                            ),
                            chatController: _chatController.value,
                            userCache: UserCache(maxSize: 100),
                            builders: Builders(
                              textMessageBuilder: (context, message, index,
                                      {required isSentByMe, groupStatus}) =>
                                  _buildBubble(message, widthScale),
                              imageMessageBuilder: (context, message, index,
                                      {required isSentByMe, groupStatus}) =>
                                  _buildBubble(message, widthScale),
                              audioMessageBuilder: (context, message, index,
                                      {required isSentByMe, groupStatus}) =>
                                  _buildBubble(message, widthScale),
                              videoMessageBuilder: (context, message, index,
                                      {required isSentByMe, groupStatus}) =>
                                  _buildBubble(message, widthScale),
                              fileMessageBuilder: (context, message, index,
                                      {required isSentByMe, groupStatus}) =>
                                  Text(message.toJson().toString()),
                              composerBuilder: (context) =>
                                  const SizedBox.shrink(),
                              emptyChatListBuilder: _emptyState,
                              systemMessageBuilder: (context, message, index,
                                      {required isSentByMe, groupStatus}) =>
                                  _buildDateHeader(message.text),
                              chatAnimatedListBuilder: (context, itemBuilder) =>
                                  ChatAnimatedList(
                                itemBuilder: itemBuilder,
                                physics: const BouncingScrollPhysics(),
                                topPadding: 12,
                                onEndReached: _paginationControl,
                                initialScrollToEndMode:
                                    InitialScrollToEndMode.none,
                              ),
                            ),
                            onMessageLongPress: _handleMessageLongPress,
                          ),
                          if (chatController.isChatMessageSearching.value)
                            _buildSearchNavigation(),
                        ],
                      ),
                    ),
                    if (!chatController.isChatMessageSearching.value)
                      _buildBottomWidget(),
                  ],
                ),
                // if (messageText.value.contains('@') &&
                //     !messageText.value.contains('@@') &&
                //     uiController.isInfluencer.value)
                //   _buildFriendList(),
              ],
            )),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final background = chatController.activeChatBackground.value;
    return SizedBox(
      height: 100.h,
      width: 100.w,
      child: background == 'chat_default'
          ? Image.network(
              chatAdmin.value?.chatUser.chatBackground ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Helpers.defaultChatBackground(),
            )
          : Helpers.checkForAsset(background)
              ? Image.file(
                  File(background),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Helpers.defaultChatBackground(),
                )
              : Image.network(
                  background,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Helpers.defaultChatBackground(),
                ),
    );
  }

  Widget _buildSearchNavigation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildNavigationButton(
          'assets/svg/arrow_up.svg',
          () async {
            await chatController.getChatMessages(
              chatId: widget.chat.id,
              search: chatController.searchController.text,
              page: chatController.chatPage.value,
              targetId: int.parse(_chatController.value.messages.first.id),
            );
          },
        ),
        SizedBox(height: 1.h),
        _buildNavigationButton(
          'assets/svg/arrow_down.svg',
          () {},
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _buildNavigationButton(String asset, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: whiteColor,
          border: Border.all(width: 1, color: primaryColor.withOpacity(0.2)),
        ),
        child: SvgPicture.asset(asset, height: 26),
      ),
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
      builder: (context) => ChatMessageAction(
        messageId: int.parse(message.id),
        createdAt: message.createdAt ?? DateTime.now(),
        replyTo: () {
          isRepling.value = true;
          replyId.value = int.parse(msg['id']);
          reply.value['name'] = message.authorId == userId
              ? 'You'
              : msg['metadata']['author'].name ?? 'You';
          if (msg['text'] != null) reply.value['message'] = msg['text'];
          if (msg['source'] != null) {
            reply.value[msg['type']] = msg['source'];
            reply.value['type'] = msg['type'];
          }
          setState(() {});
        },
        onTapCopyMessage: () =>
            Clipboard.setData(ClipboardData(text: msg['text'])),
        onMessageDelete: () async {
          msg["chat_id"] = widget.chat.id;
          await socketService.sendMessage({...msg, "isDelete": true});
          _chatController.value.removeMessage(message);
        },
        senderId: msg['authorId'],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset('assets/svg/no_chat_icon.svg', height: 200),
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
    );
  }

  Widget _buildDateHeader(String date) {
    final formatDate = DateFormat('MMMM dd, yyyy').format(DateTime.parse(date));
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          formatDate,
          style: CustomTextStyle.styledTextWidget.labelSmall!.copyWith(
            color: whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(Message message, double widthScale) {
    final msg = message.toJson();
    final createdAt = DateFormat('h:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(msg['createdAt']),
    );
    final List<SeenBy>? seenBy = message.metadata!['seenBy'];
    final author = (msg['metadata']['author'] as User).toJson();
    final isUser = author['id'] != userId;

    String textMessage = msg['text'] ?? msg['name'] ?? '';
    if (uiController.isInfluencer.value == false &&
        textMessage.contains('@@')) {
      final username = uiController.userData.value['Profile']['username'];
      textMessage = textMessage.replaceAll('@@', '$username');
    }
    final isSeen = seenBy?.any((element) {
      return element.chatMessageSeen.seenBy == chatAdmin.value?.id;
    });
    return BubbleSpecialOne(
      id: msg['id'].toString(),
      seen: isSeen ?? true,
      textMessage: textMessage,
      type: msg['type'],
      nameColor: isUser ? primaryColor : whiteColor,
      timeColor: isUser ? primaryColor : whiteColor,
      textStyle: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
        color: isUser ? blackColor : whiteColor,
        fontWeight: FontWeight.w500,
        fontSize: widthScale * kTextFormFactor * 16,
      ),
      isFavoriteMessage: msg['metadata']['is_favourite'] ?? false,
      searchQuery: chatController.searchController.text,
      createdAt: createdAt,
      color: isUser ? const Color(0xFFF9F1FF) : primaryColor,
      repliedMessage: msg['metadata']['repliedMessage'] != null
          ? TextMessage.fromJson(msg['metadata']['repliedMessage'].toJson())
          : null,
      isSender: !isUser,
      userId: userId,
      profilePic: author['imageSource'],
      fullName: author['name'],
      mediaUrl: msg['source'],
      status: msg['metadata']?['status'] ?? null,
    );
  }

  Widget _buildBottomWidget() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 12),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Obx(() => Column(
                    children: [
                      if (isRepling.value) _buildReplyWidget(),
                      if (audio.value != null) _buildAudioWidget(),
                      if (media.value.isNotEmpty) _buildMediaWidget(),
                      CustomTextFormField(
                        hintText: uiController.isInfluencer.value
                            ? "Use @@ to call your fans by their nickname"
                            : 'Write your message',
                        cursorColor: whiteColor,
                        hintStyle: CustomTextStyle.styledTextWidget.bodyMedium
                            ?.copyWith(
                          color: whiteColor.withOpacity(0.6),
                          fontSize: widthScale * kTextFormFactor * 10,
                          letterSpacing: 0.3,
                        ),
                        style: CustomTextStyle.styledTextWidget.bodyMedium
                            ?.copyWith(
                          color: whiteColor,
                          fontSize: widthScale * kTextFormFactor * 10,
                          letterSpacing: 0.3,
                        ),
                        controller: messageController,
                        borderColor: transparentColor,
                        radius: 24,
                        fillColor: transparentColor,
                        containerWidget: const SizedBox(),
                        suffixIcon: uiController.isInfluencer.value
                            ? Icons.attachment_rounded
                            : null,
                        suffixColor: backScreenColor,
                        onTapSuffix: uiController.isInfluencer.value
                            ? () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Colors.transparent,
                                  builder: (context) =>
                                      _buildFilePickerPop(context, widthScale),
                                )
                            : null,
                      ),
                    ],
                  )),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  height: 60,
                  width: 60,
                  padding: const EdgeInsets.fromLTRB(17, 19, 19, 17),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: messageText.value.isNotEmpty ||
                            media.value.isNotEmpty ||
                            audio.value != null
                        ? primaryColor
                        : sendColor,
                  ),
                  child: chatController.loading.value
                      ? const CircularProgressIndicator(
                          color: whiteColor,
                          strokeWidth: 1,
                        )
                      : SvgPicture.asset('assets/svg/send_message.svg'),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReplyWidget() {
    return Container(
      width: 100.w,
      height: 8.h,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: chatRepliesColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primaryColor,
            ),
          ),
          if (reply.value['image'] != null && reply.value['type'] == 'image')
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 36,
                width: 36,
                child: reply.value['image'].startsWith('http')
                    ? Image.network(reply.value['image'], fit: BoxFit.cover)
                    : Image.file(
                        File(reply.value['image']),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/no_image.png',
                                fit: BoxFit.cover),
                      ),
              ),
            ),
          if (reply.value['audio'] != null && reply.value['type'] == 'audio')
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(6),
              child: SvgPicture.asset(
                'assets/svg/audio_icon.svg',
                fit: BoxFit.fitHeight,
                height: 26,
              ),
            ),
          SizedBox(width: 1.w),
          Obx(() => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    reply.value['name'] ?? '',
                    style:
                        CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 40.w,
                    child: Text(
                      reply.value['message'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.styledTextWidget.labelMedium!
                          .copyWith(
                        color: blackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: (widthScale * kTextFormFactor) * 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              )),
          const Spacer(),
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                reply.clear();
                isRepling.value = false;
                replyId.value = 0;
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: whiteColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/svg/search_close.svg',
                  color: primaryColor,
                  height: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioWidget() {
    final files = audio.value?.files ?? [];
    final totalSizeMB = files.fold<double>(
      0,
      (sum, file) => sum + (file.size / (1024 * 1024)),
    );

    return Row(
      children: [
        Container(
          width: 40,
          margin: const EdgeInsets.only(top: 4, left: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: settingCircle,
          ),
          child: SvgPicture.asset('assets/svg/audio_icon.svg', height: 24),
        ),
        SizedBox(width: 2.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40.w,
              child: Text(
                files.length == 1
                    ? files.first.name
                    : '${files.length} audio files selected',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                  color: whiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${totalSizeMB.toStringAsFixed(2)} MB',
              style: CustomTextStyle.styledTextWidget.labelSmall!.copyWith(
                color: whiteColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => audio.value = null,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
            ),
            child: SvgPicture.asset(
              'assets/svg/search_close.svg',
              color: primaryColor,
            ),
          ),
        ),
        SizedBox(width: 0.5.w),
      ],
    );
  }

  Future<double> calculateTotalMediaSize(List<XFile?> files) async {
    double totalMB = 0.0;
    for (var file in files) {
      if (file != null && await File(file.path).exists()) {
        final bytes = await file.length();
        totalMB += bytes / (1024 * 1024);
      }
    }
    return totalMB;
  }

  Widget _buildMediaWidget() {
    return Stack(
      children: [
        ...List.generate(
            media.value.length,
            (index) => Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        index * 0.8,
                      ),
                      child: Container(
                        height: 6.h,
                        width: 6.h,
                        margin: const EdgeInsets.only(
                          top: 4,
                          left: 4,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: videoThumbnail.value.isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      width: 1,
                                      color: whiteColor.withOpacity(0.4),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.video_file,
                                    color: whiteColor,
                                    size: 20,
                                  ),
                                )
                              : Image.file(
                                  File(media.value[index]?.path ?? ''),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == media.value.length - 1)
                            Text(
                              media.value
                                  .map((e) =>
                                      '${e?.name.split('.').first}.${e?.name.split('.').last}')
                                  .toList()
                                  .join(', '),
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CustomTextStyle
                                  .styledTextWidget.labelMedium!
                                  .copyWith(
                                color: whiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (index == media.value.length - 1)
                            FutureBuilder<double>(
                              future: calculateTotalMediaSize(media.value),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final totalSize = snapshot.data!;
                                final display = totalSize >= 1
                                    ? '${totalSize.toStringAsFixed(2)} MB'
                                    : '${(totalSize * 1024).toStringAsFixed(2)} KB';

                                return Text(
                                  display,
                                  style: CustomTextStyle
                                      .styledTextWidget.labelSmall!
                                      .copyWith(
                                          color: whiteColor.withOpacity(0.6)),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        media.value = [];
                        audio.value = null;
                        videoThumbnail.value = [];
                        messageController.clear();
                        isRepling.value = false;
                        reply.clear();
                        replyId.value = 0;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: whiteColor.withOpacity(0.5),
                        ),
                        child: SvgPicture.asset(
                          'assets/svg/search_close.svg',
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 0.5.w),
                  ],
                ))
      ],
    );
  }

  Widget _buildFilePickerPop(BuildContext context, double widthScale) {
    const options = [
      {"icon": "image", "label": "Photo"},
      {"icon": "video", "label": "Video"},
      {"icon": "audio", "label": "Audio"},
      {"icon": "story", "label": "Story"},
    ];

    return SizedBox(
      width: 100.w,
      child: Container(
        width: 80.w,
        constraints: BoxConstraints(maxHeight: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        margin: EdgeInsets.only(
            bottom: uiController.isInfluencer.value ? 11.h : 10.h,
            left: 5.w,
            right: 5.w),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 2, color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options
              .asMap()
              .entries
              .map((entry) => GestureDetector(
                    onTap: () async {
                      final index = entry.key;
                      if (index == 0) {
                        selectedMediaType.value = 'image';
                        audio.value = null;
                        media.value = await ImagePicker().pickMultiImage(
                          limit: 10,
                        );
                      } else if (index == 1) {
                        selectedMediaType.value = 'video';
                        audio.value = null;

                        media.value = await ImagePicker().pickMultiVideo(
                          limit: 5,
                        );

                        for (var file in media.value) {
                          videoThumbnail.value.add(file?.name ?? '');
                        }
                      } else if (index == 2) {
                        selectedMediaType.value = 'audio';
                        media.value = [];
                        showDialog(
                          context: context,
                          builder: (ctx) => AudioSelector(
                            onMicTap: (filePath) async {
                              final file = File(filePath);
                              final size = await file.length();
                              audio.value = FilePickerResult([
                                PlatformFile(
                                  name: file.path.split('/').last,
                                  size: size,
                                  path: file.path,
                                )
                              ]);
                              await _sendMessage();
                              Get.back();
                            },
                            onGalleryTap: () async {
                              audio.value = await FilePicker.platform.pickFiles(
                                type: FileType.audio,
                                allowMultiple: true,
                                allowCompression: true,
                              );

                              // await _sendMessage();
                              Get.back();
                            },
                            isRecording: false,
                          ),
                        );
                      } else if (index == 3) {
                        final story = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 50,
                        );

                        Map<String, dynamic> data = {};

                        if (story != null) {
                          String type = story.path.split('.').last;
                          String path = story.path;
                          String selectedMediaType =
                              Helpers.extractMediaType(path);
                          data['image'] = await d.MultipartFile.fromFile(
                            path,
                            filename: path.split('/').last,
                            contentType: d.DioMediaType(
                              selectedMediaType,
                              type.toLowerCase(),
                            ),
                          );

                          data['media_type'] = selectedMediaType;

                          final result = await chatController.addStory(
                            data: data,
                            chatId: widget.chat.id,
                          );
                          if (result) {
                            chatController.storyData.refresh();
                            await chatController.getStory(
                              userId: uiController.userData.value['id'],
                            );
                            Helpers.toast('Story Added Successfully');
                            Get.back();
                          }
                        }
                      }
                      context.pop();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/select_${entry.value["icon"]}.svg',
                          height: 46,
                          width: 46,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 0.5.w),
                        Text(
                          entry.value["label"] ?? '',
                          style: CustomTextStyle.styledTextWidget.bodySmall!
                              .copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: widthScale * kTextFormFactor * 16,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showBannedWordAlert({String? title, String? message}) {
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
                title ?? "Your Message Contains One Or More Banned Words!",
                textAlign: TextAlign.center,
                style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                  color: failed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.w),
              SizedBox(
                width: 60.w,
                child: Text(
                  message ??
                      "Please Avoid Using Inappropriate Language To Keep This Space Safe And Friendly.",
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (chatController.loading.value) return;
    FocusScope.of(context).unfocus();
    chatController.loading.value = true;

    try {
      final data = {
        'chat_id': widget.chat.id,
        'type': 'group',
        'message_text': messageController.text,
      };

      final hasAudio = audio.value != null && audio.value!.files.isNotEmpty;
      final hasMedia = media.value.isNotEmpty;

      if (!hasAudio && !hasMedia && messageController.text.isEmpty) {
        Helpers.toast('Message Required!!');
        return;
      }

      Future<void> sendAndInsert(Map<String, dynamic> payload) async {
        final value = await chatController.sendMessage(
          data: payload,
          showProhibited: ({String? title, String? message}) =>
              _showBannedWordAlert(title: title, message: message),
        );

        if (value != null) {
          value.status = "initiated";
          final converted = _buildMessages([value]);
          _chatController.value.insertAllMessages(converted);
        }
      }

      Future<void> uploadAndSend(XFile file, String type) async {
        final response = await chatController.uploadFiles(file, type);
        final key = response[0]["data"]["key"];
        final payload = Map<String, dynamic>.from(data)
          ..['media_type'] = type
          ..['media_path'] = key;
        if (replyId.value != 0) payload['reply_message_id'] = replyId.value;

        await sendAndInsert(payload);
        await Future.delayed(const Duration(milliseconds: 800));
      }

      if (hasAudio) {
        for (final file in audio.value!.files) {
          await uploadAndSend(XFile(file.path!), 'audio');
        }
      }

      if (hasMedia) {
        for (final file in media.value) {
          if (file != null) {
            await uploadAndSend(file, selectedMediaType.value);
          }
        }
      }

      if (!hasAudio && !hasMedia && messageController.text.isNotEmpty) {
        if (replyId.value != 0) data['reply_message_id'] = replyId.value;
        await sendAndInsert(data);
      }
    } catch (e, s) {
      debugPrint('Send Message Error: $e\n$s');
      Helpers.toast('Media processing failed: $e');
    } finally {
      media.value = [];
      audio.value = null;
      videoThumbnail.value = [];
      messageController.clear();
      isRepling.value = false;
      reply.clear();
      replyId.value = 0;
      chatController.loading.value = false;
    }
  }
}
