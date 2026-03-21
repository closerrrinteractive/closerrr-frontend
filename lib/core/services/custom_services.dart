import 'dart:async';

import 'package:closerrr/core/themes/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = true,
  }) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? logOutColor : buttonColor,
        textColor: whiteColor,
        fontSize: 16.0);
  }
}

class CustomLoader {
  static void show() {
    Get.dialog(
      Center(
        child: LoadingAnimationWidget.inkDrop(
          color: primaryColor,
          size: 50,
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    Get.back();
  }
}

class Debouncer {
  final Duration delay;
  final Function(dynamic) action;
  Timer? _timer;

  Debouncer(this.delay, this.action);

  void call(dynamic value) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      action(value);
    });
  }
}

void infiniteScroll(
  ScrollController controller,
  RxInt page,
  RxInt total,
  Future<void> Function() getFunction,
  RxBool isInfiniteLoading,
) {
  page.value = 1;
  getFunction();
  controller.addListener(() async {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      isInfiniteLoading.value = true;
      if (page.value < total.value / 10) {
        page.value++;
        await getFunction();
        isInfiniteLoading.value = false;
      }
    }
  });
}

Widget showCircularProgressIndicator() {
  return const CircularProgressIndicator();
}

kLog(value, {error = false}) {
  if (kDebugMode) {
    Logger logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 60,
        // colors: true,
        // printEmojis: true,
      ),
    );

    if (error) {
      return logger.e(value);
    }

    logger.d(value);
  }
}

bool isSuccessStatusCode(int statusCode) {
  return statusCode >= 200 && statusCode < 300;
}
