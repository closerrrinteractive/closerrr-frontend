import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/upcoming_event_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../../../main.dart';
import '../../../controller/routing/routing_controller.dart';
import '../../widgets/specific_widgets/event/event_info_model.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  final EventScreenController eventController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitialEvents();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !eventController.isUpcomingLoading.value) {
        _fetchMoreEvents();
      }
    });
  }

  Future<void> _fetchInitialEvents() async {
    await eventController.getUpcomingEvents(page: 1, limit: 10);
  }

  Future<void> _fetchMoreEvents() async {
    if (!eventController.hasUpcommingMoreData.value) return;
    await eventController.getUpcomingEvents(
      page: eventController.upcomingCurrentPage.value + 1,
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        toolbarHeight: 8.h,
        surfaceTintColor: transparentColor,
        elevation: 12,
        backgroundColor: whiteColor,
        shadowColor: blueBack.withOpacity(0.1),
        title: Row(
          children: [
            InkWell(
              onTap: () => RouterController.current.pop(),
              overlayColor: const WidgetStatePropertyAll(transparentColor),
              child: Image(
                image: const AssetImage(
                  backIcon,
                ),
                height: 5.5.h,
              ),
            ),
            SizedBox(width: 1.5.w),
            Text(
              'Upcoming Events',
              style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                color: primaryColor,
                fontSize: (widthScale * kTextFormFactor) * 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Circe',
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          return eventController.upcomingEvents.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(2.h),
                  itemCount: eventController.upcomingEvents.length +
                      (eventController.hasUpcommingMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == eventController.upcomingEvents.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final event = eventController.upcomingEvents[index];
                    final time = DateFormat('dd, MMMM, yyyy | h:mm a')
                        .format(DateTime.parse(event.time.toIso8601String()));
                    Map profile =
                        userInformationController.userData.value['Profile'];

                    return UpcomingEventCard(
                      onTap: () {
                        showCustomBottomSheet(
                          context,
                          event,
                          time,
                          profile['fullname'] ?? profile['username'],
                        );
                      },
                      title: event.name,
                      posterUrl: event.image ?? '',
                      byAuthor: event.user?.profile.fullname ??
                          event.user?.profile.username ??
                          profile['fullname'] ??
                          profile['username'] ??
                          '',
                      time: time,
                    );
                  },
                );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
