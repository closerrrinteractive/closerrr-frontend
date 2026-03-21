class PayoutUpcomming {
  String status;
  String message;
  Data data;
  int statusCode;

  PayoutUpcomming({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory PayoutUpcomming.fromJson(Map<String, dynamic> json) =>
      PayoutUpcomming(
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
  String payoutFor;
  DateTime payoutDate;
  String totalAmount;
  int activeSubscribers;
  String growthRate;
  int tier;
  PlatformBreakdown platformBreakdown;

  Data({
    required this.payoutFor,
    required this.payoutDate,
    required this.totalAmount,
    required this.activeSubscribers,
    required this.growthRate,
    required this.tier,
    required this.platformBreakdown,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        payoutFor: json["payout_for"],
        payoutDate: DateTime.parse(json["payout_date"]),
        totalAmount: json["total_amount"],
        activeSubscribers: json["active_subscribers"],
        growthRate: json["growth_rate"],
        tier: json["tier"],
        platformBreakdown:
            PlatformBreakdown.fromJson(json["platform_breakdown"]),
      );

  Map<String, dynamic> toJson() => {
        "payout_for": payoutFor,
        "payout_date":
            "${payoutDate.year.toString().padLeft(4, '0')}-${payoutDate.month.toString().padLeft(2, '0')}-${payoutDate.day.toString().padLeft(2, '0')}",
        "total_amount": totalAmount,
        "active_subscribers": activeSubscribers,
        "growth_rate": growthRate,
        "tier": tier,
        "platform_breakdown": platformBreakdown.toJson(),
      };
}

class PlatformBreakdown {
  Android android;
  Android ios;

  PlatformBreakdown({
    required this.android,
    required this.ios,
  });

  factory PlatformBreakdown.fromJson(Map<String, dynamic> json) =>
      PlatformBreakdown(
        android: Android.fromJson(json["android"]),
        ios: Android.fromJson(json["ios"]),
      );

  Map<String, dynamic> toJson() => {
        "android": android.toJson(),
        "ios": ios.toJson(),
      };
}

class Android {
  int subscribers;
  String amount;

  Android({
    required this.subscribers,
    required this.amount,
  });

  factory Android.fromJson(Map<String, dynamic> json) => Android(
        subscribers: json["subscribers"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "subscribers": subscribers,
        "amount": amount,
      };
}
