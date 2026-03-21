import 'package:get/get.dart';

class Influencers {
  String status;
  String message;
  Data data;
  int statusCode;

  Influencers({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory Influencers.fromJson(Map<String, dynamic> json) => Influencers(
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
  List<Influencer> rows;
  int currentPage;
  int limit;

  Data({
    required this.count,
    required this.rows,
    required this.currentPage,
    required this.limit,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        count: json["count"],
        rows: List<Influencer>.from(
            json["rows"].map((x) => Influencer.fromJson(x))),
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

class Influencer {
  int id;
  String? email;
  dynamic mobile;
  RxBool isFriend;
  Profile? profile;
  // List<Follower> followers;
  // List<dynamic> following;

  Influencer({
    required this.id,
    this.email,
    required this.mobile,
    required this.profile,
    required bool isFriend,
  }) : isFriend = isFriend.obs;

  factory Influencer.fromJson(Map<String, dynamic> json) {
    return Influencer(
      id: json["id"],
      email: json["email"],
      mobile: json["mobile"],
      isFriend: (json["is_friend"] is int)
          ? json["is_friend"] == 1
              ? true
              : false
          : json['is_friend'],
      profile: json["Profile"] == null
          ? null
          : Profile.fromJson(
              json["Profile"],
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "mobile": mobile,
        "is_friend": isFriend.value,
        "Profile": profile?.toJson(),
        // "Followers": List<dynamic>.from(followers.map((x) => x.toJson())),
        // "Following": List<dynamic>.from(following.map((x) => x)),
      };
}

class Follower {
  int id;
  String email;
  String mobile;
  Profile profile;
  Friendship friendship;

  Follower({
    required this.id,
    required this.email,
    required this.mobile,
    required this.profile,
    required this.friendship,
  });

  factory Follower.fromJson(Map<String, dynamic> json) => Follower(
        id: json["id"],
        email: json["email"],
        mobile: json["mobile"],
        profile: Profile.fromJson(json["Profile"]),
        friendship: Friendship.fromJson(json["Friendship"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "mobile": mobile,
        "Profile": profile.toJson(),
        "Friendship": friendship.toJson(),
      };
}

class Friendship {
  int followerId;
  int followingId;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  Friendship({
    required this.followerId,
    required this.followingId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) => Friendship(
        followerId: json["follower_id"],
        followingId: json["following_id"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "follower_id": followerId,
        "following_id": followingId,
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Profile {
  int id;
  int? userId;
  String username;
  String? fullname;
  String? description;
  dynamic profilePic;

  Profile({
    required this.id,
    this.userId,
    required this.username,
    this.fullname,
    this.description,
    required this.profilePic,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        userId: json["user_id"],
        username: json["username"],
        fullname: json["fullname"],
        description: json["description"],
        profilePic: json["profile_pic"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "username": username,
        "fullname": fullname,
        "description": description,
        "profile_pic": profilePic,
      };
}
