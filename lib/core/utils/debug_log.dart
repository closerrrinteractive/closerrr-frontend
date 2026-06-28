import 'dart:convert';

import 'package:closerrr/core/utils/api_string.dart';
import 'package:http/http.dart' as http;

/// Session debug logger — relays logs via the local backend (reachable from iPhone).
class DebugLog {
  static const _sessionId = '691a90';

  static void write({
    required String location,
    required String message,
    required String hypothesisId,
    Map<String, dynamic>? data,
    String runId = 'pre-fix',
  }) {
    final payload = {
      'sessionId': _sessionId,
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data ?? {},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    http
        .post(
          Uri.parse('${ApiStrings.baseUrl}debug/client-log'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .catchError((_) => http.Response('', 500));
  }
}
