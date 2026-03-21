import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/models/events/get_all_friends.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
  Profile? profile = friendEvent.user?.profile;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: transparentColor,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: EventBottomSheetDetails(
              eventPoster:
                  friendEvent.image ?? 'https://via.placeholder.com/150',
              eventName: friendEvent.name,
              eventDateAndTime: time,
              eventVenue: friendEvent.venue,
              eventDetails: friendEvent.details ?? '',
              eventByAuthor: profile?.fullname ?? profile?.username ?? userName,
            ),
          );
        },
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
  });

  final String eventPoster;
  final String eventName;
  final String eventDateAndTime;
  final String eventVenue;
  final String eventDetails;
  final String eventByAuthor;

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Container(
      height: 100.h,
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: <Widget>[
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  RouterController.current
                      .goNamed('image_preview_screen', extra: {
                    'eventPoster': eventPoster,
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
                          width: 80,
                          height: 100,
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
                    color: const Color(0xFFEFDDFF),
                  ),
                ),
              ),
              Positioned(
                right: 2.h,
                top: 2.h,
                child: InkWell(
                  onTap: () => RouterController.current.pop(context),
                  child: Image(
                    image: const AssetImage(crossIcon),
                    height: 3.h,
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
          SizedBox(height: 2.h),
        ],
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
