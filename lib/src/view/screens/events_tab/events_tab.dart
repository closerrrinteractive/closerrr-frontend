import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/custom_no_chat.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/event_group_widget.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/event_info_model.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/friend_event_card.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/upcoming_event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/api_string.dart';
import '../../../models/explore/get_influencer_response.dart';
import '../../widgets/custom_widgets/custom_search_bar.dart';

class EventsTab extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const EventsTab({
    super.key,
    required this.navigationShell,
  });

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  EventScreenController eventController = Get.find();
  final userInfoController = Get.find<UserInformationController>();

  @override
  void initState() {
    super.initState();
    getUpcomingEvents();

    if (!userInfoController.isInfluencer.value) {
      getAllFriends();
    }
  }

  getUpcomingEvents() => eventController.getUpcomingEvents();
  getAllFriends() => eventController.getAllFriends();

  @override
  Widget build(BuildContext context) {
    Map profile = userInfoController.userData.value['Profile'];
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: const CustomSearchBar(
        isEvents: true,
        icon: 'assets/svg/calender.svg',
        title: 'Events',
        gif: eventsGif,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() => SizedBox(
              height: eventController.allFriends.isEmpty &&
                      eventController.upcomingEvents.isEmpty
                  ? 60.h
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (eventController.allFriends.isEmpty &&
                      eventController.upcomingEvents.isEmpty) ...{
                    CustomNoChat(
                      title: 'No Events Yet!',
                      subtitle: 'Make Friends Here- ',
                      isEvent: true,
                      navigationShell: widget.navigationShell,
                    ),
                  },
                  if (eventController.upcomingEvents.isNotEmpty) ...{
                    EventsGroup(
                      title: 'Upcoming Events',
                      showViewAll: true,
                      leadingIcon: SvgPicture.asset(
                        upcomingEventIcon,
                        height: 2.h,
                      ),
                      onTapShowAll: () => context.goNamed('upcoming_events'),
                      child: Column(
                        children: [
                          ...List.generate(
                              eventController.upcomingEvents.value.length >= 2
                                  ? 2
                                  : 1, (index) {
                            final event =
                                eventController.upcomingEvents.value[index];
                            final time = DateFormat('dd, MMMM, yyyy | h:mm a')
                                .format(DateTime.parse(
                                    event.time.toIso8601String()));
                            return UpcomingEventCard(
                              onTap: () {
                                showCustomBottomSheet(
                                  context,
                                  event,
                                  time,
                                  profile["fullname"] ?? profile["username"],
                                );
                              },
                              posterUrl: event.image ??
                                  'https://via.placeholder.com/150',
                              time: time,
                              title: event.name,
                              byAuthor: userInfoController.isInfluencer.value
                                  ? profile["fullname"] ?? profile["username"]
                                  : event.user?.profile.username ?? '',
                            );
                          }),
                        ],
                      ),
                    ),
                  },
                  if (userInfoController.isInfluencer.value ||
                      eventController.allFriends.isNotEmpty)
                    EventsGroup(
                      title: userInfoController.isInfluencer.value
                          ? 'Your Events'
                          : 'Friend\'s Events',
                      showViewAll: !userInfoController.isInfluencer.value &&
                          eventController.allFriends.length > 3,
                      leadingIcon: SvgPicture.asset(
                        friendEventIcon,
                        height: 2.h,
                      ),
                      onTapShowAll: () => context.goNamed('all_friends'),
                      child: Column(
                        children: [
                          ...List.generate(
                            eventController.allFriends.isEmpty &&
                                    userInfoController.isInfluencer.value
                                ? 1
                                : eventController.allFriends.length,
                            (index) {
                              if (eventController.allFriends.isEmpty &&
                                  userInfoController.isInfluencer.value) {
                                final userData =
                                    userInfoController.userData.value;
                                Map? profile = userData['Profile'];

                                return FriendEventCard(
                                  name: profile?['fullname'] ??
                                      profile?['username'] ??
                                      '',
                                  profileUrl: ApiStrings.imageUrl +
                                      (profile?['profile_pic'] ?? ''),
                                  onTap: () {
                                    final profilePic = ApiStrings.imageUrl +
                                        (profile?['profile_pic'] ?? '');

                                    context.goNamed(
                                      'friends_events',
                                      extra: {
                                        'friend': Profile(
                                          id: userData['id'],
                                          username: profile?['fullname'] ??
                                              profile?['username'],
                                          profilePic: profilePic,
                                        ),
                                      },
                                    );
                                  },
                                );
                              }

                              final friend = eventController.allFriends[index];
                              return FriendEventCard(
                                name: friend.profile.username,
                                profileUrl: ApiStrings.imageUrl +
                                    (friend.profile.profilePic ?? ''),
                                onTap: () {
                                  context.goNamed(
                                    'friends_events',
                                    extra: {
                                      'friend': Profile(
                                        id: friend.id,
                                        username: friend.profile.username,
                                        profilePic: ApiStrings.imageUrl +
                                            (friend.profile.profilePic ?? ''),
                                      ),
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }
}
