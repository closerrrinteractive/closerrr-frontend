import 'package:closerrr/core/utils/api_string.dart';
import 'package:get/get.dart';

class ChatModel {
  String status;
  String message;
  ChatData data;
  int statusCode;

  ChatModel({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      status: json["status"],
      message: json["message"],
      data: ChatData.fromJson(json["data"]),
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

class ChatData {
  int count;
  List<ChatRowData> rows;

  ChatData({
    required this.count,
    required this.rows,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) => ChatData(
        count: json["count"],
        rows: List<ChatRowData>.from(
            json["rows"].map((x) => ChatRowData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
      };
}

class ChatRowData {
  int id;
  String type;
  RxString? groupName;
  String? groupDescription;
  RxString? groupIcon;
  DateTime createdAt;
  DateTime updatedAt;
  RxInt unreadCount;
  RxInt storyCount;
  int closerrrDays;
  RxBool? isFavourite;
  RxBool? isMute;
  List<UserData> users;
  RxList<LastMessage> lastMessage;

  ChatRowData(
      {required this.id,
      required this.type,
      required this.groupName,
      required this.groupDescription,
      required this.groupIcon,
      required this.createdAt,
      required this.updatedAt,
      required this.unreadCount,
      required this.storyCount,
      required this.closerrrDays,
      this.isFavourite,
      this.isMute,
      required this.users,
      required this.lastMessage});

  factory ChatRowData.fromJson(Map<String, dynamic> json) {
    return ChatRowData(
      id: json["id"],
      type: json["type"],
      groupName:
          (json["group_name"] != null ? RxString(json["group_name"]) : null),
      groupDescription: json["group_description"],
      groupIcon:
          json["group_icon"] != null ? RxString(json["group_icon"]) : null,
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      unreadCount: RxInt(json["unreadCount"]),
      storyCount: RxInt(json["storyCount"]),
      closerrrDays: json["closerrr_days"],
      isFavourite: RxBool(json["is_favourite"] == 0 ? false : true),
      isMute: RxBool(json["is_mute"] == 0 ? false : true),
      users:
          List<UserData>.from(json["Users"].map((x) => UserData.fromJson(x))),
      lastMessage: (json["lastMessage"] as List? ?? [])
          .map((x) => LastMessage.fromJson(x))
          .toList()
          .obs,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "group_name": groupName?.value,
        "group_description": groupDescription,
        "group_icon": groupIcon,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "unreadCount": unreadCount.value,
        "storyCount": storyCount.value,
        "closerrr_days": closerrrDays,
        "is_favourite": isFavourite?.value,
        "is_mute": isMute?.value,
        "Users": List<dynamic>.from(users.map((x) => x.toJson())),
        "lastMessage": List<dynamic>.from(lastMessage.map((x) => x.toJson())),
      };
}

class LiveStreamM {
  int id;
  int user_id;
  String? live_stream_id;
  int chat_id;
  String? host_name;
  String? host_profile_pic;
  String? title;
  String? description;
  String status;
  String? save_path;
  DateTime started_at;
  DateTime? ended_at;
  DateTime createdAt;
  DateTime updatedAt;

  LiveStreamM({
    required this.id,
    required this.user_id,
    this.live_stream_id,
    required this.chat_id,
    this.host_name,
    this.host_profile_pic,
    this.title,
    this.description,
    required this.status,
    this.save_path,
    required this.started_at,
    this.ended_at,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveStreamM.fromJson(Map<String, dynamic> json) => LiveStreamM(
        id: json["id"],
        live_stream_id: json["live_stream_id"],
        chat_id: json["chat_id"],
        user_id: json["user_id"],
        host_name: json["host_name"],
        host_profile_pic: json["host_profile_pic"],
        title: json["title"],
        description: json["description"],
        status: json["status"],
        save_path: json["save_path"],
        started_at: DateTime.parse(json["started_at"]),
        ended_at:
            json["ended_at"] != null ? DateTime.parse(json["ended_at"]) : null,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );
}

class LastMessage {
  int id;
  int chatId;
  int senderId;
  dynamic storyId;
  dynamic replyMessageId;
  String? messageText;
  Rx<DateTime> createdAt;
  Rx<DateTime> updatedAt;
  LastMessageUser user;

  LastMessage({
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

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json["id"],
      chatId: json["chat_id"],
      senderId: json["sender_id"],
      storyId: json["story_id"],
      replyMessageId: json["reply_message_id"],
      messageText: json["message_text"],
      createdAt: DateTime.parse(json["createdAt"]).obs,
      updatedAt: DateTime.parse(json["updatedAt"]).obs,
      user: LastMessageUser.fromJson(json["User"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "chat_id": chatId,
        "sender_id": senderId,
        "story_id": storyId,
        "reply_message_id": replyMessageId,
        "message_text": messageText,
        "createdAt": createdAt.value.toIso8601String(),
        "updatedAt": updatedAt.value.toIso8601String(),
        "User": user.toJson(),
      };
}

class LastMessageUser {
  int id;
  String email;
  dynamic mobile;
  dynamic userId;
  UserProfile profile;

  LastMessageUser({
    required this.id,
    required this.email,
    required this.mobile,
    required this.userId,
    required this.profile,
  });

  factory LastMessageUser.fromJson(Map<String, dynamic> json) =>
      LastMessageUser(
        id: json["id"],
        email: json["email"],
        mobile: json["mobile"],
        userId: json["user_id"],
        profile: UserProfile.fromJson(json["Profile"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "mobile": mobile,
        "user_id": userId,
        "Profile": profile.toJson(),
      };
}

class UserProfile {
  int? id;
  String? username;
  String? fullname;
  String? profilePic;
  String? bannerPic;

  UserProfile({
    this.id,
    this.username,
    this.fullname,
    this.profilePic,
    this.bannerPic,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"],
        username: json["username"],
        fullname: json["fullname"],
        profilePic: json["profile_pic"],
        bannerPic: json["banner_pic"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "fullname": fullname,
        "profile_pic": profilePic,
        "banner_pic": bannerPic,
      };
}

class UserData {
  int id;
  dynamic userId;
  UserProfile? profile;
  ChatUser chatUser;
  RxList<LiveStreamM>? liveStreams;

  UserData({
    required this.id,
    required this.userId,
    required this.profile,
    required this.chatUser,
    required this.liveStreams,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
        id: json["id"],
        userId: json["user_id"],
        profile: json["Profile"] == null
            ? null
            : UserProfile.fromJson(json["Profile"]),
        chatUser: ChatUser.fromJson(json["ChatUser"]),
        liveStreams: (json["LiveStreams"] != null
            ? (json["LiveStreams"] as List)
                .map((x) => LiveStreamM.fromJson(x))
                .toList()
                .obs
            : null));
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "Profile": profile?.toJson(),
        "ChatUser": chatUser.toJson(),
      };
}

class ChatUser {
  int chatId;
  int userId;
  bool isAdmin;
  RxString? friendName;
  dynamic bio;
  dynamic nickname;
  String? chatBackground;
  DateTime createdAt;
  DateTime updatedAt;

  ChatUser({
    required this.chatId,
    required this.userId,
    required this.isAdmin,
    required this.friendName,
    required this.nickname,
    required this.bio,
    required this.chatBackground,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        chatId: json["chat_id"],
        userId: json["user_id"],
        isAdmin: json["is_admin"],
        friendName: RxString((json["friend_name"] ?? '').toString()),
        bio: json["bio"],
        nickname: json["your_nickname"],
        chatBackground: ApiStrings.s3ImageUrl + (json["chat_background"] ?? ''),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "user_id": userId,
        "is_admin": isAdmin,
        "friend_name": friendName,
        "bio": bio,
        "your_nickname": nickname,
        "chat_background": chatBackground,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
