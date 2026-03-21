// To parse this JSON data, do
//
//     final chatMessages = chatMessagesFromJson(jsonString);

import 'dart:convert';

import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/models/chat/story/story_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'chat_memories.dart';
import 'chat_model.dart';

ChatMessages chatMessagesFromJson(String str) =>
    ChatMessages.fromJson(json.decode(str));

String chatMessagesToJson(ChatMessages data) => json.encode(data.toJson());

class ChatMessages {
  String status;
  String message;
  Data data;
  int statusCode;

  ChatMessages({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory ChatMessages.fromJson(Map<String, dynamic> json) {
    return ChatMessages(
      status: json["status"],
      message: json["message"],
      data: Data.fromJson(json["data"]),
      statusCode: json["statusCode"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}

class Data {
  final Messages messages;
  final bool? isTargetView;
  final int? targetMessageId;
  final SearchInfo? searchInfo;

  Data({
    required this.messages,
    this.isTargetView,
    this.targetMessageId,
    this.searchInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        messages: Messages.fromJson(json["messages"]),
        isTargetView: json["isTargetView"],
        targetMessageId: json["targetMessageId"] is String
            ? int.parse(json["targetMessageId"])
            : json["targetMessageId"],
        searchInfo: json["searchInfo"] == null
            ? null
            : SearchInfo.fromJson(json["searchInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "messages": messages.toJson(),
        "isTargetView": isTargetView,
        "targetMessageId": targetMessageId,
        "searchInfo": searchInfo!.toJson(),
      };
}

class SearchInfo {
  final String term;
  final int? totalMatches;
  final int? currentMatchIndex;
  final int currentMatchId;
  final bool hasMoreAbove;
  final bool hasMoreBelow;

  SearchInfo({
    required this.term,
    this.totalMatches,
    this.currentMatchIndex,
    required this.currentMatchId,
    required this.hasMoreAbove,
    required this.hasMoreBelow,
  });

  factory SearchInfo.fromJson(Map<String, dynamic> json) => SearchInfo(
        term: json["term"],
        totalMatches: json["totalMatches"],
        currentMatchIndex: json["currentMatchIndex"],
        currentMatchId: json["currentMatchId"] is int
            ? json["currentMatchId"]
            : int.parse(json["currentMatchId"] ?? '0'),
        hasMoreAbove: json["hasMoreAbove"] ?? false,
        hasMoreBelow: json["hasMoreBelow"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "term": term,
        "totalMatches": totalMatches,
        "currentMatchIndex": currentMatchIndex,
        "currentMatchId": currentMatchId,
        "hasMoreAbove": hasMoreAbove,
        "hasMoreBelow": hasMoreBelow,
      };
}

class Messages {
  int count;
  List<MessagesRow> rows;

  Messages({
    required this.count,
    required this.rows,
  });

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        count: json["count"],
        rows: List<MessagesRow>.from(
          json["rows"].map(
            (x) => MessagesRow.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "rows": List<dynamic>.from(
          rows.map((x) => x.toJson()),
        ),
      };
}

class MessagesRow {
  int id;
  int chatId;
  int senderId;
  String type;
  dynamic storyId;
  dynamic replyMessageId;
  String? messageText;
  DateTime createdAt;
  DateTime updatedAt;
  Story? story;
  bool isFavourite;
  List<Media> media;
  ChatMessageUser user;
  List<SeenBy> seenBy;
  ReplyTo? replyTo;
  String? status;

  MessagesRow(
      {required this.id,
      required this.chatId,
      required this.senderId,
      this.type = "message",
      required this.storyId,
      required this.replyMessageId,
      required this.messageText,
      required this.createdAt,
      required this.updatedAt,
      required this.story,
      required this.media,
      required this.user,
      required this.seenBy,
      required this.replyTo,
      required this.isFavourite,
      this.status});

  factory MessagesRow.fromJson(Map<String, dynamic> json) {
    return MessagesRow(
        id: json["id"],
        chatId: json["chat_id"],
        senderId: json["sender_id"],
        storyId: json["story_id"],
        type: json["type"] ?? "message",
        replyMessageId: json["reply_message_id"],
        messageText: json["message_text"],
        isFavourite: json["is_favourite"] == 1 ? true : false,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        story: json["Story"] == null ? null : Story.fromJson(json["Story"]),
        media: List<Media>.from(
            (json["media"] ?? []).map((x) => Media.fromJson(x))),
        user: ChatMessageUser.fromJson(json["User"]),
        seenBy:
            List<SeenBy>.from(json["seenBy"].map((x) => SeenBy.fromJson(x))),
        replyTo:
            json["ReplyTo"] == null ? null : ReplyTo.fromJson(json["ReplyTo"]),
        status: json["media"].length > 0 ? json["media"][0]["status"] : null);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "chat_id": chatId,
        "sender_id": senderId,
        "story_id": storyId,
        "reply_message_id": replyMessageId,
        "message_text": messageText,
        "is_favourite": isFavourite,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "Story": story?.toJson(),
        "media": List<dynamic>.from(media.map((x) => x)),
        "User": user.toJson(),
        "seenBy": List<dynamic>.from(seenBy.map((x) => x)),
        "ReplyTo": replyTo?.toJson(),
      };
}

class SeenBy {
  int id;
  ChatMessageSeen chatMessageSeen;

  SeenBy({
    required this.id,
    required this.chatMessageSeen,
  });

  factory SeenBy.fromJson(Map<String, dynamic> json) => SeenBy(
        id: json["id"],
        chatMessageSeen: ChatMessageSeen.fromJson(json["ChatMessageSeen"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ChatMessageSeen": chatMessageSeen.toJson(),
      };
}

class ChatMessageSeen {
  int chatId;
  int messageId;
  int seenBy;
  DateTime seenAt;
  DateTime createdAt;
  DateTime updatedAt;

  ChatMessageSeen({
    required this.chatId,
    required this.messageId,
    required this.seenBy,
    required this.seenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessageSeen.fromJson(Map<String, dynamic> json) =>
      ChatMessageSeen(
        chatId: json["chat_id"],
        messageId: json["message_id"],
        seenBy: json["seen_by"],
        seenAt: DateTime.parse(json["seen_at"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "message_id": messageId,
        "seen_by": seenBy,
        "seen_at": seenAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Media {
  int id;
  String rank;
  int parentId;
  String path;
  String category;
  String? mimeType;
  double? size;
  dynamic width;
  dynamic height;
  String? resolution;
  String? metadata;
  String? duration;
  DateTime createdAt;
  DateTime updatedAt;
  VideoPlayerController? videoController;
  AudioPlayer? audioPlayer;

  Media({
    required this.id,
    required this.rank,
    required this.parentId,
    required this.path,
    required this.category,
    required this.mimeType,
    required this.size,
    required this.width,
    required this.height,
    required this.resolution,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.duration,
    this.audioPlayer,
    this.videoController,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json["id"],
      rank: json["rank"],
      parentId: json["parent_id"],
      path: json["path"],
      category: json["category"],
      mimeType: json["mime_type"],
      size: json["size"]?.toDouble(),
      width: json["width"],
      height: json["height"],
      resolution: json["resolution"],
      metadata: json["metadata"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      audioPlayer: json["category"] == 'audio'
          ? (AudioPlayer()..setUrl(ApiStrings.s3ImageUrl + json["path"]))
          : null,
      videoController: json["category"] == 'video'
          ? VideoPlayerController.network(ApiStrings.s3ImageUrl + json["path"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "rank": rank,
        "parent_id": parentId,
        "path": path,
        "category": category,
        "mime_type": mimeType,
        "size": size,
        "width": width,
        "height": height,
        "resolution": resolution,
        "metadata": metadata,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class StoryUser {
  int id;
  dynamic email;
  dynamic mobile;
  Profile profile;

  StoryUser({
    required this.id,
    required this.email,
    required this.mobile,
    required this.profile,
  });

  factory StoryUser.fromJson(Map<String, dynamic> json) => StoryUser(
        id: json["id"],
        email: json["email"],
        mobile: json["mobile"],
        profile: Profile.fromJson(json["Profile"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "mobile": mobile,
        "Profile": profile.toJson(),
      };
}

class ReplyTo {
  int id;
  int chatId;
  int senderId;
  dynamic storyId;
  dynamic replyMessageId;
  String? messageText;
  DateTime createdAt;
  DateTime updatedAt;
  StoryUser user;

  ReplyTo({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.storyId,
    required this.replyMessageId,
    required this.messageText,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory ReplyTo.fromJson(Map<String, dynamic> json) => ReplyTo(
        id: json["id"],
        chatId: json["chat_id"],
        senderId: json["sender_id"],
        storyId: json["story_id"],
        replyMessageId: json["reply_message_id"],
        messageText: json["message_text"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        user: StoryUser.fromJson(json["User"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "chat_id": chatId,
        "sender_id": senderId,
        "story_id": storyId,
        "reply_message_id": replyMessageId,
        "message_text": messageText,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "User": user.toJson(),
      };
}

class ChatMessageUser {
  int id;
  String? email;
  dynamic mobile;
  UserProfile? profile;
  List<Chats> chats;

  ChatMessageUser({
    required this.id,
    required this.email,
    required this.mobile,
    required this.profile,
    required this.chats,
  });

  factory ChatMessageUser.fromJson(Map<String, dynamic> json) =>
      ChatMessageUser(
        id: json["id"],
        email: json["email"],
        mobile: json["mobile"],
        profile: json["Profile"] == null
            ? null
            : UserProfile.fromJson(json["Profile"]),
        chats: json["Chats"] == null
            ? []
            : List<Chats>.from(json["Chats"].map((x) => Chats.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "mobile": mobile,
        "Profile": profile?.toJson(),
      };
}

class Chats {
  int id;
  List<UserData> users;
  ChatUser chatUser;

  Chats({
    required this.id,
    required this.users,
    required this.chatUser,
  });

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        id: json["id"],
        users: json["Users"] != null
            ? List<UserData>.from(
                json["Users"].map((x) => UserData.fromJson(x)),
              )
            : [],
        chatUser: ChatUser.fromJson(json["ChatUser"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Users": List<dynamic>.from(users.map((x) => x.toJson())),
        "ChatUser": chatUser.toJson(),
      };
}
