class UserNotifications {
  String status;
  String message;
  SettingNotification data;
  int statusCode;

  UserNotifications({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory UserNotifications.fromJson(Map<String, dynamic> json) =>
      UserNotifications(
        status: json["status"],
        message: json["message"],
        data: SettingNotification.fromJson(json["data"]),
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}

class SettingNotification {
  int id;
  dynamic fanId;
  int influencerId;
  bool messagesEnabled;
  bool storiesEnabled;
  bool eventsEnabled;
  bool callsEnabled;
  bool liveStreamEnabled;
  dynamic notificationTone;
  dynamic callTone;
  DateTime createdAt;
  DateTime updatedAt;

  SettingNotification({
    required this.id,
    required this.fanId,
    required this.influencerId,
    required this.messagesEnabled,
    required this.storiesEnabled,
    required this.eventsEnabled,
    required this.callsEnabled,
    required this.liveStreamEnabled,
    required this.notificationTone,
    required this.callTone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SettingNotification.fromJson(Map<String, dynamic> json) =>
      SettingNotification(
        id: json["id"],
        fanId: json["fan_id"],
        influencerId: json["influencer_id"],
        messagesEnabled: json["messages_enabled"],
        storiesEnabled: json["stories_enabled"],
        eventsEnabled: json["events_enabled"],
        callsEnabled: json["calls_enabled"],
        liveStreamEnabled: json["live_stream_enabled"],
        notificationTone: json["notification_tone"],
        callTone: json["call_tone"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fan_id": fanId,
        "influencer_id": influencerId,
        "messages_enabled": messagesEnabled,
        "stories_enabled": storiesEnabled,
        "events_enabled": eventsEnabled,
        "calls_enabled": callsEnabled,
        "live_stream_enabled": liveStreamEnabled,
        "notification_tone": notificationTone,
        "call_tone": callTone,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
