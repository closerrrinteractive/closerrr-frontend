// To parse this JSON data, do
//
//     final closerrrUser = closerrrUserFromJson(jsonString);

import 'dart:convert';

CloserUser closerrrUserFromJson(String str) =>
    CloserUser.fromJson(json.decode(str));

String closerrrUserToJson(CloserUser data) => json.encode(data.toJson());

class CloserUser {
  String status;
  String message;
  User data;
  int statusCode;

  CloserUser({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory CloserUser.fromJson(Map<String, dynamic> json) => CloserUser(
        status: json["status"],
        message: json["message"],
        data: User.fromJson(json["data"]),
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}

class User {
  int id;
  String email;
  dynamic mobile;
  String password;
  dynamic userId;
  bool isEmailVerified;
  bool isMobileVerified;
  int roleId;
  dynamic signInType;
  bool isOnboarded;
  DateTime createdAt;
  DateTime updatedAt;
  Profile profile;
  String accessToken;
  String refreshToken;

  User({
    required this.id,
    required this.email,
    required this.mobile,
    required this.password,
    required this.userId,
    required this.isEmailVerified,
    required this.isMobileVerified,
    required this.roleId,
    required this.signInType,
    required this.isOnboarded,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        mobile: json["mobile"],
        password: json["password"],
        userId: json["user_id"],
        isEmailVerified: json["is_email_verified"],
        isMobileVerified: json["is_mobile_verified"],
        roleId: json["role_id"],
        signInType: json["sign_in_type"],
        isOnboarded: json["is_onboarded"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        profile: Profile.fromJson(json["Profile"]),
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
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
        "sign_in_type": signInType,
        "is_onboarded": isOnboarded,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "Profile": profile.toJson(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

class Profile {
  int id;
  String username;
  dynamic profilePic;
  dynamic bannerPic;
  dynamic bio;
  dynamic gender;
  dynamic address;
  dynamic birthday;
  int userId;
  DateTime createdAt;
  DateTime updatedAt;

  Profile({
    required this.id,
    required this.username,
    required this.profilePic,
    required this.bannerPic,
    required this.bio,
    required this.gender,
    required this.address,
    required this.birthday,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        username: json["username"],
        profilePic: json["profile_pic"],
        bannerPic: json["banner_pic"],
        bio: json["bio"],
        gender: json["gender"],
        address: json["address"],
        birthday: json["birthday"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "profile_pic": profilePic,
        "banner_pic": bannerPic,
        "bio": bio,
        "gender": gender,
        "address": address,
        "birthday": birthday,
        "user_id": userId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
