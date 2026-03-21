class GetAllFriendsResponse {
  String status;
  String message;
  Data data;
  int statusCode;

  GetAllFriendsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory GetAllFriendsResponse.fromJson(Map<String, dynamic> json) =>
      GetAllFriendsResponse(
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
  int id;
  String email;
  dynamic mobile;
  Profile profile;

  Friend({
    required this.id,
    required this.email,
    required this.mobile,
    required this.profile,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
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

class Profile {
  int id;
  String username;
  String? fullname;
  dynamic profilePic;

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
