import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/services/chat_services.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_media_model.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:closerrr/src/models/chat/story/story_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/socket_services.dart';
import '../../models/chat/chat_memories.dart';
import '../../models/chat/chat_messages_model.dart';

class ChatController extends GetxController {
  final Dio dio;
  ChatController(this.dio);

  late ChatServices chatServices = ChatServices();
  final CoreSocketServices socketService = Get.find();
  final searchChatController = TextEditingController();
  var newMessageEvent =
      Rxn<Map<String, dynamic>>(); // holds the latest new message
  var newBadgeEvent =
      Rxn<Map<String, dynamic>>(); // holds the latest new badge message
  var userEvent = Rxn<Map<String, dynamic>>();
  var newCompressMediaEvent =
      Rxn<Map<String, dynamic>>(); // holds the latest compress media info

  ///[Loading]
  final loading = false.obs;
  final isSearching = false.obs;

  /// [Chat Searching]
  final isChatMessageSearching = false.obs;
  TextEditingController searchController = TextEditingController();
  FocusNode searchInputFieldFocusNode = FocusNode();
  final activeSearch = 1.obs;
  final searchTextId = 0.obs;
  final hasAbove = true.obs;
  final hasBelow = true.obs;
  final loadingUpMessages = false.obs;
  final loadingDownMessages = false.obs;
  final totalMatches = 0.obs;

  ///[Chats]
  final RxString activeChatBackground = "".obs;
  final chatPage = 0.obs;
  final chatCount = 0.obs;
  final chats = <ChatRowData>[].obs;
  final messages = <MessagesRow>[].obs;
  // final Rx<InMemoryChatController> inMemoryChatController =
  //     InMemoryChatController(messages: []).obs;
  final uiController = Get.find<UserInformationController>();

  /// [Own Messages]
  final ownMessages = false.obs;

  /// [Chat Media]
  final chatMedia = <MediaData>[].obs;
  final chatMediaCount = 0.obs;
  final mediaActiveIndex = 0.obs;
  final selectedSection = 'Photos'.obs;

  /// [Chat Memories]
  RxList<MemoriesData> chatMemories = <MemoriesData>[].obs;

  /// [Story Data]
  final isDownloading = false.obs;
  final isDownloaded = false.obs;
  final isDownloadFailed = false.obs;
  final storyData = <StoryRow>[].obs;
  final progressNotifier = ValueNotifier(0.0);
  final isStoryLoading = false.obs;
  final storyIndex = 0.obs;

  /// [Media Data]
  final isMediaDownloading = false.obs;
  final isMediaDownloaded = false.obs;
  final isMediaDownloadFailed = false.obs;
  final mediaData = <StoryRow>[].obs;
  final mediaProgressNotifier = ValueNotifier(0.0);

  final currentPage = 1.obs;
  final isLastMessage = false.obs;

  Future<void> getChats({
    required int page,
    String? search,
  }) async {
    final response = await chatServices.getChats(
      page: page,
      search: search,
    );
    response.fold(
      (failure) => kLog('Failure in Chats :: $failure', error: true),
      (success) {
        chatCount.value = success.data.count;
        success.data.rows.sort((a, b) {
          if (a.isFavourite != null && b.isFavourite != null) {
            if (a.isFavourite!.value == b.isFavourite!.value) {
              return 0;
            }
          }
          return b.isFavourite!.value ? 1 : -1;
        });

        chats.assignAll(success.data.rows);
      },
    );
  }

  Future getChatMessages({
    String? search,
    required int chatId,
    int? targetId,
    bool? isOwn,
    int? page,
    int? limit,
    String? direction,
  }) async {
    List<MessagesRow> newRows = [];
    final response = await chatServices.getChatMessages(
      search,
      chatId: chatId,
      isOwn: isOwn,
      page: page,
      targetId: targetId,
      direction: direction,
      limit: limit,
    );

    response.fold(
      (failure) => kLog('Failure in Chat Messages :: $failure', error: true),
      (success) {
        hasAbove.value = success.data.searchInfo?.hasMoreAbove ?? false;
        hasBelow.value = success.data.searchInfo?.hasMoreBelow ?? false;
        totalMatches.value = success.data.searchInfo?.totalMatches ?? 0;

        if (search != null && search.isNotEmpty) {
          searchTextId.value = success.data.targetMessageId ?? 0;
        }

        if (page == 1 || search != null && targetId == null) {
          messages.clear();
        }
        newRows = success.data.messages.rows;
        isOwn != null ? ownMessages.value = true : ownMessages.value = false;
        messages.addAll(newRows);
        isLastMessage.value = messages.length == success.data.messages.count;
      },
    );

    loadingUpMessages.value = false;
    loadingDownMessages.value = false;
    return newRows;
  }

