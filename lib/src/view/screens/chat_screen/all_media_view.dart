import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/models/chat/chat_media_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../../models/chat/chat_model.dart';
import '../../popup/chat/chat_media_popup.dart';
import '../../widgets/specific_widgets/chat/chat_app_bar.dart';

class ChatMediaView extends StatefulWidget {
  final String mediaType;
  final MediaRow media;
  final List<MediaData> mediaList;
  final ChatUser? chatUser;
  final UserProfile? loggedInUser;
  final ChatRowData? chat;

  const ChatMediaView({
    super.key,
    required this.mediaType,
    required this.media,
    required this.mediaList,
    this.chatUser,
    this.loggedInUser,
    this.chat,
  });

  @override
  State<ChatMediaView> createState() => _ChatMediaViewState();
}

class _ChatMediaViewState extends State<ChatMediaView> {
  final ChatController chatController = Get.find();

  final selectedIndex = 0.obs;
  late final ScrollController scrollController;
  late final PageController pageScrollController;

  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final isPlaying = false.obs;
  final RxString _currentPosition = '00:00'.obs;
  final RxString _totalDuration = '00:00'.obs;
  final RxDouble _progressValue = 0.0.obs;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    selectedIndex.value = chatController.chatMedia.first.rows
        .indexWhere((e) => e.id == chatController.mediaActiveIndex.value);

    pageScrollController = PageController(
      viewportFraction: 0.25,
      initialPage: selectedIndex.value,
    );

