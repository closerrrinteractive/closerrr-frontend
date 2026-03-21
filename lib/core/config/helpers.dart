import 'dart:convert';
import 'dart:developer' as d;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:closerrr/core/config/responsive.dart';
import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/auth/user.dart';
import 'package:closerrr/src/models/chat/chat_messages_model.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart'
    show Message, TextMessage, ImageMessage, VideoMessage, AudioMessage;
import 'package:flutter_chat_core/flutter_chat_core.dart' as fcc;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getx;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../src/models/chat/chat_model.dart';

enum RequestType { get, post, delete, put }

enum Status {
  success,
  failed,
  loading,
  networkError,
  error,
  pending,
  canceled,
  empty,
}

class Helpers {
  static extractMediaType(String path) {
    String type = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(type)) {
      type = 'image';
    } else if (['mp4'].contains(type)) {
      type = 'video';
    }
    return type;
  }

  Future<List<int>> extractWaveform(String audioPath) async {
    final outputPath = '${audioPath}_waveform.pcm';

    // Convert audio file -> raw PCM (16-bit little endian)
    await FFmpegKit.execute(
      '-i $audioPath -ac 1 -f s16le -acodec pcm_s16le $outputPath',
    );

    final file = File(outputPath);
    final bytes = await file.readAsBytes();

    // Convert every 2 bytes -> PCM sample
    final buffer = ByteData.view(bytes.buffer);
    List<int> samples = [];
    for (int i = 0; i < buffer.lengthInBytes; i += 2) {
      samples.add(buffer.getInt16(i, Endian.little));
    }

    return samples;
  }

  List<double> normalizeSamples(List<int> samples, int barsCount) {
    int step = (samples.length / barsCount).floor();
    List<double> normalized = [];

    for (int i = 0; i < samples.length; i += step) {
      final chunk = samples.sublist(i, i + step);
      final avg =
          chunk.map((e) => e.abs()).reduce((a, b) => a + b) / chunk.length;
      normalized.add(avg / 32768.0); // normalize 0 → 1
    }

    return normalized;
  }

  static List<TextSpan> buildHighlightedTextSpans(
      String text, String? query, int? activedIndex, bool? isSender) {
    if (query == null || query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final int matchIndex = lowerText.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      if (matchIndex > start) {
        spans.add(TextSpan(text: text.substring(start, matchIndex)));
      }

      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: TextStyle(
            backgroundColor: isSender != true ? primaryColor : whiteColor,
            color: isSender != true ? whiteColor : Colors.black,
          ),
        ),
      );

      start = matchIndex + query.length;
    }

    return spans;
  }

  static Future<void> compressVideo(
    File videoFile, {
    int targetSizeKB = 5240,
    int maxRetries = 3,
  }) async {
    // try {
    //   final originalSize = await videoFile.length();
    //   print('Original Size: ${formatBytes(originalSize)}');

    //   if (originalSize <= targetSizeKB * 1024) {
    //     print("File is already under target size. Returning original.");
    //     return XFile(videoFile.path);
    //   }

    //   // Create output path
    //   final outputPath =
    //       '${videoFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    //   // Initial compression settings
    //   int crf = 28; // Start with moderate compression
    //   int width = 720; // Target width
    //   double frameRate = 24; // Target frame rate

    //   File? compressedFile;
    //   int retryCount = 0;

    //   while (retryCount < maxRetries) {
    //     print('Attempt ${retryCount + 1} with CRF: $crf, Width: $width');

    //     // FFmpeg command to compress video
    //     final command = '-i "${videoFile.path}" '
    //         '-c:v libx264 '
    //         '-crf $crf '
    //         '-vf "scale=$width:-2,fps=$frameRate" '
    //         '-preset fast '
    //         '-profile:v baseline ' // Better device compatibility
    //         '-movflags +faststart ' // Enable streaming
    //         '-c:a aac '
    //         '-b:a 128k '
    //         '-y ' // Overwrite output file without asking
    //         '"$outputPath"';

    //     print('Executing FFmpeg command: $command');

    //     final session = await FFmpegKit.execute(command);
    //     final returnCode = await session.getReturnCode();

    //     if (ReturnCode.isSuccess(returnCode)) {
    //       compressedFile = File(outputPath);
    //       final compressedSize = await compressedFile.length();

    //       print('Compressed Size: ${formatBytes(compressedSize)}');

    //       if (compressedSize <= targetSizeKB * 1024) {
    //         return XFile(compressedFile.path);
    //       } else {
    //         // Adjust parameters for next attempt
    //         crf += 3; // Increase compression
    //         width = (width * 0.8).round(); // Reduce resolution
    //         frameRate =
    //             frameRate > 20 ? frameRate - 2 : frameRate; // Reduce frame rate
    //         retryCount++;
    //       }
    //     } else {
    //       final failStackTrace = await session.getFailStackTrace();
    //       print('FFmpeg compression failed: ${await session.getOutput()}');
    //       print('Error: ${await session.getFailStackTrace()}');
    //       break;
    //     }
    //   }

    //   // Return the best attempt we got (even if it didn't meet target)
    //   if (compressedFile != null && await compressedFile.exists()) {
    //     return XFile(compressedFile.path);
    //   }

    //   return null;
    // } catch (e) {
    //   print('Error during compression: $e');
    //   return null;
    // }
  }

  static String formatBytes(int bytes, [int decimals = 0]) {
    const k = 1024;
    final dm = decimals < 0 ? 0 : decimals;
    final sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(k)).floor();
    final a = (bytes / pow(k, i)).toStringAsFixed(dm);
    return '$a ${sizes[i]}';
  }
  // Image compression

  static Future<XFile?> compressImage({
    required File imageFile,
    int quality = 75,
    bool preservePng = true,
  }) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        throw UnsupportedError(
          'Image compression is only supported on mobile platforms.',
        );
      }

      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.absolute.path, "compressed.jpg");
      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 70,
      );
      return result;
    } catch (e) {
      throw Exception('Image compression failed: $e');
    }
  }

  // Video compression
  //   Future<void> compressVideo(String inputPath, String outputPath,
  //       {int quality = 50}) async {
  //     await FFmpegKit.execute(
  //             'ffmpeg -i $inputPath -c:v libx264 -pix_fmt yuv420p $outputPath')
  //         .then((session) async {
  //       final returnCode = await session.getReturnCode();

  //       if (ReturnCode.isSuccess(returnCode)) {
  //       } else if (ReturnCode.isCancel(returnCode)) {
  //         throw Exception('Video compression was cancelled');
  //       } else {
  //         throw Exception(
  //             'Video compression failed with return code: $returnCode');
  //       }
  //     });
  //   }

  // // Audio compression
  //   Future<void> compressAudio(String inputPath, String outputPath) async {
  //     FFmpegKit.execute('-i file1.mp4 -c:v mpeg4 file2.mp4')
  //         .then((session) async {
  //       final returnCode = await session.getReturnCode();

  //       if (ReturnCode.isSuccess(returnCode)) {
  //         print('Audio compression successful');
  //       } else if (ReturnCode.isCancel(returnCode)) {
  //         throw Exception(
  //             'Audio compression failed with return code: $returnCode');
  //       } else {
  //         throw Exception(
  //             'Audio compression failed with return code: $returnCode');
  //       }
  //     });
  //   }

  static Future<Map<String, dynamic>> getVideoDetails(String path) async {
    Uint8List? thumb = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 300,
      quality: 75,
    );
    d.log(thumb.toString());
    String duration = "00:00";
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(path));
      await controller.initialize().then((_) {
        duration = formatDuration(controller.value.duration);
      });

      return {'thumb': thumb, 'duration': duration};
    } catch (e) {
      kLog("Video processing error: $e", error: true);
      return {'thumb': thumb, 'duration': duration};
    }
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static double getProgressValue(Duration position, Duration duration) {
    return (duration.inMilliseconds > 0)
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0; // Prevent division by zero
  }

  static toast(String msg, {ToastGravity? gravity}) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM,
      backgroundColor: primaryColor,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  static getDuration(Duration duration) {
    if (duration.inDays > 0) {
      return "${duration.inDays}d";
    } else if (duration.inHours > 0) {
      return "${duration.inHours}h";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes}m";
    } else if (duration.inSeconds > 0) {
      return "${duration.inSeconds}s";
    } else {
      return "0s";
    }
  }

  static getAdmin({required List<UserData> users}) {
    final user = users.firstWhere((element) => element.chatUser.isAdmin);
    return user;
  }

  static getUser({required List<UserData> users, required String userId}) {
    try {
      int parsedUserId = int.parse(userId);
      return users.firstWhere(
        (element) => element.chatUser.userId == parsedUserId,
      );
    } catch (e) {
      return null;
    }
  }

  static bool checkForAsset(String? path) {
    try {
      if (path != null) {
        final file = File(path);
        return file.existsSync();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static defaultChatBackground({bool bottomWidget = false}) {
    return Image.asset(
      'assets/png/chat_background.png',
      width: 32.0,
      alignment: bottomWidget ? Alignment.bottomCenter : Alignment.topCenter,
      fit: BoxFit.cover,
    );
  }

  static setString({required String key, required String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static getString({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<String> getFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("FcmToken") ?? "";
  }

  static getUserId() async {
    final data = await getString(key: 'userData');
    try {
      final closerUser = User.fromJson(jsonDecode(data));
      return closerUser.id.toString();
    } catch (e) {
      return 0.toString();
    }
  }

  static getRowCol({required bool isRow, required List<Widget> children}) {
    if (isRow) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }
  }

  static cupertinoAlertPopUp(
    BuildContext context,
    String title,
    Function() onTapAction, {
    String desc = "",
    String optionText = "Okay",
    bool secondOption = false,
    Function()? secondOnTap,
    bool? canHeDismiss,
    String secondOptionText = "Yes",
    bool? isBtnStatusOne = false,
    bool? isBtnStatusTwo = false,
    getx.Rx<Status>? statusOne,
    getx.Rx<Status>? statusTwo,
    bool? isFromSub = false,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AbsorbPointer(
          absorbing: (isBtnStatusOne == true &&
                  statusOne?.value == Status.loading) ||
              (isBtnStatusTwo == true && statusTwo?.value == Status.loading),
          child: WillPopScope(
            onWillPop: () => Future(() => canHeDismiss ?? true),
            child: CupertinoAlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      title,
                      style: CustomTextStyle.styledTextWidget.headlineLarge
                          ?.copyWith(
                        color: blackColor,
                        fontSize: Responsive.isTablet() ? 10.sp : 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  const Divider(thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isBtnStatusOne == true &&
                              statusOne!.value == Status.loading
                          ? const SizedBox(
                              width: 100,
                              height: 40,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Container(
                              height: 40,
                              width: 100,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    Colors.transparent,
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: CustomButton(
                                buttonTitle: optionText,
                                backButtonColor: buttonColor,
                                isTextStyle: true,
                                onlyText: true,
                                onPress: () {
                                  Navigator.of(context).pop();
                                  // Then perform the action
                                  onTapAction();
                                },
                              ),
                            ),
                      secondOption
                          ? isBtnStatusTwo == true &&
                                  statusTwo?.value == Status.loading
                              ? const SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    // Close the pop-up
                                    Navigator.of(context).pop();
                                    // Then perform the action
                                    if (secondOnTap != null) {
                                      secondOnTap();
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 100,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      secondOptionText,
                                      style: CustomTextStyle
                                          .styledTextWidget.headlineLarge
                                          ?.copyWith(color: blackColor),
                                    ),
                                  ),
                                )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static bool containsBadWords(String text) {
    List<String> badWords = ["ugly", "stupid", "moron", "dull", "fool"];
    // Normalize text (lowercase for case-insensitive check)
    final lowerText = text.toLowerCase();

    for (var word in badWords) {
      if (lowerText.contains(word.toLowerCase())) {
        return true; // Found a bad word
      }
    }
    return false; // Safe
  }

  static Future<void> openLink(link) async {
    final url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
  }

  static isInfluencer(roleId) {
    return roleId == 3;
  }
}

List<Message> buildMessages(
  List<MessagesRow> messageRows,
  UserInformationController uiController,
  String userId,
) {
  return messageRows.map<Message>((messageRow) {
    final author = _buildUser(messageRow.user, uiController, userId);
    var profile = messageRow.replyTo?.user.profile;

    if (messageRow.media.isEmpty) {
      return TextMessage(
        id: messageRow.id.toString(),
        text: messageRow.messageText ?? '',
        authorId: messageRow.senderId.toString(),
        createdAt: messageRow.createdAt,
        metadata: {
          "repliedMessage": messageRow.story != null
              ? TextMessage(
                  id: (messageRow.story?.id ?? '').toString(),
                  text: messageRow.story?.text ?? '',
                  // author: User(
                  //   id: (messageRow.story?.userId.toString()) ?? '',
                  // ),
                  authorId: (messageRow.story?.userId.toString()) ?? '',
                  // previewData: PreviewData(
                  //   image: PreviewDataImage(
                  //     height: 250,
                  //     url: (ApiStrings.s3ImageUrl +
                  //         (messageRow.story?.mediaPath ?? '')),
                  //     width: 250,
                  //   ),
                  // ),
                  // status: messageRow.seenBy,
                  // type: MessageType.text,
                  metadata: {
                    "author": fcc.User(
                      id: (messageRow.story?.userId.toString()) ?? '',
                    ),
                  },
                )
              : messageRow.replyTo != null
                  ? TextMessage(
                      id: (messageRow.replyTo?.id ?? '').toString(),
                      replyToMessageId: messageRow.replyTo?.id.toString(),
                      text: messageRow.replyTo?.messageText ?? '',
                      authorId: (messageRow.replyTo?.senderId ?? '').toString(),
                      // author: User(
                      //   id: (messageRow.replyTo?.user.id.toString()) ?? '',
                      //   firstName: messageRow.replyTo?.user.profile.username,
                      // ),
                      // type: MessageType.text,
                      metadata: {
                          "author": fcc.User(
                            id: (messageRow.replyTo?.user.id.toString()) ?? '',
                            name: profile?.fullname ?? profile?.username,
                          ),
                        })
                  : null,
          "author": author
        },
      );
    } else {
      final media = messageRow.media.first;
      if (media.category == 'image') {
        return ImageMessage(
          authorId: messageRow.senderId.toString(),
          createdAt: messageRow.createdAt,
          id: messageRow.id.toString(),
          source: ApiStrings.s3ImageUrl + media.path,
          size: (media.size ?? 0).toInt(),
          height: media.height?.toDouble() ?? 0,
          width: media.width?.toDouble() ?? 0,
          metadata: {"author": author},
        );
      } else if (media.category == 'video') {
        return VideoMessage(
          authorId: messageRow.senderId.toString(),
          createdAt: messageRow.createdAt,
          id: messageRow.id.toString(),
          name: media.path,
          source: ApiStrings.s3ImageUrl + media.path,
          size: (media.size ?? 0).toInt(),
          metadata: {"author": author},
        );
      } else if (media.category == "audio") {
        return AudioMessage(
          authorId: messageRow.senderId.toString(),
          createdAt: messageRow.createdAt,
          id: messageRow.id.toString(),
          source: ApiStrings.s3ImageUrl + media.path,
          size: (media.size ?? 0).toInt(),
          duration: const Duration(seconds: 3),
          metadata: {"author": author},
        );
      } else {
        return TextMessage(
          id: messageRow.id.toString(),
          authorId: messageRow.senderId.toString(),
          text: messageRow.messageText ?? '',
          createdAt: messageRow.createdAt,
          metadata: {"author": author},
        );
      }
    }
  }).toList();
}

fcc.User _buildUser(
  ChatMessageUser? user,
  UserInformationController uiController,
  String userId,
) {
  final isAdmin = user!.chats.first.chatUser.isAdmin;

  UserData? groupAdmin = Helpers.getAdmin(
    users: user.chats.first.users,
  );

  UserData? loggedInUser;
  if (!uiController.isInfluencer.value) {
    loggedInUser = Helpers.getUser(
      users: user.chats.first.users,
      userId: userId,
    );
  }

  return fcc.User(
    id: user.id.toString(),
    name: uiController.userData['role_id'] == 3
        ? user.profile?.fullname ?? user.profile?.username ?? 'No Name'
        : isAdmin
            ? loggedInUser?.chatUser.friendName?.value ??
                groupAdmin?.profile?.fullname ??
                groupAdmin?.profile?.username ??
                ''
            : 'Unknown',
    // lastName: '',
    imageSource: ApiStrings.s3ImageUrl + (user.profile?.profilePic ?? ''),
  );
}
