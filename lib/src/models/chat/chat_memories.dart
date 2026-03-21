import 'package:closerrr/src/models/chat/chat_messages_model.dart';

class ChatMemories {
  String status;
  String message;
  List<MemoriesData> data;
  int statusCode;

  ChatMemories({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory ChatMemories.fromJson(Map<String, dynamic> json) {
    return ChatMemories(
      status: json["status"],
      message: json["message"],
      data: json["data"] != null
          ? List<MemoriesData>.from(
              json["data"].map((x) => MemoriesData.fromJson(x)))
          : [],
      statusCode: json["statusCode"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "statusCode": statusCode,
      };
}

class MemoriesData {
  int id;
  int chatId;
  int senderId;
  dynamic storyId;
  dynamic replyMessageId;
  String? messageText;
  DateTime createdAt;
  DateTime updatedAt;
  List<Media> media;
  ChatMemoriesUser user;

  MemoriesData({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.storyId,
    required this.replyMessageId,
    required this.messageText,
    required this.createdAt,
    required this.updatedAt,
    required this.media,
    required this.user,
  });

  factory MemoriesData.fromJson(Map<String, dynamic> json) {
    return MemoriesData(
      id: json["id"],
      chatId: json["chat_id"],
      senderId: json["sender_id"],
      storyId: json["story_id"],
      replyMessageId: json["reply_message_id"],
      messageText: json["message_text"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      media: json['media'] != null
          ? List<Media>.from(json["media"].map((x) => Media.fromJson(x)))
          : [],
      user: ChatMemoriesUser.fromJson(json["User"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "chat_id": chatId,
        "sender_id": senderId,
        "story_id": storyId,
        "reply_message_id": replyMessageId,
        "message_text": messageText,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "media": List<dynamic>.from(media.map((x) => x)),
        "User": user.toJson(),
      };
}

class ChatMemoriesUser {
  int id;
  dynamic userId;
  Profile profile;

  ChatMemoriesUser({
    required this.id,
    required this.userId,
    required this.profile,
  });

  factory ChatMemoriesUser.fromJson(Map<String, dynamic> json) =>
      ChatMemoriesUser(
        id: json["id"],
        userId: json["user_id"],
        profile: Profile.fromJson(json["Profile"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "Profile": profile.toJson(),
      };
}

class Profile {
  int id;
  String username;
  String? fullname;
  dynamic profilePic;
  dynamic bannerPic;

  Profile({
    required this.id,
    required this.username,
    required this.fullname,
    required this.profilePic,
    required this.bannerPic,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
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
