class FaqCategories {
  String status;
  String message;
  Data data;
  int statusCode;

  FaqCategories({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory FaqCategories.fromJson(Map<String, dynamic> json) => FaqCategories(
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
  List<FAQCategory> rows;

  Data({
    required this.count,
    required this.rows,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        count: json["count"],
        rows: List<FAQCategory>.from(json["rows"].map((x) => FAQCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
      };
}

class FAQCategory {
  int id;
  String name;
  String description;
  int displayOrder;
  bool isActive;
  DateTime rowCreatedAt;
  DateTime rowUpdatedAt;
  DateTime createdAt;
  DateTime updatedAt;

  FAQCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.displayOrder,
    required this.isActive,
    required this.rowCreatedAt,
    required this.rowUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQCategory.fromJson(Map<String, dynamic> json) => FAQCategory(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        displayOrder: json["display_order"],
        isActive: json["is_active"],
        rowCreatedAt: DateTime.parse(json["created_at"]),
        rowUpdatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "display_order": displayOrder,
        "is_active": isActive,
        "created_at": rowCreatedAt.toIso8601String(),
        "updated_at": rowUpdatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
