class GetShowcaseResponse {
  String status;
  String message;
  List<ShowcaseData> data;
  int statusCode;

  GetShowcaseResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory GetShowcaseResponse.fromJson(Map<String, dynamic> json) =>
      GetShowcaseResponse(
        status: json["status"],
        message: json["message"],
        data: List<ShowcaseData>.from(json["data"].map((x) => ShowcaseData.fromJson(x))),
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "statusCode": statusCode,
      };
}

class ShowcaseData {
  int id;
  String rank;
  int parentId;
  String path;
  String category;
  String mimeType;
  double size;
  dynamic width;
  dynamic height;
  String resolution;
  String? metadata;
  DateTime createdAt;
  DateTime updatedAt;

  ShowcaseData({
    required this.id,
    required this.rank,
    required this.parentId,
    required this.path,
    required this.category,
    required this.mimeType,
    required this.size,
    required this.width,
    required this.height,
    required this.resolution,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShowcaseData.fromJson(Map<String, dynamic> json) => ShowcaseData(
        id: json["id"],
        rank: json["rank"],
        parentId: json["parent_id"],
        path: json["path"],
        category: json["category"],
        mimeType: json["mime_type"],
        size: json["size"]?.toDouble(),
        width: json["width"],
        height: json["height"],
        resolution: json["resolution"],
        metadata: json["metadata"] as String?,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rank": rank,
        "parent_id": parentId,
        "path": path,
        "category": category,
        "mime_type": mimeType,
        "size": size,
        "width": width,
        "height": height,
        "resolution": resolution,
        "metadata": metadata,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
