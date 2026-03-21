import 'dart:async';

import 'package:closerrr/core/services/custom_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  // final Connectivity _connectivity = Connectivity();
  bool _isInitialConnection = true; // Add this flag

  @override
  void onInit() {
    super.onInit();
    Connectivity().onConnectivityChanged.listen(_updateConnectionState);
  }

  Future<void> _updateConnectionState(
      List<ConnectivityResult> connectivityResult) async {
    if (connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile)) {
      // Show the message only if it's not the initial connection state
      if (!_isInitialConnection) {
        CustomSnackbar.show(
          title: 'Internet Connection',
          message: 'Connected',
          isError: false,
        );
      }
      // Update the flag after the initial connection state
      _isInitialConnection = false;
    } else {
      CustomSnackbar.show(
        title: 'Internet Connection',
        message: 'Please connect to the internet',
        isError: true,
      );
    }
  }
}
