import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/upcoming_event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../../../main.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../controller/routing/routing_controller.dart';
import '../../../models/explore/get_influencer_response.dart';
import '../../widgets/specific_widgets/event/event_info_model.dart';
import 'widgets/event_calender.dart';

class FriendsEventsScreen extends StatefulWidget {
  final Profile profile;
  const FriendsEventsScreen({
    super.key,
    required this.profile,
    this.isChat,
    this.chatUser,
    this.chatId,
    this.closerDays,
    this.chat,
  });
  final bool? isChat;
  final ChatUser? chatUser;
  final int? chatId;
  final String? closerDays;
  final ChatRowData? chat;

  @override
  State<FriendsEventsScreen> createState() => _FriendsEventsScreenState();
}

class _FriendsEventsScreenState extends State<FriendsEventsScreen> {
  static const bool forceEmptyFriendEvents = false;

  final EventScreenController eventController = Get.find();
  final uiController = Get.find<UserInformationController>();

  @override
  void initState() {
    super.initState();
    getFriendEvent();
  }

  getFriendEvent() {
    eventController.getUpcomingFriendEvents(
      friendId: widget.profile.id,
      page: 1,
      limit: 50,
      isMonth: true,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      // isMonth: true,
    );
    // eventController.getUpcomingFriendEvents(
    //   friendId: widget.profile.id,
    //   page: 1,
    //   limit: 50,
    //   date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blueBack.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticHelper.trigger(type: HapticFeedbackType.light);
                      RouterController.current.pop();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withOpacity(0.08),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            backSvgIcon,
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => Text(
                          uiController.isInfluencer.value
                              ? 'Your Events'
                              : 'Friend\'s Events',
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: (widthScale * kTextFormFactor) * 18,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                Container(
                  margin: EdgeInsets.only(top: 3.h, bottom: 3.h),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(74),
                        child: Image.network(
                          (widget.profile.profilePic ?? ''),
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              person,
                              width: 74,
                              height: 74,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.profile.fullname ?? widget.profile.username,
                        style: CustomTextStyle.styledTextWidget.labelMedium!
                            .copyWith(
                          fontSize: (widthScale * kTextFormFactor) * 24,
                          color: primaryColor,
                          fontFamily: 'Hellix',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: CalendarWidget(
                    friendId: widget.profile.id,
                  ),
                ),
                if (eventController.isLoading.value) ...{
                  SizedBox(height: 2.h),
                  const Center(child: CircularProgressIndicator()),
                } else if (forceEmptyFriendEvents || eventController.friendEvents.isEmpty) ...{
                  SizedBox(height: 2.h),
                  SvgPicture.asset(
                    'assets/svg/calendar_empty.svg',
                    height: 10.h,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Sorry! No Events For This Date.',
                    style:
                        CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                      fontSize: (widthScale * kTextFormFactor) * 16,
                      color: headingColor,
                      fontFamily: 'AnnieUseYourTelescope',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.15,
                    ),
                  ),
                  SizedBox(height: 2.h),
                } else ...{
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: eventController.friendEvents.length,
                    itemBuilder: (context, index) {
                      final friendEvent = eventController.friendEvents[index];
                      final time = DateFormat('E, d MMM, yyyy | h:mm a')
                          .format(friendEvent.time);
                      final profile =
                          userInformationController.userData.value['Profile'];
                      final profileName = profile is Map
                          ? (profile['fullname'] ?? profile['username'] ?? '')
                          : '';

                      return UpcomingEventCard(
                        onTap: () {
                          if (userInformationController.isInfluencer.value) {
                            context.pushNamed(
                              widget.isChat ?? false
                                  ? "chat_friends_create_event"
                                  : "friends_create_event",
                              extra: {
                                'friend': widget.profile,
                                'chat_id': widget.chatId,
                                'event': friendEvent,
                                'isEdit': true,
                                'chat': widget.chat,
                              },
                            );
                          } else {
                            showCustomBottomSheet(
                              context,
                              friendEvent,
                              time,
                              profileName,
                            );
                          }
                        },
                        title: friendEvent.name,
                        posterUrl: friendEvent.getEventPoster(widget.profile.profilePic),
                        byAuthor: friendEvent.user?.profile.fullname ??
                            friendEvent.user?.profile.username ??
                            profileName,
                        time: time,
                      );
                    },
                  ),
                }
              ],
            ),
          ),
        ),
      ),
    ],
  ),
),
      floatingActionButton: userInformationController.isInfluencer.value
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                context.goNamed(
                    widget.isChat ?? false
                        ? "chat_friends_create_event"
                        : 'friends_create_event',
                    extra: {
                      'friend': widget.profile,
                      'chat_id': widget.chatId,
                      'profile': UserProfile(
                        id: widget.profile.id,
                        username:
                            widget.profile.fullname ?? widget.profile.username,
                        profilePic: widget.profile.profilePic,
                      ).toJson(),
                      'chat': widget.chat,
                    });
              },
              child: SvgPicture.asset(
                addIcon,
                height: 3.h,
              ),
            )
          : null,
    );
  }
}