    if (widget.mediaType == 'Videos') _initVideo(widget.media.path);
    if (widget.mediaType == 'Audio') _initAudio(widget.media.path);
  }

  Future<void> _initVideo(String path) async {
    await _disposeVideoController();
    final controller =
        VideoPlayerController.network(ApiStrings.s3ImageUrl + path);

    await controller.initialize();
    _videoController = controller;
    _totalDuration.value = Helpers.formatDuration(controller.value.duration);

    controller.addListener(() {
      final position = controller.value.position;
      final duration = controller.value.duration;

      _currentPosition.value = Helpers.formatDuration(position);
      if (duration.inMilliseconds > 0) {
        _progressValue.value =
            position.inMilliseconds / duration.inMilliseconds;
      }

      if (position >= duration && duration.inMilliseconds > 0) {
        isPlaying.value = false;
      }
    });

    setState(() {});
    _fetchVideoDetails();
  }

  Future<void> _initAudio(String path) async {
    await _audioPlayer
        .setUrl((ApiStrings.s3ImageUrl + path).replaceAll(' ', '%20'));

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration.value = Helpers.formatDuration(duration);
      }
    });

    _audioPlayer.positionStream.listen((position) {
      _currentPosition.value = Helpers.formatDuration(position);
      final totalMs = _audioPlayer.duration?.inMilliseconds ?? 0;
      _progressValue.value =
          totalMs > 0 ? position.inMilliseconds / totalMs : 0.0;
    });

    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value =
          state.playing && state.processingState != ProcessingState.completed;
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        isPlaying.value = false;
        _progressValue.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _disposeVideoController();
    _audioPlayer.dispose();
    scrollController.dispose();
    pageScrollController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    await _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final mediaDownloadTitle = widget.mediaType == "Photos"
        ? "Photo"
        : widget.mediaType == "Videos"
            ? "Video"
            : widget.mediaType;

    return Scaffold(
      appBar: ChatAppBar(
        isMediaView: true,
        loggedInUser: widget.chatUser,
        chatAdmin: widget.loggedInUser,
        chatIcon: widget.chat?.groupIcon,
        controlTap: () {
          final chatMedia =
              chatController.chatMedia.value.first.rows[selectedIndex.value];
          showDialog(
            context: context,
            builder: (ctx) => MediaPopup(
              chatId: widget.chatUser?.chatId,
              mediaDownloadTitle: mediaDownloadTitle,
              media: chatMedia.path,
              id: chatMedia.id,
            ),
          );
        },
      ),
      body: Obx(
        () => Container(
          color: isPlaying.value ? blackColor : whiteColor,
          child: Column(
            children: [
              _buildMainMediaView(),
              if (widget.mediaType != "Photos") _buildProgressBar(widthScale),
              if (widget.mediaType == "Videos") _buildVideoThumbnails(),
              if (widget.mediaType == "Photos") _buildPhotoThumbnails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainMediaView() {
    final mediaRow =
        chatController.chatMedia.value.first.rows[selectedIndex.value];

    return Container(
      color: const Color(0xFFFAFAFA),
      height: 70.h,
      width: 100.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.mediaType == 'Photos') _buildImage(mediaRow.path),
          if (widget.mediaType == 'Videos' &&
              _videoController?.value.isInitialized == true) ...[
            SizedBox(
              width: 100.w,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
            _playPauseBtn(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
                isPlaying.value = false;
              } else {
                _videoController!.play();
                isPlaying.value = true;
              }
            }),
          ],
          if (widget.mediaType == 'Audio') _buildAudioPlayer(),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    return Image.network(
      ApiStrings.s3ImageUrl + path,
      width: 100.w,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error)),
    );
  }

  Widget _buildAudioPlayer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 100.w, height: 70.h, color: backScreenColor),
        CircleAvatar(
          radius: 62,
          backgroundColor: primaryColor.withOpacity(0.05),
          backgroundImage: NetworkImage(
            ApiStrings.s3ImageUrl + (widget.loggedInUser?.profilePic ?? ''),
          ),
        ),
        _playPauseBtn(() {
          if (_audioPlayer.playing) {
            _audioPlayer.pause();
          } else {
            _audioPlayer.play();
          }
        }),
        Positioned(
          top: 20.w,
          child: SvgPicture.asset('assets/svg/audio_icon.svg'),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double widthScale) {
    return Obx(() => Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
          child: Row(
            children: [
              Text(
                _currentPosition.value,
                style: CustomTextStyle.styledTextWidget.labelSmall?.copyWith(
                  color: isPlaying.value ? whiteColor : primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: (widthScale * kTextFormFactor) * 12,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: LinearProgressIndicator(
                  value: _progressValue.value,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: primaryColor,
                  backgroundColor: progressBackgroundColor,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _totalDuration.value,
                style: CustomTextStyle.styledTextWidget.labelSmall?.copyWith(
                  color: isPlaying.value ? whiteColor : primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: (widthScale * kTextFormFactor) * 12,
                ),
              )
            ],
          ),
        ));
  }

  GestureDetector _playPauseBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying.value ? Icons.pause : Icons.play_arrow_rounded,
          color: whiteColor,
          size: 46,
        ),
      ),
    );
  }

  Widget _buildVideoThumbnails() {
    final mediaRows = chatController.chatMedia.value.first.rows;

    return SizedBox(
      width: 100.w,
      height: 20.w,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: mediaRows.length,
        itemBuilder: (context, index) {
          final row = mediaRows[index];
          return GestureDetector(
            onTap: () {
              _scrollToImage(index);
              selectedIndex.value = index;
              _initVideo(row.path);
              chatController.mediaActiveIndex.value = row.id;
            },
            child: Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.all(selectedIndex.value == index ? 0 : 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: row.videoThumbnail.value != null
                    ? Image.memory(
                        row.videoThumbnail.value!,
                        fit: BoxFit.cover,
                        opacity: selectedIndex.value != index
                            ? const AlwaysStoppedAnimation(0.6)
                            : null,
                      )
                    : const SizedBox(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoThumbnails() {
    final mediaRows = chatController.chatMedia.value.first.rows;

    return Container(
      margin: EdgeInsets.only(top: 2.h),
      height: 68,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        itemCount: mediaRows.length,
        itemBuilder: (context, index) {
          final row = mediaRows[index];
          return GestureDetector(
            onTap: () {
              selectedIndex.value = index;
              chatController.mediaActiveIndex.value = row.id;
            },
            child: Container(
              width: 68,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.all(selectedIndex.value == index ? 0 : 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiStrings.s3ImageUrl + row.path,
                  fit: BoxFit.cover,
                  opacity: selectedIndex.value != index
                      ? const AlwaysStoppedAnimation(0.7)
                      : null,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _fetchVideoDetails() async {
    final rows = chatController.chatMedia.value.first.rows;
    for (final row in rows) {
      final details =
          await Helpers.getVideoDetails(ApiStrings.s3ImageUrl + row.path);
      row.videoThumbnail.value = details['thumb'];
    }
  }

  void _scrollToImage(int index) {
    const offset = 72.0;
    if (selectedIndex.value > index) {
      scrollController.animateTo(
        scrollController.offset - offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (selectedIndex.value < index) {
      scrollController.animateTo(
        scrollController.offset + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
