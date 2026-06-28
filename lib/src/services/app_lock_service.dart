import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:closerrr/src/controller/settings_controller/preferences_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/lock_screen_widget.dart';

class AppLockService extends GetxService with WidgetsBindingObserver {
  final PreferencesController preferencesController = Get.find<PreferencesController>();
  bool isLocked = false;
  bool isLockScreenShowing = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (preferencesController.isAppLockEnabled.value) {
        isLocked = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (isLocked) {
        showLockOverlay();
      }
    }
  }

  Future<void> showLockOverlay() async {
    if (isLockScreenShowing) return;
    isLockScreenShowing = true;

    await Get.dialog(
      PopScope(
        canPop: false,
        child: LockScreenWidget(
          onAuthenticated: () {
            isLocked = false;
            isLockScreenShowing = false;
            Get.back();
          },
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      useSafeArea: false,
    );
  }
}
