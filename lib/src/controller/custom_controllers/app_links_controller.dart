import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AppLinkController extends GetxController {
  String? _pendingRoute;
  Map<String, dynamic>? _pendingExtra;

  void setPendingRoute(String route, Map<String, dynamic>? extra) {
    _pendingRoute = route;
    _pendingExtra = extra;
    debugPrint('Pending route set: $_pendingRoute with extra: $_pendingExtra');
  }

  void clearPendingRoute() {
    _pendingRoute = null;
    _pendingExtra = null;
  }

  String? get pendingRoute => _pendingRoute;
  Map<String, dynamic>? get pendingExtra => _pendingExtra;

  bool get hasPendingRoute => _pendingRoute != null;
}
