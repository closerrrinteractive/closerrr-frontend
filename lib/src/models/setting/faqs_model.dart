class FaQs {
  String status;
  String message;
  Data data;
  int statusCode;

  FaQs({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory FaQs.fromJson(Map<String, dynamic> json) => FaQs(
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
  List<FAQData> rows;

  Data({
    required this.count,
    required this.rows,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        count: json["count"],
        rows: List<FAQData>.from(json["rows"].map((x) => FAQData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
      };
}

class FAQData {
  int id;
  int categoryId;
  String question;
  String answer;
  int displayOrder;
  bool isActive;
  DateTime rowCreatedAt;
  DateTime rowUpdatedAt;
  DateTime createdAt;
  DateTime updatedAt;
  FaqCategory faqCategory;

  FAQData({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answer,
    required this.displayOrder,
    required this.isActive,
    required this.rowCreatedAt,
    required this.rowUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.faqCategory,
  });

  factory FAQData.fromJson(Map<String, dynamic> json) => FAQData(
        id: json["id"],
        categoryId: json["category_id"],
        question: json["question"],
        answer: json["answer"],
        displayOrder: json["display_order"],
        isActive: json["is_active"],
        rowCreatedAt: DateTime.parse(json["created_at"]),
        rowUpdatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        faqCategory: FaqCategory.fromJson(json["FaqCategory"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "question": question,
        "answer": answer,
        "display_order": displayOrder,
        "is_active": isActive,
        "created_at": rowCreatedAt.toIso8601String(),
        "updated_at": rowUpdatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "FaqCategory": faqCategory.toJson(),
      };
}

class FaqCategory {
  int id;
  String name;
  String description;
  int displayOrder;
  bool isActive;
  DateTime faqCategoryCreatedAt;
  DateTime faqCategoryUpdatedAt;
  DateTime createdAt;
  DateTime updatedAt;

  FaqCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.displayOrder,
    required this.isActive,
    required this.faqCategoryCreatedAt,
    required this.faqCategoryUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaqCategory.fromJson(Map<String, dynamic> json) => FaqCategory(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        displayOrder: json["display_order"],
        isActive: json["is_active"],
        faqCategoryCreatedAt: DateTime.parse(json["created_at"]),
        faqCategoryUpdatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "display_order": displayOrder,
        "is_active": isActive,
        "created_at": faqCategoryCreatedAt.toIso8601String(),
        "updated_at": faqCategoryUpdatedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
