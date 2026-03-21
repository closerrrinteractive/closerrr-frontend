// To parse this JSON data, do
//
//     final storyModel = storyModelFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';

StoryModel storyModelFromJson(String str) =>
    StoryModel.fromJson(json.decode(str));

String storyModelToJson(StoryModel data) => json.encode(data.toJson());

class StoryModel {
  String status;
  String message;
  StoryData data;
  int statusCode;

  StoryModel({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        status: json["status"],
        message: json["message"],
        data: StoryData.fromJson(json["data"]),
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}

class StoryData {
  int count;
  List<StoryRow> rows;
  int currentPage;
  int limit;

  StoryData({
    required this.count,
    required this.rows,
    required this.currentPage,
    required this.limit,
  });

  factory StoryData.fromJson(Map<String, dynamic> json) => StoryData(
        count: json["count"],
        rows:
            List<StoryRow>.from(json["rows"].map((x) => StoryRow.fromJson(x))),
        currentPage: json["current_page"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
        "current_page": currentPage,
        "limit": limit,
      };
}

class StoryRow {
  int id;
  String email;
  dynamic mobile;
  String password;
  dynamic userId;
  bool isEmailVerified;
  bool isMobileVerified;
  int roleId;
  dynamic fcmToken;
  dynamic streamToken;
  dynamic signInType;
  bool isOnboarded;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime lastStoryDate;
  List<Story> stories;

  StoryRow({
    required this.id,
    required this.email,
    required this.mobile,
    required this.password,
    required this.userId,
    required this.isEmailVerified,
    required this.isMobileVerified,
    required this.roleId,
    required this.fcmToken,
    required this.streamToken,
    required this.signInType,
    required this.isOnboarded,
    required this.createdAt,
    required this.updatedAt,
    required this.lastStoryDate,
    required this.stories,
  });

  factory StoryRow.fromJson(Map<String, dynamic> json) => StoryRow(
        id: json["id"],
        email: json["email"],
        mobile: json["mobile"],
        password: json["password"],
        userId: json["user_id"],
        isEmailVerified: json["is_email_verified"],
        isMobileVerified: json["is_mobile_verified"],
        roleId: json["role_id"],
        fcmToken: json["fcm_token"],
        streamToken: json["stream_token"],
        signInType: json["sign_in_type"],
        isOnboarded: json["is_onboarded"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        lastStoryDate: DateTime.parse(json["lastStoryDate"]),
        stories:
            List<Story>.from(json["Stories"].map((x) => Story.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "mobile": mobile,
        "password": password,
        "user_id": userId,
        "is_email_verified": isEmailVerified,
        "is_mobile_verified": isMobileVerified,
        "role_id": roleId,
        "fcm_token": fcmToken,
        "stream_token": streamToken,
        "sign_in_type": signInType,
        "is_onboarded": isOnboarded,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "lastStoryDate": lastStoryDate.toIso8601String(),
        "Stories": List<dynamic>.from(stories.map((x) => x.toJson())),
      };
}

class Story {
  int id;
  dynamic text;
  int userId;
  int likeCount;
  String mediaType;
  dynamic mediaPath;
  dynamic mediaMimeType;
  dynamic mediaSize;
  RxBool isLiked;
  dynamic mediaMetadata;
  DateTime createdAt;
  DateTime updatedAt;

  Story({
    required this.id,
    required this.text,
    required this.userId,
    required this.mediaType,
    required this.mediaPath,
    required this.mediaMimeType,
    required this.mediaSize,
    required this.mediaMetadata,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
    required this.likeCount,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json["id"],
      text: json["text"],
      userId: json["user_id"],
      mediaType: json["media_type"],
      mediaPath: json["media_path"],
      mediaMimeType: json["media_mime_type"],
      mediaSize: json["media_size"],
      mediaMetadata: json["media_metadata"],
      likeCount: json["likeCount"] ?? 0,
      isLiked: json["is_like"] != null
          ? json["is_like"] == 0
              ? false.obs
              : true.obs
          : false.obs,
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "user_id": userId,
        "media_type": mediaType,
        "media_path": mediaPath,
        "media_mime_type": mediaMimeType,
        "media_size": mediaSize,
        "is_like": isLiked,
        "media_metadata": mediaMetadata,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
