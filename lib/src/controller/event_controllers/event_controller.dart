import 'package:closerrr/services/event_services.dart';
import 'package:closerrr/src/models/events/upcoming_events_response.dart';
import 'package:get/get.dart';

import '../../../core/services/custom_services.dart';
import '../../models/events/get_all_friends.dart';

class EventScreenController extends GetxController {
  late EventServices eventServices = EventServices();

  RxList<Events> upcomingEvents = <Events>[].obs;
  RxBool isUpcomingLoading = false.obs;
  RxInt upcomingCurrentPage = 1.obs;
  RxBool hasUpcommingMoreData = true.obs;

  RxList<Friend> allFriends = <Friend>[].obs;
  RxList<Events> friendEvents = <Events>[].obs;

  RxBool isLoading = false.obs;
  RxBool isCreating = false.obs;
  RxList<Events> friendMonthEvents = <Events>[].obs;

  Rx<DateTime> selectedDate = DateTime.now().obs;

  /// [Get Explore Friends]
  Future<void> getUpcomingEvents({
    int? friendId,
    int page = 1,
    int limit = 10,
  }) async {
    if (isUpcomingLoading.value || !hasUpcommingMoreData.value) return;
    isUpcomingLoading.value = true;

    final response = await eventServices.getUpcomingEvents(
      friendId: friendId,
      page: page,
      limit: limit,
    );

    response.fold(
      (l) => kLog(l),
      (r) async {
        if (page == 1) {
          upcomingEvents.clear();
        }
        upcomingEvents.addAll(r.data.rows);
        hasUpcommingMoreData.value = r.data.rows.length == limit;
        upcomingCurrentPage.value = page;
      },
    );

    isUpcomingLoading.value = false;
  }

  Future<void> getUpcomingFriendEvents({
    required int? friendId,
    required int page,
    required int limit,
    String? date,
    bool isMonth = false,
  }) async {
    final response = await eventServices.getUpcomingEvents(
      friendId: friendId,
      page: page,
      limit: limit,
      date: date,
      isMonth: isMonth,
    );

    response.fold(
      (l) => kLog(l),
      (r) async {
        if (isMonth) {
          friendMonthEvents.clear();
          friendMonthEvents.addAll(r.data.rows);
        }
        if (page == 1) {
          friendEvents.clear();
        }
        friendEvents.addAll(r.data.rows);
      },
    );
    isLoading.value = false;
  }

  /// [Add Event]
  Future<bool> addEvent({
    required Map<String, dynamic> event,
    required String id,
  }) async {
    final response = await eventServices.addEvent(
      event: event,
    );
    response.fold(
      (l) {
        return kLog(l);
      },
      (r) async {
        isCreating.value = false;
        friendEvents.add(r.data);
        friendMonthEvents.add(r.data);
        upcomingEvents.add(r.data);
      },
    );

    return response.isRight();
  }

  /// [Edit Event]
  Future<bool> editEvent({
    required Map<String, dynamic> event,
    required String id,
    required String eventId,
  }) async {
    final response = await eventServices.editEvent(
      event: event,
      eventId: eventId,
    );
    response.fold(
      (l) {
        return kLog(l);
      },
      (r) async {
        isCreating.value = false;
        final friendIndex = friendEvents.indexWhere(
          (element) => element.id == int.parse(eventId),
        );
        final monthIndex = friendMonthEvents.indexWhere(
          (element) => element.id == int.parse(eventId),
        );
        final upcomingIndex = upcomingEvents.indexWhere(
          (element) => element.id == int.parse(eventId),
        );
        if (friendIndex != -1) {
          friendEvents[friendIndex] = r.data;
        }
        if (monthIndex != -1) {
          friendMonthEvents[monthIndex] = r.data;
        }
        if (upcomingIndex != -1) {
          upcomingEvents[upcomingIndex] = r.data;
        }
      },
    );

    return response.isRight();
  }

  /// [Edit Event]
  Future<bool> deleteEvent({required String id}) async {
    final response = await eventServices.deleteEvent(id: id);
    response.fold(
      (l) {
        return kLog(l);
      },
      (r) async {
        friendEvents.removeWhere((element) => element.id == int.parse(id));
        friendMonthEvents.removeWhere((element) => element.id == int.parse(id));
        upcomingEvents.removeWhere((element) => element.id == int.parse(id));
      },
    );

    return response.isRight();
  }

  /// [Get All Friends]
  Future<void> getAllFriends() async {
    final response = await eventServices.getAllFriends();
    response.fold(
      (l) => kLog(l),
      (r) async {
        allFriends.clear();
        allFriends.addAll(r.data.rows);
      },
    );
  }
}
