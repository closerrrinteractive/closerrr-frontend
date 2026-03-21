import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/live/live_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CoreSocketServices {
  final UserInformationController userInformationController = Get.find();
  RxList<dynamic> newComments = <dynamic>[].obs;
  io.Socket? socket;
  // Add a connection status variable
  RxBool isConnected = false.obs;

  Future<void> connectSocket() async {
    if (socket != null && socket!.connected) {
      isConnected.value = true;
      debugPrint('Socket already connected');
      return;
    }

    socket = io.io(
        ApiStrings.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/socket-server')
            .setAuth(
                {'token': userInformationController.userData['accessToken']})
            .build());

    socket?.connect();

    socket?.onConnect((data) {
      isConnected.value = true;
      kLog("Socket connected successfully!!! $data");
    });

    socket?.onError((error) {
      isConnected.value = false;
      debugPrint("Socket onError $error");
    });

    socket?.onDisconnect((_) {
      isConnected.value = false;
      kLog("Socket disconnected!!!");
    });
  }

  // Helper method to ensure socket is connected
  Future<bool> ensureConnection() async {
    if (!isConnected.value) {
      await connectSocket();
      // Wait for connection or timeout after 5 seconds
      int attempts = 0;
      while (!isConnected.value && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }
    return isConnected.value;
  }

  Future<void> startLiveStream(streamData) async {
    if (await ensureConnection()) {
      socket?.emit("startLiveStream", streamData);
    } else {
      debugPrint("Failed to connect socket for startLiveStream");
    }
  }

  Future<void> endLiveStream(streamData) async {
    if (await ensureConnection()) {
      socket?.emit("endLiveStream", streamData);
    } else {
      debugPrint("Failed to connect socket for endLiveStream");
    }
  }

  Future<void> joinUserRoom(id) async {
    if (await ensureConnection()) {
      socket?.emit("joinUserRoom", {"userId": id});
    }
  }

  Future<void> joinLiveStream(streamData) async {
    if (await ensureConnection()) {
      socket?.emit("joinLiveStream", streamData);
    }
  }

  Future<void> addCommentInLiveStream(streamData) async {
    debugPrint("addCommentInLiveStream");
    if (await ensureConnection()) {
      newComments.insert(0, {
        "name": streamData["name"],
        "message": streamData["message"],
      });
      socket?.emit("addCommentInLiveStream", streamData);
    }
  }

  Future<void> getNewCommentInLiveStream() async {
    if (await ensureConnection()) {
      debugPrint("Listening for new comment");

      socket?.on("new_comment", (data) {
        final comment = data["data"];
        newComments.insert(0, {
          "name": comment["name"],
          "message": comment["message"],
        });
      });
    }
  } 

  Future<void> getEndLiveStream() async {
    if (await ensureConnection()) {
      debugPrint("Listening for end live stream");

      socket?.on("end_live_stream", (data) {
        print("end_live_stream");
        // debugPrint(data);
        Get.find<LiveController>().endLiveStreamEvent.value = data;
      });
    }
  }

  Future<void> disposeListeners(listenerName) async {
    if (socket != null) {
      socket?.off(listenerName);
      debugPrint("Socket listeners disposed");
    }
  }

  // chat
  Future<void> joinChatRoom(data) async {
    print("sksjssksksks");
    print(data);
    if (await ensureConnection()) {
      socket?.emit("joinChatRoom", data);
    }
  }

  Future<void> leaveRoom(roomName) async {
    if (await ensureConnection()) {
      socket?.emit("leaveRoom", roomName);
    }
  }

  Future<void> sendMessage(Map data) async {
    // debugPrint("sendMessage: $data");
    if (await ensureConnection()) {
      socket?.emit("sendMessage", {
        "message": data,
        "chatId": data["chat_id"],
        "isDelete": data["isDelete"]
      });
    }
  }

  Future<void> listenUserRoom(id) async {
    if (await ensureConnection()) {
      socket?.on("user$id", (data) {
        print("debug 1");
        print(data);
        Get.find<ChatController>().userEvent.value = data;
      });
    }
  }

  Future<void> recieveMessage(chatId) async {
    if (await ensureConnection()) {
      socket?.on("newMessage", (data) {
        Get.find<ChatController>().newMessageEvent.value = data;
      });
    }
  }

  Future<void> recieveBadgeUpdate() async {
    if (await ensureConnection()) {
      socket?.on("badge_update", (data) {
        Get.find<ChatController>().newBadgeEvent.value = data;
      });
    }
  }

  Future<void> recieveLiveStreamUpdate() async {
    if (await ensureConnection()) {
      socket?.on("START_LIVE_STREAM", (data) {
        debugPrint("startLiveStream: $data");
        Get.find<LiveController>().newLiveStreamEvent.value = data;
      });
    }
  }

  // aws s3 and lambda compression events
  Future<void> updateCompressedMediaPath() async {
    if (await ensureConnection()) {
      socket?.on("update-compressed-media-path", (data) {
        Get.find<ChatController>().newCompressMediaEvent.value = data;
      });
    }
  }
}