  Future<MessagesRow?> sendMessage({
    required Map<String, dynamic> data,
    required Function({String? title, String? message}) showProhibited,
  }) async {
    try {
      final response = await chatServices.sendMessage(
        data: data,
      );
      return await response.fold(
        (failure) {
          if (failure.props.isNotEmpty) {
            print('-----------------------------------');
            if (failure.props.first
                .toString()
                .contains('MESSAGE_LIMIT_REACHED')) {
              showProhibited(
                title: "Message Limit Reached",
                message: "You can't send more than 3 messages per day.",
              );
            }
            if (failure.props.first
                .toString()
                .contains('Your message contained prohibited language.')) {
              showProhibited();
            }
          }

          kLog('Failure in Sending Message :: $failure', error: true);
          return null;
        },
        (success) async {
          Map<String, dynamic> data = success["data"];
          await socketService.sendMessage(data);
          data["type"] = "loading";
          messages.insert(0, MessagesRow.fromJson(data));
          return MessagesRow.fromJson(data);
        },
      );
    } catch (e) {
      kLog('Exception in Sending Message :: $e', error: true);
      return null;
    }
  }

  Future<void> addAndRemoveStarredMessage({
    required int messageId,
  }) async {
    final response = await chatServices.addAndRemoveStarredMessage(
      messageId: messageId,
    );
    response.fold(
      (failure) => kLog('Failure in Add Remove Starred Message :: $failure',
          error: true),
      (success) {
        kLog(success);
      },
    );
  }

  Future<void> getStarredMessages({
    required int chatId,
  }) async {
    final response = await chatServices.getStarredMessages(
      chatId: chatId,
    );
    response.fold(
      (failure) =>
          kLog('Failure in Getting Starred Messages :: $failure', error: true),
      (success) {
        chatMemories.assignAll(success.data);
      },
    );
  }

  Future<void> getChatMedia({
    required int chatId,
    required int page,
    required int limit,
    required String mediaType,
  }) async {
    final response = await chatServices.getChatMedia(
      chatId: chatId,
      page: page,
      limit: limit,
      mediaType: mediaType,
    );

    response.fold(
      (failure) =>
          kLog('Failure in Getting Chat Media :: $failure', error: true),
      (success) {
        chatMediaCount.value = success.data.count;
        chatMedia.assign(success.data);
      },
    );
  }

  Future<void> getUnreadMessagesCount({
    required int chatId,
  }) async {
    final response = await chatServices.getUnreadMessagesCount(chatId: chatId);
    response.fold(
      (failure) => kLog('Failure in Getting Unread Messages Count :: $failure',
          error: true),
      (success) {
        // Handle the unread messages count
      },
    );
  }

  Future<void> getChatUsers({
    required int chatId,
  }) async {
    final response = await chatServices.getChatUsers(chatId: chatId);
    response.fold(
      (failure) =>
          kLog('Failure in Getting Chat Users :: $failure', error: true),
      (success) {
        // Handle the chat users data
      },
    );
  }

  Future<void> addAndRemoveFavouriteChat({
    required int chatId,
  }) async {
    final response =
        await chatServices.addAndRemoveFavouriteChat(chatId: chatId);
    response.fold(
      (failure) => kLog('Failure in Adding/Removing favourite Chat :: $failure',
          error: true),
      (success) {
        // Handle the favourite chat status
      },
    );
  }

  Future<void> updateSeenStatus({
    required int chatId,
  }) async {
    final response = await chatServices.updateSeenStatus(chatId: chatId);
    response.fold(
      (failure) =>
          kLog('Failure in Updating Seen Status :: $failure', error: true),
      (success) {
        // Handle the seen status update
      },
    );
  }

  Future<bool> updateNickname({
    required int chatId,
    String? nickname,
    required bool isYours,
  }) async {
    final response = await chatServices.updateNickname(
      chatId: chatId,
      nickname: nickname,
      isYours: isYours,
    );
    response.fold(
      (failure) {
        kLog('Failure in Updating Nickname :: $failure', error: true);
        return false;
      },
      (success) async {
        getChatMessages(chatId: chatId, page: 1, limit: 10);
        getChats(page: 1);
        return true;
      },
    );
    return response.isRight();
  }

