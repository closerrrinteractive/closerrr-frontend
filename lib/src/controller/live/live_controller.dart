import 'dart:async';

import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/services/live_stream_service.dart';
import 'package:get/get.dart';
import 'package:stream_video/stream_video.dart';

class LiveController extends GetxController {
  Map liveStreamData = {};
  final LiveStreamService liveStreamService = LiveStreamService();
  var newLiveStreamEvent =
      Rxn<Map<String, dynamic>>(); // holds the latest new livestream
  var endLiveStreamEvent = Rxn<Map<String, dynamic>>();
  RxInt counter = 3.obs;
  RxBool isTimerRunning = false.obs;
  Timer? _timer;
  final RxMap<String, dynamic> liveActions = {
    "camera_enabled": true,
    "mic_enabled": true,
    "flip_camera": false,
    "start_live": false,
    "show_only_stream": false,
    "participants": <CallParticipantState>[]
  }.obs;

  Future<void> startTimer() async {
    if (isTimerRunning.value) return;
    isTimerRunning.value = true;

    // Create a Completer to handle the async completion
    Completer<void> completer = Completer<void>();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter.value > 0) {
        counter.value--;
      } else {
        stopTimer();
        // Timer finished - complete the Future
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    // Wait for the timer to complete
    await completer.future;
  }

  void stopTimer() {
    _timer?.cancel();
    isTimerRunning.value = false;
    counter.value = 3;
  }

  void resetTimer({int initialValue = 3}) {
    stopTimer();
    counter.value = initialValue;
  }

  void toggleAction(String key) {
    liveActions[key] = !(liveActions[key] ?? false);
  }

  void resetLiveActions() {
    liveActions["camera_enabled"] = true;
    liveActions["mic_enabled"] = true;
    liveActions["flip_camera"] = false;
    liveActions["start_live"] = false;
    liveActions["show_only_stream"] = false;
    liveActions["participants"] = <CallParticipantState>[];
  }

  void clearLiveStreamData() {
    liveStreamData = {};
  }

  Future<void> startLiveStream({required Map<String, dynamic> data}) async {
    final response = await liveStreamService.startLiveStream(data: data);
    response.fold(
      (l) {
        return kLog(l);
      },
      (r) {
        liveStreamData = r["data"];
        return kLog(r);
      },
    );
  }

  Future<void> endLiveStream({required Map<String, dynamic> data}) async {
    final response = await liveStreamService.endLiveStream(data: data);
    response.fold(
      (l) {
        return kLog(l);
      },
      (r) {
        return kLog(r);
      },
    );
  }

  Future<void> addCommentToLiveStream(
      {required Map<String, dynamic> data}) async {
    final response = await liveStreamService.addCommentToLiveStream(data: data);
    response.fold(
      (l) {
        return kLog(l);
      },
      (r) {
        return kLog(r);
      },
    );
  }
}
