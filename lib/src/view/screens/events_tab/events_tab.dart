import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/custom_no_chat.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/event_info_model.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/upcoming_event_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'package:closerrr/core/config/haptic_helper.dart';
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
  static const bool forceEmptyUpcomingEvents = false;
  static const bool forceEmptyFriendsList = false;

  EventScreenController eventController = Get.find();
  final userInfoController = Get.find<UserInformationController>();
  final RxString selectedCategory = 'Upcoming'.obs;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _fetchUpcomingEvents(page: 1);

    if (!userInfoController.isInfluencer.value) {
      getAllFriends();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !eventController.isUpcomingLoading.value) {
      if (eventController.hasUpcommingMoreData.value) {
        _fetchUpcomingEvents(page: eventController.upcomingCurrentPage.value + 1);
      }
    }
  }

  Future<void> _fetchUpcomingEvents({required int page}) async {
    if (page == 1) {
      eventController.hasUpcommingMoreData.value = true;
    }
    await eventController.getUpcomingEvents(page: page);
  }

  void getAllFriends() => eventController.getAllFriends();

  String _profileName({String fallback = ''}) {
    final profile = userInfoController.userData.value['Profile'];
    return profile is Map
        ? (profile['fullname'] ?? profile['username'] ?? fallback)
        : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final double scale = widthScale * kTextFormFactor;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: const CustomSearchBar(
        isEvents: true,
        icon: 'assets/svg/calender.svg',
        title: 'Events',
        gif: eventsGif,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.w),
        child: Column(
          children: [
            Obx(() {
              final sequence = ['Upcoming', 'Friends'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sequence.map((cat) {
                          final isSelected = selectedCategory.value == cat;
                          return GestureDetector(
                            onTap: () {
                              HapticHelper.trigger(type: HapticFeedbackType.light);
                              if (selectedCategory.value != cat) {
                                selectedCategory.value = cat;
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 3.w),
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.7.h),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : primaryColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20.sp),
                                border: Border.all(
                                  color: isSelected ? primaryColor : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                                  color: isSelected ? whiteColor : primaryColor,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              );
            }),

            // Tab Content
            Expanded(
              child: Obx(() {
                final bool hasNoFriends = forceEmptyFriendsList || eventController.allFriends.isEmpty;
                if (selectedCategory.value == 'Upcoming') {
                  if (eventController.isUpcomingLoading.value &&
                      eventController.upcomingEvents.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }
                  if (forceEmptyUpcomingEvents || eventController.upcomingEvents.isEmpty) {
                    if (hasNoFriends) {
                      return CustomNoChat(
                        title: 'No Friends Yet!',
                        subtitle: 'Make Friends Here- ',
                        isEvent: true,
                        navigationShell: widget.navigationShell,
                      );
                    } else {
                      return CustomNoChat(
                        title: 'No Upcoming Events!',
                        subtitle: 'Stay tuned for something special✨',
                        isEvent: false,
                        navigationShell: widget.navigationShell,
                      );
                    }
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: eventController.upcomingEvents.length +
                        (eventController.hasUpcommingMoreData.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == eventController.upcomingEvents.length) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }
                      final event = eventController.upcomingEvents[index];
                      final time = DateFormat('E, d MMM, yyyy | h:mm a')
                          .format(DateTime.parse(event.time.toIso8601String()));
                      final profileName = _profileName();
                      final currentUserProfilePic = userInfoController.userData.value['Profile']?['profile_pic'];

                      return UpcomingEventCard(
                        onTap: () {
                          showCustomBottomSheet(
                            context,
                            event,
                            time,
                            profileName,
                          );
                        },
                        title: event.name,
                        posterUrl: event.getEventPoster(currentUserProfilePic),
                        byAuthor: userInfoController.isInfluencer.value
                            ? _profileName()
                            : event.user?.profile.fullname ??
                                event.user?.profile.username ??
                                '',
                        time: time,
                      );
                    },
                  );
                } else {
                  // Friends category
                  if (hasNoFriends) {
                    return CustomNoChat(
                      title: 'No Friends Yet!',
                      subtitle: 'Make Friends Here- ',
                      isEvent: true,
                      navigationShell: widget.navigationShell,
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: eventController.allFriends.length,
                    itemBuilder: (context, index) {
                      final friend = eventController.allFriends[index];
                      return GestureDetector(
                        onTap: () {
                          context.goNamed(
                            'friends_events',
                            extra: {
                              'friend': Profile(
                                id: friend.id,
                                username: friend.profile.username,
                                fullname: friend.profile.fullname,
                                profilePic: ApiStrings.imageUrl +
                                    (friend.profile.profilePic ?? ''),
                              ),
                            },
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 0.6.h),
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(16.sp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                offset: const Offset(0, 8),
                                blurRadius: 24,
                                spreadRadius: -2,
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: ApiStrings.imageUrl + (friend.profile.profilePic ?? ''),
                                  height: 6.h,
                                  width: 6.h,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, error, stackTrace) => Image(
                                    image: const AssetImage(person),
                                    height: 6.h,
                                    width: 6.h,
                                  ),
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (friend.profile.fullname?.isNotEmpty == true
                                              ? friend.profile.fullname
                                              : friend.profile.username) ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                                        color: mainTextColor,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                        fontSize: 16 * scale,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '@${friend.profile.username}',
                                      style: CustomTextStyle.styledTextWidget.headlineLarge!.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                        height: 1.1,
                                        fontSize: 11 * scale,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: primaryColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
