class TranscationHistory {
  String status;
  String message;
  Data data;
  int statusCode;

  TranscationHistory({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory TranscationHistory.fromJson(Map<String, dynamic> json) =>
      TranscationHistory(
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
  List<Row> rows;
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
        rows: List<Row>.from(json["rows"].map((x) => Row.fromJson(x))),
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

class Row {
  int id;
  String transferId;
  int userId;
  int beneficiaryId;
  String cfTransferId;
  DateTime payoutFor;
  DateTime payoutDate;
  String status;
  String statusCode;
  String statusDescription;
  String currency;
  String transferAmount;
  String transferMode;
  int activeSubscribers;
  String growthRate;
  int tier;
  int androidSubscribers;
  int iosSubscribers;
  String androidAmount;
  String iosAmount;
  DateTime createdAt;
  DateTime updatedAt;

  Row({
    required this.id,
    required this.transferId,
    required this.userId,
    required this.beneficiaryId,
    required this.cfTransferId,
    required this.payoutFor,
    required this.payoutDate,
    required this.status,
    required this.statusCode,
    required this.statusDescription,
    required this.currency,
    required this.transferAmount,
    required this.transferMode,
    required this.activeSubscribers,
    required this.growthRate,
    required this.tier,
    required this.androidSubscribers,
    required this.iosSubscribers,
    required this.androidAmount,
    required this.iosAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Row.fromJson(Map<String, dynamic> json) => Row(
        id: json["id"],
        transferId: json["transfer_id"],
        userId: json["user_id"],
        beneficiaryId: json["beneficiary_id"],
        cfTransferId: json["cf_transfer_id"],
        payoutFor: DateTime.parse(json["payout_for"]),
        payoutDate: DateTime.parse(json["payout_date"]),
        status: json["status"],
        statusCode: json["status_code"],
        statusDescription: json["status_description"],
        currency: json["currency"],
        transferAmount: json["transfer_amount"],
        transferMode: json["transfer_mode"],
        activeSubscribers: json["active_subscribers"],
        growthRate: json["growth_rate"],
        tier: json["tier"],
        androidSubscribers: json["android_subscribers"],
        iosSubscribers: json["ios_subscribers"],
        androidAmount: json["android_amount"],
        iosAmount: json["ios_amount"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "transfer_id": transferId,
        "user_id": userId,
        "beneficiary_id": beneficiaryId,
        "cf_transfer_id": cfTransferId,
        "payout_for": payoutFor.toIso8601String(),
        "payout_date": payoutDate.toIso8601String(),
        "status": status,
        "status_code": statusCode,
        "status_description": statusDescription,
        "currency": currency,
        "transfer_amount": transferAmount,
        "transfer_mode": transferMode,
        "active_subscribers": activeSubscribers,
        "growth_rate": growthRate,
        "tier": tier,
        "android_subscribers": androidSubscribers,
        "ios_subscribers": iosSubscribers,
        "android_amount": androidAmount,
        "ios_amount": iosAmount,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
