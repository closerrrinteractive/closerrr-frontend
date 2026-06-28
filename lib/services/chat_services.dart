import 'package:closerrr/core/services/http_service.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/models/chat/chat_memories.dart';
import 'package:closerrr/src/models/chat/chat_messages_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import '../core/utils/failure.dart';
import '../src/models/chat/chat_media_model.dart';
import '../src/models/chat/chat_model.dart';
import '../src/models/chat/story/story_model.dart';

class ChatServices {
  final HttpService httpService = HttpService();
  static const MethodChannel _galleryChannel = MethodChannel('com.closerrr.app/gallery');

  /// [1]
  Future<Either<Failure, ChatModel>> getChats({
    required int page,
    String? search,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (search != null) {
        data['search'] = search;
      }
      final response = await httpService.get(
        ApiStrings.getChats,
        queryParameters: data,
      );

      return Right(ChatModel.fromJson(response.data));
    } catch (e, s) {
      print('--------------$s');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [2]
  Future<Either<Failure, ChatMessages>> getChatMessages(
    String? search, {
    required int chatId,
    bool? isOwn,
    int? targetId,
    int? page,
    int? limit,
    String? direction,
  }) async {
    try {
      Map<String, dynamic> data = {
        'chat_id': chatId,
      };

      if (direction != null) {
        data['search_direction'] = direction;
      }

      if (page != null) {
        data['page'] = page;
      }

      if (isOwn != null) {
        data['is_own'] = isOwn;
      }

      if (targetId != null) {
        data['target_message_id'] = targetId;
        data['search_direction'] = 'up';
      }

      if (limit != null) {
        data['limit'] = limit;
      }

      if (search != null && search.isNotEmpty) {
        data['search'] = search;
      }
      final response = await httpService.get(
        ApiStrings.getChatMessages,
        queryParameters: data,
      );

      final chatMessages = ChatMessages.fromJson(response.data);

      return Right(chatMessages);
    } catch (e, stackTrace) {
      return Left(ServerFailure(message: e.toString(), stackTrace: stackTrace));
    }
  }

  /// [3]
  Future<Either<Failure, Map<String, dynamic>>> sendMessage(
      {required Map<String, dynamic> data}) async {
    try {
      final response = await httpService.post(
        ApiStrings.sendMessage,
        data: data,
        isFormData: true,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [4]
  Future<Either<Failure, Map<String, dynamic>>> addAndRemoveStarredMessage(
      {required int messageId}) async {
    try {
      final response = await httpService.post(
        ApiStrings.addAndRemoveStarredMessage,
        data: {
          'message_id': messageId,
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [5]
  Future<Either<Failure, Map<String, dynamic>>> updateNickname({
    required int chatId,
    String? nickname,
    required bool isYours,
  }) async {
    try {
      final data = {
        'chat_id': chatId.toString(),
        'is_yours': isYours,
      };

      if (nickname != null) {
        data['nickname'] = nickname;
      }

      // if (friendId != null) {
      //   data['friend_id'] = friendId;
      // }
      final response = await httpService.post(
        ApiStrings.updateNickname,
        data: data,
        isFormData: false,
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [6]
  Future<Either<Failure, Map<String, dynamic>>> updateChatBackground({
    required int chatId,
    XFile? background,
    required String type,
  }) async {
    try {
      final data = {
        'chat_id': chatId,
        'type': type,
        if (background != null)
          'background': await MultipartFile.fromFile(
            background.path,
            filename: background.name,
          ),
      };

      final response = await httpService.post(
        ApiStrings.updateChatBackground,
        data: data,
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [7]
  Future<Either<Failure, ChatMedia>> getChatMedia({
    required int chatId,
    required int page,
    required int limit,
    required String mediaType,
  }) async {
    try {
      final response = await httpService.get(
        ApiStrings.getChatMedia,
        queryParameters: {
          'chat_id': chatId,
          'page': page,
          'limit': limit,
          'media_type': mediaType,
        },
      );

      return Right(ChatMedia.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [8]
  Future<Either<Failure, ChatMemories>> getStarredMessages({
    required int chatId,
  }) async {
    try {
      final response = await httpService.get(
        ApiStrings.getStarredMessages,
        queryParameters: {
          'chat_id': chatId,
        },
      );

      return Right(ChatMemories.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [9]
  Future<Either<Failure, Map<String, dynamic>>> addAndRemoveFavouriteChat(
      {required int chatId}) async {
    try {
      final response = await httpService.post(
        ApiStrings.addAndRemoveFavouriteChat,
        data: {
          'chat_id': chatId,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [10]
  Future<Either<Failure, Map<String, dynamic>>> getChatUsers({
    required int chatId,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.getChatUsers,
        data: {
          'chat_id': chatId,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [11]
  Future<Either<Failure, Map<String, dynamic>>> updateSeenStatus(
      {required int chatId}) async {
    try {
      final response = await httpService.patch(
        ApiStrings.updateSeenStatus,
        data: {
          'chat_id': chatId,
          'all': true,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [12]
  Future<Either<Failure, Map<String, dynamic>>> getUnreadMessagesCount(
      {required int chatId}) async {
    try {
      final response = await httpService.post(
        ApiStrings.getUnreadMessagesCount,
        data: {
          'chat_id': chatId,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [13]
  Future<Either<Failure, Map<String, dynamic>>> downloadMedia({
    required String mediaUrl,
    required ValueNotifier<double> progressNotifier,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${mediaUrl.split('/').last}';
    try {
      await Dio().download(
        mediaUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            progressNotifier.value = progress;
          }
        },
      );

      try {
        final bool? success = await _galleryChannel.invokeMethod<bool>(
          'saveFileToGallery',
          {'path': filePath},
        );
        if (success == true) {
          return Right({'file_path': filePath});
        } else {
          return Left(ServerFailure(message: 'Failed to save media to gallery.'));
        }
      } on PlatformException catch (pe) {
        return Left(ServerFailure(message: pe.message ?? 'Error saving media to gallery.'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [14] [Get Story]
  Future<Either<Failure, StoryModel>> getStory({
    required int userId,
  }) async {
    try {
      final response = await httpService.get(
        ApiStrings.getStory,
        queryParameters: {'user_id': userId},
      );

      return Right(StoryModel.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [15] [Add Story]
  Future<Either<Failure, Map<String, dynamic>>> addStory({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.addStory,
        data: data,
        isFormData: true,
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [16] [Like Story]
  Future<Either<Failure, Map<String, dynamic>>> likeStory({
    required int storyId,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.likeStory,
        data: {
          'id': storyId,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [17] [get pre-signed urls]
  Future<Either<Failure, Map<String, dynamic>>> getPresignedUrls(
      XFile file, String selectedMediaType) async {
    try {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final fileName = file.name;

      final response = await httpService.post(
        ApiStrings.generatePresignedUrls,
        data: {
          'filename': fileName,
          'content_type': mimeType,
          'selected_media_type': selectedMediaType
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [18] [upload files to S3]
  Future<Either<Failure, Map<String, dynamic>>> uploadToS3(
    XFile file,
    String url,
    headers,
  ) async {
    try {
      final dio = Dio();
      final fileLength = await file.length();
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      final fileStream = file.openRead();

      final response = await dio.put(
        url,
        data: fileStream,
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': fileLength.toString(),
            if (headers.containsKey('x-amz-meta-original-name'))
              'x-amz-meta-original-name': headers['x-amz-meta-original-name']!,
            if (headers.containsKey('x-amz-meta-upload-timestamp'))
              'x-amz-meta-upload-timestamp':
                  headers['x-amz-meta-upload-timestamp']!,
          },
          responseType: ResponseType.plain, // S3 returns empty body
        ),
        onSendProgress: (count, total) {
          print("Uploaded $count / $total bytes");
        },
      );

      if (response.statusCode == 200) {
        print("✅ Upload successful via Dio");
        return const Right({});
      } else {
        print("❌ Upload failed with status: ${response.statusCode}");
        return Left(
            ServerFailure(message: 'Upload failed: ${response.statusCode}'));
      }
    } catch (e) {
      print("❌ Dio Upload Error: $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [Report]
  Future<Either<Failure, Map<String, dynamic>>> report({
    required int id,
    required String text,
    required String type,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.report,
        data: {
          'id': id,
          'text': text,
          'type': type,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> deleteMessage(
      {required int messageId}) async {
    try {
      final response = await httpService.delete(
        "${ApiStrings.deleteMessage}/$messageId",
        queryParameters: {
          'messageId': messageId,
        },
      );

      return Right(response.data);
    } catch (e, s) {
      return Left(ServerFailure(message: e.toString(), stackTrace: s));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> deleteStory(
      {required int storyId}) async {
    try {
      final response = await httpService.delete(
        "${ApiStrings.deleteStory}/$storyId",
        queryParameters: {
          'storyId': storyId,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> updateChatSettings(
      {required int chatId,
      String? groupName,
      String? groupDescription,
      XFile? groupIcon}) async {
    try {
      final Map<String, dynamic> data = {};
      final Map<String, dynamic> params = {
        "group_name": groupName,
        "group_description": groupDescription,
      };

      // Dynamically add non-null and non-empty values
      for (final entry in params.entries) {
        final value = entry.value;
        if (value != null && value.trim().isNotEmpty) {
          data[entry.key] = value;
        }
      }

      if (groupIcon != null) {
        data["group_icon"] = await MultipartFile.fromFile(
          groupIcon.path,
          filename: groupIcon.name,
        );
      }

      final response = await httpService.patch(
        '${ApiStrings.updateChatSettings}/$chatId',
        data: data,
      );

      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
