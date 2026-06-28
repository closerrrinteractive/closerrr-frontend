import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class PreferencesController extends GetxController {
  final RxBool isAppLockEnabled = false.obs;
  final RxBool isPipEnabled = false.obs;
  final RxBool isHapticEnabled = true.obs;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isAppLockEnabled.value = prefs.getBool('pref_app_lock') ?? false;
    isPipEnabled.value = prefs.getBool('pref_pip') ?? false;
    isHapticEnabled.value = prefs.getBool('pref_haptic') ?? true;
  }

  Future<bool> toggleAppLock(bool value) async {
    if (value) {
      final authenticated = await authenticateUser(
        reason: 'Please authenticate to enable App Lock',
      );
      if (authenticated) {
        isAppLockEnabled.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pref_app_lock', true);
        return true;
      }
      return false;
    } else {
      final authenticated = await authenticateUser(
        reason: 'Please authenticate to disable App Lock',
      );
      if (authenticated) {
        isAppLockEnabled.value = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pref_app_lock', false);
        return true;
      }
      return false;
    }
  }

  Future<void> togglePip(bool value) async {
    isPipEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_pip', value);
  }

  Future<void> toggleHaptic(bool value) async {
    isHapticEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_haptic', value);
  }

  Future<bool> authenticateUser({required String reason}) async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        return false;
      }

      return await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print("Authentication error: $e");
      return false;
    }
  }
}
