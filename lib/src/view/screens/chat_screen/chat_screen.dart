import 'dart:async';
import 'dart:convert';

import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/live/live_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/config/helpers.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../popup/chat/chat_tile_hold.dart';
import '../../widgets/custom_widgets/custom_chat_tile.dart';
import '../../widgets/custom_widgets/custom_search_bar.dart';
import '../../widgets/specific_widgets/chat/custom_no_chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final CoreSocketServices socketService = Get.find();
  RxString selectedOption = 'Favorite Chats'.obs;
  ChatController chatController = Get.find();
  UserInformationController userInformationController = Get.find();
  ScrollController scrollController = ScrollController();
  LiveController liveController = Get.find();

  @override
  void initState() {
    super.initState();
    chatController.chatPage.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        if (scrollController.position.atEdge) {
          final page = chatController.chatPage.value;
          final finalPage = (chatController.chatCount.value / 10).ceil();
          if (finalPage != page) {
            chatController.getChats(page: page);
            chatController.chatPage.value++;
          }
        }
      });
      getAllChats();
    });
  }

  @override
  void dispose() {
    socketService.disposeListeners("badge_update");
    socketService.disposeListeners("START_LIVE_STREAM");
    super.dispose();
  }

  listenForNewMessage() {
    // listen for new message and update the badge count and last message
    socketService.recieveBadgeUpdate();
    chatController.newBadgeEvent.listen((data) {
      if (data != null &&
          data["sender_id"] != userInformationController.userData["id"]) {
        ChatRowData? findedChat = chatController.chats.value
            .firstWhereOrNull((chat) => chat.id == data["chat_id"]);
        if (findedChat != null) {
          if (data["isDelete"] == true) {
            findedChat.lastMessage.value.first.messageText = "Deleted Message";
          } else {
            findedChat.unreadCount.value += 1;
            findedChat.lastMessage
              ..clear()
              ..add(LastMessage.fromJson({
                "id": data["id"],
                "chat_id": data["chat_id"],
                "sender_id": data["sender_id"],
                "story_id": data["story_id"],
                "reply_message_id": data["reply_message_id"],
                "message_text": data["message_text"],
                "createdAt": data["createdAt"],
                "updatedAt": data["updatedAt"],
                "User": data["User"],
              }));
          }
        }
      }
    });
  }

  listenForNewStream() {
    socketService.recieveLiveStreamUpdate();
    liveController.newLiveStreamEvent.listen((data) {
      if (data != null) {
        Map metaData = jsonDecode(data["meta_data"]);
        ChatRowData? chatRow = chatController.chats.value
            .firstWhereOrNull((chat) => chat.id == metaData["chat_id"]);

        if (chatRow != null) {
          final chatAdmin = Helpers.getAdmin(users: chatRow.users);
          chatAdmin?.liveStreams?.insert(
              0,
              LiveStreamM(
                  id: 1,
                  user_id: metaData["user_id"],
                  host_name: metaData["host_name"] ??
                      metaData["Profile"]["fullname"] ??
                      metaData["Profile"]["username"],
                  host_profile_pic: metaData["host_profile_pic"] ??
                      metaData["Profile"]["profile_pic"],
                  live_stream_id: metaData["id"],
                  status: "LIVE",
                  started_at: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  chat_id: chatRow.id));
        }
      }
    });
    liveController.endLiveStreamEvent.listen((data) {
      if (data != null) {
        Map metaData = data["data"];
        ChatRowData? chatRow = chatController.chats.value
            .firstWhereOrNull((chat) => chat.id == metaData["chat_id"]);
        if (chatRow != null) {
          final chatAdmin = Helpers.getAdmin(users: chatRow.users);
          if (chatAdmin != null && chatAdmin.liveStreams != null) {
            chatAdmin.liveStreams!.removeWhere(
                (stream) => stream.live_stream_id == metaData["id"]);
          }
        }
      }
    });
  }

  getAllChats() async {
    await chatController.getChats(page: 1);
    listenForNewMessage();
    listenForNewStream();
  }

  void sortAllChatsByFavorite() {
    // Make a copy of the list
    final sortedChats = List.of(chatController.chats);

    sortedChats.sort((a, b) {
      final aFav = a.isFavourite?.value ?? false;
      final bFav = b.isFavourite?.value ?? false;

      if (aFav == bFav) return 0;
      return aFav ? -1 : 1; // favorites first
    });

    // Reassign safely → not the same reference
    chatController.chats.assignAll(sortedChats);
  }

  Timer? debounce;
  FocusNode searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomSearchBar(
          isEvents: false,
          icon: 'assets/svg/chat_icon.svg',
          title: 'Chats',
          gif: chatHeartGif,
          searchController: chatController.searchChatController,
          onClose: () {
            chatController.isSearching.value = false;
            chatController.searchChatController.clear();
            chatController.getChats(page: 1);
          },
          onSearch: (value) {
            debounce?.cancel();
            debounce = Timer(const Duration(milliseconds: 800), () {
              chatController.getChats(
                search: chatController.searchChatController.text,
                page: 1,
              );
            });
          }),
      backgroundColor: whiteColor,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.only(top: 1.h),
        child: Column(
          children: [
            if (chatController.chats.value.isNotEmpty)
              Row(
                children: [
                  SvgPicture.asset(
                    favoriteChats,
                    color: headingColor,
                    height: 2.h,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "All Chats",
                    style: CustomTextStyle.styledTextWidget.labelMedium!
                        .copyWith(color: headingColor, fontSize: 15.sp),
                  ),
                ],
              ),
            SizedBox(height: 2.5.h),
            Obx(() {
              return Expanded(
                child: chatController.chatCount.value == 0
                    ? CustomNoChat(
                        isChat: true,
                        title: 'It’s no fun to be alone!',
                        subtitle: 'Make Friends Here-',
                        navigationShell: widget.navigationShell,
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: chatController.chats.value.length,
                        itemBuilder: (context, index) {
                          final chat = chatController.chats.value;
                          return ChatTile(
                            key: ValueKey(chat[index].id),
                            chat: chat[index],
                            onTap: () async {
                              if (chat[index].storyCount.value != 0) {
                                final admin = Helpers.getAdmin(
                                  users: chat[index].users,
                                );

                                context.go('/chat/story_screen', extra: {
                                  'user': admin,
                                  'chat_id': chat[index].id,
                                  'chat': chat[index],
                                });
                              }
                            },
                            onTapChat: () {
                              context.push(
                                '/chat/chat_message',
                                extra: {'chat': chat[index]},
                              ).then((_) {
                                chat[index].unreadCount.value = 0;
                              });
                            },
                            onHold: () => showDialog(
                              context: context,
                              builder: (context) {
                                final admin = Helpers.getAdmin(
                                  users: chat[index].users,
                                );
                                return ChatTileHold(
                                  chatId: chat[index].id,
                                  index: index,
                                  onTapChangeIsFavorite: () async {
                                    chatController.chats[index].isFavourite!
                                        .value = !(chatController
                                            .chats[index].isFavourite?.value ??
                                        false);

                                    await chatController
                                        .addAndRemoveFavouriteChat(
                                      chatId: chat[index].id,
                                    );

                                    sortAllChatsByFavorite();
                                  },
                                  secondaryText:
                                      chat[index].isFavourite!.value == true
                                          ? 'Remove Chat as Favorite'
                                          : 'Mark Chat as Favorite',
                                  text: admin.profile?.fullname ??
                                      admin.profile?.username ??
                                      '',
                                  chat: chat[index],
                                );
                              },
                            ),
                          );
                        },
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
