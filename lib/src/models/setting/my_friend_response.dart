// To parse this JSON data, do
//
//     final myFriendsResponse = myFriendsResponseFromJson(jsonString);

import 'dart:convert';

MyFriendsResponse myFriendsResponseFromJson(String str) =>
    MyFriendsResponse.fromJson(json.decode(str));

String myFriendsResponseToJson(MyFriendsResponse data) =>
    json.encode(data.toJson());

class MyFriendsResponse {
  String status;
  String message;
  Data data;
  int statusCode;

  MyFriendsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory MyFriendsResponse.fromJson(Map<String, dynamic> json) =>
      MyFriendsResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}

class Data {
  int count;
  List<Friend> rows;

  Data({
    required this.count,
    required this.rows,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        count: json["count"],
        rows: List<Friend>.from(json["rows"].map((x) => Friend.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
      };
}

class Friend {
  int followerId;
  int followingId;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  int id;
  int closerrrDays;
  Following following;

  Friend({
    required this.followerId,
    required this.followingId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.closerrrDays,
    required this.following,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        followerId: json["follower_id"],
        followingId: json["following_id"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        id: json["id"],
        closerrrDays: json["closerrr_days"],
        following: Following.fromJson(json["Following"]),
      );

  Map<String, dynamic> toJson() => {
        "follower_id": followerId,
        "following_id": followingId,
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "id": id,
        "closerrr_days": closerrrDays,
        "Following": following.toJson(),
      };
}

class Following {
  int id;
  String email;
  dynamic mobile;
  Profile profile;
  List<Chat> chats;

  Following({
    required this.id,
    required this.email,
    required this.mobile,
    required this.profile,
    required this.chats,
  });

  factory Following.fromJson(Map<String, dynamic> json) => Following(
        id: json["id"],
        email: json["email"],
        mobile: json["mobile"],
        profile: Profile.fromJson(json["Profile"]),
        chats: List<Chat>.from(json["Chats"].map((x) => Chat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "mobile": mobile,
        "Profile": profile.toJson(),
        "Chats": List<dynamic>.from(chats.map((x) => x.toJson())),
      };
}

class Chat {
  int id;
  ChatUser chatUser;

  Chat({
    required this.id,
    required this.chatUser,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"],
        chatUser: ChatUser.fromJson(json["ChatUser"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ChatUser": chatUser.toJson(),
      };
}

class ChatUser {
  int chatId;
  int userId;
  bool isAdmin;
  dynamic friendName;
  dynamic yourNickname;
  String chatBackground;
  DateTime createdAt;
  DateTime updatedAt;

  ChatUser({
    required this.chatId,
    required this.userId,
    required this.isAdmin,
    required this.friendName,
    required this.yourNickname,
    this.chatBackground = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        chatId: json["chat_id"],
        userId: json["user_id"],
        isAdmin: json["is_admin"],
        friendName: json["friend_name"],
        yourNickname: json["your_nickname"],
        chatBackground: json["chat_background"] ?? '',
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "user_id": userId,
        "is_admin": isAdmin,
        "friend_name": friendName,
        "your_nickname": yourNickname,
        "chat_background": chatBackground,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Profile {
  int id;
  String username;
  String? fullname;
  String? profilePic;

  Profile({
    required this.id,
    required this.username,
    this.fullname,
    required this.profilePic,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        username: json["username"],
        fullname: json["fullname"],
        profilePic: json["profile_pic"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "fullname": fullname,
        "profile_pic": profilePic,
      };
}
