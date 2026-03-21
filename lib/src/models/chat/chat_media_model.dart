// To parse this JSON data, do
//
//     final chatMedia = chatMediaFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../../core/utils/api_string.dart';

ChatMedia chatMediaFromJson(String str) => ChatMedia.fromJson(json.decode(str));

String chatMediaToJson(ChatMedia data) => json.encode(data.toJson());

class ChatMedia {
  final String status;
  final String message;
  final MediaData data;
  final int statusCode;

  ChatMedia({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory ChatMedia.fromJson(Map<String, dynamic> json) => ChatMedia(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] != null
            ? MediaData.fromJson(json["data"])
            : MediaData(itemsPerPage: 0, count: 0, rows: []),
        statusCode: json["statusCode"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}

class MediaData {
  final int itemsPerPage;
  final int count;
  final List<MediaRow> rows;

  MediaData({
    required this.itemsPerPage,
    required this.count,
    required this.rows,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) => MediaData(
        itemsPerPage: json["itemsPerPage"] ?? 0,
        count: json["count"] ?? 0,
        rows: (json["rows"] as List? ?? []).map((x) => MediaRow.fromJson(x)).toList(),
      );

  Map<String, dynamic> toJson() => {
        "itemsPerPage": itemsPerPage,
        "count": count,
        "rows": rows.map((x) => x.toJson()).toList(),
      };
}

class MediaRow {
  final int id;
  final String rank;
  final int parentId;
  final String path;
  final String category;
  final String mimeType;
  final dynamic size;
  final dynamic width;
  final dynamic height;
  final String resolution;
  final String metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Runtime-only reactive properties
  final Rx<Uint8List?> videoThumbnail;
  final Rx<VideoPlayerController> videoController;
  final Rx<AudioPlayer> audioPlayer;

  MediaRow({
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
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.videoThumbnail,
    required this.videoController,
    required this.audioPlayer,
  });

  factory MediaRow.fromJson(Map<String, dynamic> json) {
    final path = json["path"] ?? "";
    final url = ApiStrings.s3ImageUrl + path;

    return MediaRow(
      id: json["id"] ?? 0,
      rank: json["rank"] ?? "",
      parentId: json["parent_id"] ?? 0,
      path: path,
      category: json["category"] ?? "",
      mimeType: json["mime_type"] ?? "",
      size: json["size"],
      width: json["width"],
      height: json["height"],
      resolution: json["resolution"] ?? "",
      metadata: json["metadata"] ?? "",
      createdAt:
          json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now() : DateTime.now(),
      updatedAt:
          json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) ?? DateTime.now() : DateTime.now(),
      videoThumbnail: Rx<Uint8List?>(null),
      videoController: VideoPlayerController.network(url).obs,
      audioPlayer: (AudioPlayer()..setUrl(url)).obs,
    );
  }

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

// OLD non null safe

// // To parse this JSON data, do
// //
// //     final chatMedia = chatMediaFromJson(jsonString);

// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:video_player/video_player.dart';

// import '../../../core/utils/api_string.dart';

// ChatMedia chatMediaFromJson(String str) => ChatMedia.fromJson(json.decode(str));

// String chatMediaToJson(ChatMedia data) => json.encode(data.toJson());

// class ChatMedia {
//   String status;
//   String message;
//   MediaData data;
//   int statusCode;

//   ChatMedia({
//     required this.status,
//     required this.message,
//     required this.data,
//     required this.statusCode,
//   });

//   factory ChatMedia.fromJson(Map<String, dynamic> json) => ChatMedia(
//         status: json["status"],
//         message: json["message"],
//         data: MediaData.fromJson(json["data"]),
//         statusCode: json["statusCode"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "data": data.toJson(),
//         "statusCode": statusCode,
//       };
// }

// class MediaData {
//   int itemsPerPage;
//   int count;
//   List<MediaRow> rows;

//   MediaData({
//     required this.itemsPerPage,
//     required this.count,
//     required this.rows,
//   });

//   factory MediaData.fromJson(Map<String, dynamic> json) {
//     return MediaData(
//       itemsPerPage: json["itemsPerPage"],
//       count: json["count"],
//       rows: List<MediaRow>.from(json["rows"].map((x) => MediaRow.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "itemsPerPage": itemsPerPage,
//         "count": count,
//         "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
//       };
// }

// class MediaRow {
//   int id;
//   String rank;
//   int parentId;
//   String path;
//   String category;
//   String mimeType;
//   dynamic size;
//   dynamic width;
//   dynamic height;
//   String resolution;
//   String metadata;
//   DateTime createdAt;
//   DateTime updatedAt;
//   Rx<Uint8List?> videoThumbnail = Rx<Uint8List?>(null);
//   Rx<VideoPlayerController> videoController;
//   Rx<AudioPlayer> audioPlayer;

//   MediaRow({
//     required this.id,
//     required this.rank,
//     required this.parentId,
//     required this.path,
//     required this.category,
//     required this.mimeType,
//     required this.size,
//     required this.width,
//     required this.height,
//     required this.resolution,
//     required this.metadata,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.videoController,
//     required this.audioPlayer,
//   });

//   factory MediaRow.fromJson(Map<String, dynamic> json) => MediaRow(
//         id: json["id"],
//         rank: json["rank"],
//         parentId: json["parent_id"],
//         path: json["path"],
//         category: json["category"],
//         mimeType: json["mime_type"],
//         size: json["size"],
//         width: json["width"],
//         height: json["height"],
//         resolution: json["resolution"],
//         metadata: json["metadata"],
//         createdAt: DateTime.parse(json["createdAt"]),
//         updatedAt: DateTime.parse(json["updatedAt"]),
//         videoController:
//             VideoPlayerController.network(ApiStrings.s3ImageUrl + json["path"])
//                 .obs,
//         audioPlayer:
//             (AudioPlayer()..setUrl(ApiStrings.s3ImageUrl + json["path"])).obs,
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "rank": rank,
//         "parent_id": parentId,
//         "path": path,
//         "category": category,
//         "mime_type": mimeType,
//         "size": size,
//         "width": width,
//         "height": height,
//         "resolution": resolution,
//         "metadata": metadata,
//         "createdAt": createdAt.toIso8601String(),
//         "updatedAt": updatedAt.toIso8601String(),
//       };
// }