  Future<bool?> updateChatBackground({
    required int chatId,
    XFile? background,
    required String type,
  }) async {
    final response = await chatServices.updateChatBackground(
      chatId: chatId,
      type: type,
      background: background,
    );
    response.fold(
      (failure) {
        kLog('Failure in Updating Chat Background :: $failure', error: true);
        return false;
      },
      (success) {
        getChatMessages(chatId: chatId, page: 1, limit: 10);
        return true;
      },
    );
    return null;
  }

  /// [Get Story]
  Future<void> getStory({
    required int userId,
  }) async {
    final response = await chatServices.getStory(userId: userId);
    response.fold(
      (failure) {
        isStoryLoading.value = false;
        return kLog('Failure in Getting Story :: $failure', error: true);
      },
      (success) {
        /// [Handle the story data]
        storyData.assignAll(success.data.rows);
        isStoryLoading.value = false;
      },
    );
  }

  /// [Add Story]
  Future<bool> addStory({
    required Map<String, dynamic> data,
    required int chatId,
  }) async {
    final response = await chatServices.addStory(
      data: data,
    );
    response.fold(
      (failure) {
        kLog('Failure in Adding Story :: $failure', error: true);
      },
      (success) {
        final story = Story.fromJson(success['data']);
        final uiController = Get.find<UserInformationController>();
        final userData = uiController.userData.value;
        if (storyData.value.isEmpty) {
          storyData.value.add(StoryRow(
            id: userData['id'],
            email: userData['email'],
            mobile: userData['mobile'],
            password: '',
            userId: null,
            isEmailVerified: userData['is_email_verified'],
            isMobileVerified: userData['is_mobile_verified'],
            roleId: userData['role_id'],
            fcmToken: userData['fcm_token'],
            streamToken: userData['stream_token'],
            signInType: userData['sign_in_type'],
            isOnboarded: userData['is_onboarded'],
            createdAt: DateTime.parse(userData['createdAt']),
            updatedAt: DateTime.parse(userData['updatedAt']),
            lastStoryDate: DateTime.now(),
            stories: [story],
          ));
        } else {
          storyData.value.first.stories.add(story);
        }
        final chat = chats.firstWhere((e) => e.id == chatId);
        chat.storyCount.value = chat.storyCount.value + 1;
      },
    );
    return response.isRight();
  }

  /// [Like Story]
  Future<Map<String, dynamic>?> likeStory({
    required int storyId,
  }) async {
    final response = await chatServices.likeStory(
      storyId: storyId,
    );
    Map<String, dynamic>? success;
    response.fold(
      (failure) => kLog('Failure in Liking Story :: $failure', error: true),
      (succ) {
        print("--------------");
        success = succ;
      },
    );
    return success;
  }

  /// [Report]
  Future<bool> report({
    required int id,
    required String text,
    required String type,
  }) async {
    var message = ''.obs;
    final response = await chatServices.report(
      id: id,
      text: text,
      type: type,
    );
    response.fold(
      (failure) => kLog('Failure in Liking Story :: $failure', error: true),
      (success) {
        message.value = success['error_message'] ?? '';
      },
    );
    loading.value = false;
    if (message.value.contains('Already')) {
      return false;
    }
    return true;
  }

  Future<bool> deleteMessage({required int messageId}) async {
    try {
      final response = await chatServices.deleteMessage(
        messageId: messageId,
      );

      response.fold((fail) {
        return false;
      }, (success) {
        messages.removeWhere((mes) => mes.id == messageId);
        return true;
      });

      return response.isRight();
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> updateChatSettings(
      {required int chatId,
      String? groupName,
      String? groupDescription,
      XFile? groupIcon}) async {
    final response = await chatServices.updateChatSettings(
      chatId: chatId,
      groupName: groupName,
      groupDescription: groupDescription,
      groupIcon: groupIcon,
    );
    Map<String, dynamic> success = {};
    response.fold(
      (failure) {
        kLog('Failure in Updating Chat Settngs :: $failure', error: true);
        success = {
          'success': false,
          'error': 'Failure in Updating Chat Settngs :: $failure',
        };
      },
      (succ) async {
        success = succ;
      },
    );
    return success;
  }
}
