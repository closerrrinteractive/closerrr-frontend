// To parse required this JSON data, do
//
//     final subscriptionAnalytics = subscriptionAnalyticsFromJson(jsonString);

import 'dart:convert';

SubscriptionAnalytics subscriptionAnalyticsFromJson(String str) =>
    SubscriptionAnalytics.fromJson(json.decode(str));

String subscriptionAnalyticsToJson(SubscriptionAnalytics data) =>
    json.encode(data.toJson());

class SubscriptionAnalytics {
  final String status;
  final String message;
  final List<AnalyticsData> data;
  final int statusCode;

  SubscriptionAnalytics({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory SubscriptionAnalytics.fromJson(Map<String, dynamic> json) =>
      SubscriptionAnalytics(
        status: json["status"],
        message: json["message"],
        data: List<AnalyticsData>.from(json["data"].map((x) => AnalyticsData.fromJson(x))),
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "statusCode": statusCode,
      };
}

class AnalyticsData {
  final int influencerId;
  final int totalSubscriberAndroid;
  final int totalSubscriberIos;
  final int totalPayoutAndroid;
  final int totalPayoutIos;

  AnalyticsData({
    required this.influencerId,
    required this.totalSubscriberAndroid,
    required this.totalSubscriberIos,
    required this.totalPayoutAndroid,
    required this.totalPayoutIos,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => AnalyticsData(
        influencerId: json["influencer_id"],
        totalSubscriberAndroid: json["total_subscriber_android"],
        totalSubscriberIos: json["total_subscriber_ios"],
        totalPayoutAndroid: json["total_payout_android"],
        totalPayoutIos: json["total_payout_ios"],
      );

  Map<String, dynamic> toJson() => {
        "influencer_id": influencerId,
        "total_subscriber_android": totalSubscriberAndroid,
        "total_subscriber_ios": totalSubscriberIos,
        "total_payout_android": totalPayoutAndroid,
        "total_payout_ios": totalPayoutIos,
      };
}
