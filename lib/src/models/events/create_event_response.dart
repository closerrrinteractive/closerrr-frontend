import 'package:closerrr/src/models/events/upcoming_events_response.dart';

class CreateEventResponse {
  String status;
  String message;
  Events data;
  int statusCode;

  CreateEventResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory CreateEventResponse.fromJson(Map<String, dynamic> json) =>
      CreateEventResponse(
        status: json["status"] ?? json["error_type"],
        message: json["message"] ?? json["error_message"],
        data: Events.fromJson(json["data"]),
        statusCode: json["statusCode"] ?? json["error_code"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "statusCode": statusCode,
      };
}
