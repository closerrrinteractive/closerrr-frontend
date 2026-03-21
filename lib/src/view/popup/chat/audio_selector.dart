import 'dart:async';

import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_popup_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class AudioSelector extends StatefulWidget {
  const AudioSelector({
    super.key,
    required this.onMicTap,
    required this.onGalleryTap,
    required this.isRecording,
  });

  final Function(String audioPath) onMicTap;
  final Function() onGalleryTap;
  final bool isRecording;

  @override
  State<AudioSelector> createState() => _AudioSelectorState();
}

class _AudioSelectorState extends State<AudioSelector> {
  final _heights = [0.05, 0.07, 0.1, 0.07, 0.05].obs;
  final _recordState = RecordState.idle.obs;
  final _recordDuration = 0.obs;
  Timer? _animationTimer;
  Timer? _durationTimer;
  FlutterSoundRecorder? _recorder;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _startAnimating();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _durationTimer?.cancel();
    _recorder?.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await Permission.microphone.request();
  }

  void _startAnimating() {
    _animationTimer =
        Timer.periodic(const Duration(milliseconds: 150), (timer) {
      _heights.add(_heights.removeAt(0));
    });
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.isGranted) {
      final dir = await getTemporaryDirectory();
      _audioPath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder!.startRecorder(toFile: _audioPath, codec: Codec.aacMP4);
      _recordState.value = RecordState.recording;
      _startDurationTimer();
    } else {
      await Permission.microphone.request();
    }
  }

  Future<void> _pauseRecording() async {
    await _recorder!.pauseRecorder();
    _recordState.value = RecordState.paused;
    _durationTimer?.cancel();
  }

  Future<void> _resumeRecording() async {
    await _recorder!.resumeRecorder();
    _recordState.value = RecordState.recording;
    _startDurationTimer();
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    _recordState.value = RecordState.stopped;
    _durationTimer?.cancel();
    // if (_audioPath != null) {
    // widget.onMicTap(_audioPath!);
    // }
  }

  Future<void> _sendRecording() async {
    // await _recorder!.stopRecorder();
    // _recordState.value = RecordState.stopped;
    // _durationTimer?.cancel();
    if (_audioPath != null) {
      widget.onMicTap(_audioPath!);
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordDuration.value++;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Obx(() {
        final isRecordingMode = _recordState.value != RecordState.idle;
        return Stack(
          children: [
            Container(
              width: 100.w,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: popColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecordingMode ? 'Record Audio' : 'Send Audio',
                    textAlign: TextAlign.center,
                    style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (!isRecordingMode) ...[
                    PopupCustomBtn(
                      isReporting: false,
                      title: 'Record Audio',
                      svg: "assets/svg/record_mic.svg",
                      isChat: true,
                      ontap: () {
                        _recordState.value = RecordState.ready;
                        _recordDuration.value = 0;
                      },
                    ),
                    SizedBox(height: 2.h),
                    PopupCustomBtn(
                      isReporting: false,
                      title: 'Choose Audio File',
                      svg: "assets/svg/choose_audio.svg",
                      isChat: true,
                      ontap: widget.onGalleryTap,
                    ),
                  ] else ...[
                    Text(
                      _formatDuration(_recordDuration.value),
                      style:
                          CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                        color: headingColor,
                        fontSize: (widthScale * kTextFormFactor) * 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              _recordState.value == RecordState.recording
                                  ? callHangColor
                                  : greyColor,
                          radius: 4,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _recordState.value == RecordState.recording
                              ? 'Recording...'
                              : _recordState.value == RecordState.paused
                                  ? 'Recording Paused'
                                  : _recordState.value == RecordState.stopped
                                      ? 'Recording Stopped'
                                      : 'Ready To Record',
                          style: CustomTextStyle.styledTextWidget.bodyLarge!
                              .copyWith(
                            fontSize: (widthScale * kTextFormFactor) * 14,
                            color: headingColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    if (_recordState.value == RecordState.recording) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                            width: 26.w,
                            buttonTitle: 'PAUSE',
                            backButtonColor: Colors.transparent,
                            bordercolor:
                                const BorderSide(width: 1, color: primaryColor),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            onlyText: true,
                            titleStyle: CustomTextStyle
                                .styledTextWidget.bodyLarge!
                                .copyWith(
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              color: primaryColor,
                            ),
                            onPress: _pauseRecording,
                          ),
                          CustomButton(
                            width: 26.w,
                            buttonTitle: 'STOP',
                            backButtonColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            onlyText: true,
                            titleStyle: CustomTextStyle
                                .styledTextWidget.bodyLarge!
                                .copyWith(
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              color: whiteColor,
                            ),
                            onPress: _stopRecording,
                          ),
                        ],
                      ),
                    ] else if (_recordState.value == RecordState.paused) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                            width: 26.w,
                            buttonTitle: 'RESUME',
                            backButtonColor: Colors.transparent,
                            bordercolor:
                                const BorderSide(width: 1, color: primaryColor),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            onlyText: true,
                            titleStyle: CustomTextStyle
                                .styledTextWidget.bodyLarge!
                                .copyWith(
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              color: primaryColor,
                            ),
                            onPress: _resumeRecording,
                          ),
                          CustomButton(
                            width: 26.w,
                            buttonTitle: 'STOP',
                            backButtonColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            onlyText: true,
                            titleStyle: CustomTextStyle
                                .styledTextWidget.bodyLarge!
                                .copyWith(
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              color: whiteColor,
                            ),
                            onPress: _stopRecording,
                          ),
                        ],
                      ),
                    ] else if (_recordState.value == RecordState.stopped) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                            width: 26.w,
                            buttonTitle: 'RE-RECORD',
                            backButtonColor: Colors.transparent,
                            bordercolor:
                                const BorderSide(width: 1, color: primaryColor),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 0),
                            onlyText: true,
                            titleStyle: CustomTextStyle
                                .styledTextWidget.bodyLarge!
                                .copyWith(
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              color: primaryColor,
                            ),
                            onPress: () {
                              _recordDuration.value = 0;
                              _startRecording();
                            },
                          ),
                          CustomButton(
                            width: 26.w,
                            buttonTitle: 'SEND',
                            backButtonColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            onlyText: true,
                            titleStyle: CustomTextStyle
                                .styledTextWidget.bodyLarge!
                                .copyWith(
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              color: whiteColor,
                            ),
                            onPress: _sendRecording,
                          ),
                        ],
                      )
                    ] else ...[
                      CustomButton(
                        width: 40.w,
                        buttonTitle: 'START RECORDING',
                        backButtonColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 0),
                        onlyText: true,
                        titleStyle: CustomTextStyle.styledTextWidget.bodyLarge!
                            .copyWith(
                          fontSize: (widthScale * kTextFormFactor) * 14,
                          color: whiteColor,
                        ),
                        onPress: _startRecording,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (isRecordingMode)
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: () {
                    if (_recordState.value == RecordState.recording ||
                        _recordState.value == RecordState.paused) {
                      _stopRecording();
                    }
                    _recordState.value = RecordState.idle;
                    _recordDuration.value = 0;
                  },
                  child: SvgPicture.asset(crossProfileIcon),
                ),
              ),
          ],
        );
      }),
    );
  }
}

enum RecordState { idle, ready, recording, paused, stopped }
