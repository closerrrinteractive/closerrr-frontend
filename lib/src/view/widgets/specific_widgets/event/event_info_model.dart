import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';

import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/constant_string.dart';
import '../../../../controller/routing/routing_controller.dart';
import '../../../../models/events/upcoming_events_response.dart';

void showCustomBottomSheet(
  BuildContext context,
  Events friendEvent,
  String time,
  String userName,
) {
  final UserInformationController userInformationController = Get.find<UserInformationController>();
  final currentUserProfile = userInformationController.userData.value['Profile'];

  String eventByAuthor = userName;
  String? authorUsername;

  if (friendEvent.user != null) {
    eventByAuthor = friendEvent.user?.profile.fullname ?? friendEvent.user?.profile.username ?? userName;
    authorUsername = friendEvent.user?.profile.username;
  } else if (currentUserProfile is Map) {
    eventByAuthor = currentUserProfile['fullname'] ?? currentUserProfile['username'] ?? userName;
    authorUsername = currentUserProfile['username'];
  }

  final String currentUserProfilePic = currentUserProfile is Map ? currentUserProfile['profile_pic'] ?? '' : '';
  final String influencerPic = friendEvent.user?.profile.profilePic ?? currentUserProfilePic;
  final String resolvedPoster = friendEvent.getEventPoster(currentUserProfilePic);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: transparentColor,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 90.h,
          ),
          child: EventBottomSheetDetails(
            eventPoster: resolvedPoster,
            eventName: friendEvent.name,
            eventDateAndTime: time,
            eventVenue: friendEvent.venue,
            eventDetails: friendEvent.details ?? '',
            eventByAuthor: eventByAuthor,
            authorUsername: authorUsername,
            influencerProfilePic: influencerPic,
          ),
        ),
      );
    },
  );
}

class EventBottomSheetDetails extends StatelessWidget {
  const EventBottomSheetDetails({
    super.key,
    required this.eventPoster,
    required this.eventName,
    required this.eventDateAndTime,
    required this.eventVenue,
    required this.eventDetails,
    required this.eventByAuthor,
    this.authorUsername,
    this.influencerProfilePic,
  });

  final String eventPoster;
  final String eventName;
  final String eventDateAndTime;
  final String eventVenue;
  final String eventDetails;
  final String eventByAuthor;
  final String? authorUsername;
  final String? influencerProfilePic;

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Container(
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  HapticHelper.trigger(type: HapticFeedbackType.light);
                  Navigator.pop(context);
                  RouterController.current
                      .pushNamed('image_preview_screen', extra: {
                    'imagesToPreview': [eventPoster],
                    'isEvent': true,
                    'eventName': eventName,
                    'eventTime': eventDateAndTime,
                    'influencerProfilePic': influencerProfilePic,
                  });
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: SizedBox(
                    height: 320,
                    width: 100.w,
                    child: Hero(
                      tag: eventPoster,
                      child: Image.network(
                          eventPoster.contains('http')
                              ? eventPoster
                              : ApiStrings.baseUrl + eventPoster,
                          width: double.maxFinite,
                          height: 360,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: double.maxFinite,
                          height: 320,
                          child: Image.asset(
                            Constants.eventImage,
                            fit: BoxFit.cover,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  width: 2.w,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 45.w, vertical: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primaryColor,
                  ),
                ),
              ),
              Positioned(
                right: 2.h,
                top: 2.h,
                child: InkWell(
                  onTap: () {
                    HapticHelper.trigger(type: HapticFeedbackType.light);
                    RouterController.current.pop(context);
                  },
                  child: SvgPicture.asset(
                    piccrossSvgIcon,
                    height: 3.h,
                    width: 3.h,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 2.h),
          EventInfoModelGroupWidget(
            label: 'Name',
            title: eventName,
          ),
          EventInfoModelGroupWidget(
            label: 'Date & Time',
            title: eventDateAndTime,
          ),
          if (eventVenue.isNotEmpty)
            EventInfoModelGroupWidget(
              label: 'Venue',
              title: eventVenue,
            ),
          if (eventDetails.isNotEmpty)
            EventInfoModelGroupWidget(
              label: 'Event Details',
              title: eventDetails,
              isBold: false,
            ),
          Center(
            child: Text(
              "By - $eventByAuthor",
              style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                color: primaryColor,
                fontSize: (widthScale * kTextFormFactor) * 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hellix',
              ),
            ),
          ),
          if (authorUsername != null && authorUsername!.isNotEmpty) ...[
            Center(
              child: Text(
                authorUsername!.startsWith('@') ? authorUsername!.toLowerCase() : "@${authorUsername!.toLowerCase()}",
                style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  color: textColor,
                  fontSize: (widthScale * kTextFormFactor) * 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Hellix',
                ),
              ),
            ),
          ],
          SizedBox(height: 3.h),
        ],
      ),
    ),
  ),
);
  }
}

class EventInfoModelGroupWidget extends StatelessWidget {
  const EventInfoModelGroupWidget({
    super.key,
    required this.label,
    required this.title,
    this.isBold,
  });
  final String label;
  final String title;
  final bool? isBold;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(width: 1, color: Colors.grey.shade200)),
      ),
      width: double.maxFinite,
      margin: EdgeInsets.only(left: 3.h, right: 3.h, bottom: 1.5.h),
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyle.styledTextWidget.bodyLarge!
                .copyWith(fontSize: 10.sp, color: primaryColor),
          ),
          Text(
            title,
            // maxLines: 2,
            // overflow: TextOverflow.ellipsis,
            style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
              fontSize: isBold == false ? 13.sp : 14.sp,
              fontWeight: isBold == false ? null : FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
