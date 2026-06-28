import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/models/events/get_all_friends.dart';

class EventsResponse {
  String status;
  String message;
  Data data;
  int statusCode;

  EventsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) => EventsResponse(
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
  List<Events> rows;

  Data({
    required this.count,
    required this.rows,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        count: json["count"],
        rows: List<Events>.from(json["rows"].map((x) => Events.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
      };
}

class Events {
  int id;
  String name;
  DateTime time;
  String venue;
  String? details;
  String? image;
  int userId;
  DateTime createdAt;
  DateTime updatedAt;
  User? user;

  Events({
    required this.id,
    required this.name,
    required this.time,
    required this.venue,
    required this.details,
    required this.image,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Events.fromJson(Map<String, dynamic> json) => Events(
        id: json["id"],
        name: json["name"],
        time: DateTime.parse(json["time"]),
        venue: json["venue"],
        details: json["details"],
        image: ApiStrings.imageUrl +
            ((json["image"] ?? '').split('amazonaws.com/').last),
        userId: json["user_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        user: json["User"] != null ? User.fromJson(json["User"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "time": time.toIso8601String(),
        "venue": venue,
        "details": details,
        "image": image,
        "user_id": userId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "User": user!.toJson(),
      };

  String getEventPoster(String? currentUserProfilePic) {
    final bool hasNoImage = image == null || 
                            image!.isEmpty || 
                            image == ApiStrings.imageUrl || 
                            image == ApiStrings.baseUrl ||
                            image!.endsWith('amazonaws.com/') ||
                            image!.endsWith('amazonaws.com');
    if (hasNoImage) {
      final String? profilePic = user?.profile.profilePic ?? currentUserProfilePic;
      if (profilePic != null && profilePic.isNotEmpty) {
        return profilePic.startsWith('http') ? profilePic : ApiStrings.imageUrl + profilePic;
      }
    }
    return image ?? '';
  }
}

class User {
  int id;
  Profile profile;

  User({
    required this.id,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        profile: Profile.fromJson(json["Profile"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Profile": profile.toJson(),
      };
}
