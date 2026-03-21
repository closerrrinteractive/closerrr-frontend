// audio_chat_bubble.dart
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as js;
import 'package:sizer/sizer.dart';

class AudioChatBubble extends StatefulWidget {
  final bool isSender;
  final String mediaUrl;
  final String id;

  const AudioChatBubble({
    super.key,
    required this.isSender,
    required this.mediaUrl,
    required this.id,
  });

  @override
  State<AudioChatBubble> createState() => _AudioChatBubbleState();
}

class _AudioChatBubbleState extends State<AudioChatBubble> {
  late final js.AudioPlayer _audioPlayer;
  late final PlayerController _waveController;

  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxString durationText = '00:00'.obs;
  final RxDouble progress = 0.0.obs;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<js.PlayerState>? _playerStateSubscription;

  String? _localFilePath;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = js.AudioPlayer();
    _waveController = PlayerController();
    _initializeListeners();
    _prepareAudio();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _initializeListeners() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_totalDuration.inMilliseconds > 0) {
        progress.value = position.inMilliseconds /
            (_totalDuration.inMilliseconds == 0
                ? 1
                : _totalDuration.inMilliseconds);

        final remaining = _totalDuration - position;

        final minutes =
            remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds =
            remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
        durationText.value = '$minutes:$seconds';

        _waveController.seekTo(position.inMilliseconds);
      }
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == js.ProcessingState.completed) {
        _handleCompletion();
      }
    });
  }

  Future<File> _getCachedFile(String url) async {
    final cacheManager = DefaultCacheManager();
    final file = await cacheManager.getSingleFile(url);
    return file;
  }

  Future<void> _prepareAudio() async {
    try {
      isLoading.value = true;

      final file = await _getCachedFile(widget.mediaUrl);
      _localFilePath = file.path;

      await _audioPlayer.setFilePath(file.path);

      _totalDuration = _audioPlayer.duration ?? Duration.zero;

      // ✅ Start countdown at full duration
      final minutes =
          _totalDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds =
          _totalDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
      durationText.value = '$minutes:$seconds';

      await _waveController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
        noOfSamples: 35,
      );

      _waveController.setFinishMode(finishMode: FinishMode.stop);
      _waveController.seekTo(0);

      isLoading.value = false;
    } catch (e, st) {
      debugPrint("Error preparing audio: $e\n$st");
      isLoading.value = false;
    }
  }

  Future<void> _handleCompletion() async {
    await _audioPlayer.stop();
    await _waveController.stopPlayer();
    await _audioPlayer.seek(Duration.zero);
    _waveController.seekTo(0);

    isPlaying.value = false;
    progress.value = 0.0;

    final minutes =
        _totalDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _totalDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    durationText.value = '$minutes:$seconds';
  }

  Future<void> _handlePlayPause() async {
    if (isLoading.value) return;

    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        await _waveController.pausePlayer();
      } else {
        final current = _audioPlayer.position;
        if (_totalDuration.inMilliseconds > 0 &&
            current.inMilliseconds >= _totalDuration.inMilliseconds) {
          await _audioPlayer.seek(Duration.zero);
          _waveController.seekTo(0);
        }

        await _audioPlayer.play();
        await _waveController.startPlayer();
      }
    } catch (e) {
      debugPrint("Playback error: $e");
    }
  }

  // Future<void> _seekTo(Duration position) async {
  //   if (_localFilePath == null) return;
  //   await _audioPlayer.seek(position);
  //   _waveController.seekTo(position.inMilliseconds);
  //   if (_audioPlayer.playing) {
  //     await _waveController.startPlayer();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Obx(() {
      if (isLoading.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isSender ? Colors.white : primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Loading audio...",
                style: TextStyle(
                  color: widget.isSender ? Colors.white : Colors.black87,
                  fontSize: (widthScale * kTextFormFactor) * 12,
                ),
              ),
            ],
          ),
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _handlePlayPause,
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSender
                    ? Colors.white.withOpacity(0.3)
                    : primaryColor.withOpacity(0.2),
              ),
              child: Center(
                child: Obx(() => Icon(
                      isPlaying.value ? Icons.pause : Icons.play_arrow_rounded,
                      color: widget.isSender ? Colors.white : primaryColor,
                      size: 22,
                    )),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (_localFilePath != null)
            SizedBox(
              width: 45.w,
              height: 50,
              child: AudioFileWaveforms(
                size: Size(45.w, 50),
                playerController: _waveController,
                waveformType: WaveformType.fitWidth,
                enableSeekGesture: false,
                playerWaveStyle: PlayerWaveStyle(
                  seekLineColor: peachColor,
                  fixedWaveColor: widget.isSender
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey.shade300,
                  liveWaveColor: widget.isSender ? peachColor : primaryColor,
                  spacing: 4.3,
                  showSeekLine: false,
                  waveCap: StrokeCap.round,
                ),
              ),
            )
          else
            SizedBox(
              width: 45.w,
              height: 50,
              child: Center(
                child: Text(
                  "No audio",
                  style: TextStyle(
                    color: widget.isSender ? Colors.white : Colors.black87,
                    fontSize: (widthScale * kTextFormFactor) * 12,
                  ),
                ),
              ),
            ),
          Text(
            durationText.value,
            style: TextStyle(
              color: widget.isSender ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: (widthScale * kTextFormFactor) * 14,
            ),
          ),
        ],
      );
    });
  }
}
