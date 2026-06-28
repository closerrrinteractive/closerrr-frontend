import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:closerrr/src/controller/settings_controller/preferences_controller.dart';

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

class HapticHelper {
  static void trigger({HapticFeedbackType type = HapticFeedbackType.light}) {
    try {
      if (Get.isRegistered<PreferencesController>()) {
        final PreferencesController controller = Get.find<PreferencesController>();
        if (!controller.isHapticEnabled.value) return;
      }

      switch (type) {
        case HapticFeedbackType.light:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.medium:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.heavy:
          HapticFeedback.vibrate();
          break;
        case HapticFeedbackType.selection:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.vibrate:
          HapticFeedback.vibrate();
          break;
      }
    } catch (_) {
      // Safely ignore failures if engine is initializing
    }
  }
}
