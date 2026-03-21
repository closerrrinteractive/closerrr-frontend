import 'package:closerrr/src/models/events/create_event_response.dart';
import 'package:closerrr/src/models/events/upcoming_events_response.dart';
import 'package:dartz/dartz.dart';

import '../core/utils/api_string.dart';
import '../core/utils/failure.dart';
import '../main.dart';
import '../src/models/events/get_all_friends.dart';

class EventServices {
  Future<Either<Failure, EventsResponse>> getUpcomingEvents({
    int? friendId,
    int? page,
    int? limit,
    String? date,
    bool isMonth = false,
  }) async {
    try {
      final response = await httpService.get(
        ApiStrings.getEvents,
        queryParameters: {
          if (friendId != null) 'friendId': friendId,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (date != null) 'date': date,
          if (isMonth) 'isMonth': isMonth,
        },
      );

      return Right(EventsResponse.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, CreateEventResponse>> addEvent({
    required Map<String, dynamic> event,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.addEvent,
        data: event,
        isFormData: true,
      );
      return Right(CreateEventResponse.fromJson(response.data));
    } catch (e, s) {
      return Left(ServerFailure(message: e.toString(), stackTrace: s));
    }
  }

  Future<Either<Failure, CreateEventResponse>> editEvent({
    required Map<String, dynamic> event,
    required String eventId,
  }) async {
    try {
      final response = await httpService.patch(
        ApiStrings.editEvent + ("/$eventId"),
        data: event,
        isFormData: true,
      );
      return Right(CreateEventResponse.fromJson(response.data));
    } catch (e, s) {
      return Left(ServerFailure(message: e.toString(), stackTrace: s));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> deleteEvent(
      {required String id}) async {
    try {
      final response = await httpService.delete(
        "${ApiStrings.deleteEvent}/$id",
        // queryParameters: {
        //   "evenId": id,
        // },
      );
      return Right(response.data);
    } catch (e, s) {
      return Left(ServerFailure(message: e.toString(), stackTrace: s));
    }
  }

  Future<Either<Failure, GetAllFriendsResponse>> getAllFriends() async {
    try {
      final response = await httpService.get(ApiStrings.getAllFriends);
      return Right(GetAllFriendsResponse.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
