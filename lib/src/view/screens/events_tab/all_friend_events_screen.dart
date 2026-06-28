import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/explore/get_influencer_response.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/event/friend_event_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../../controller/routing/routing_controller.dart';

class AllFriendEventsScreen extends StatefulWidget {
  const AllFriendEventsScreen({super.key});

  @override
  State<AllFriendEventsScreen> createState() => _AllFriendEventsScreenState();
}

class _AllFriendEventsScreenState extends State<AllFriendEventsScreen> {
  final EventScreenController eventController = Get.find();
  final UserInformationController userInfoController = Get.find();

  @override
  void initState() {
    super.initState();

    if (!userInfoController.isInfluencer.value) {
      getAllFriends();
    }
  }

  getAllFriends() => eventController.getAllFriends();

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Scaffold(
      backgroundColor: whiteColor,
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
                image: const AssetImage(backIcon),
                height: 5.5.h,
              ),
            ),
            SizedBox(width: 1.5.w),
            Text(
              userInfoController.isInfluencer.value
                  ? 'Your Events'
                  : 'Friend\'s Events',
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
      body: Obx(() => SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  if (eventController.isLoading.value) ...{
                    SizedBox(height: 2.h),
                    const Center(child: CircularProgressIndicator()),
                  } else ...{
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventController.allFriends.length,
                      itemBuilder: (context, index) {
                        final allFriends = eventController.allFriends[index];
                        return FriendEventCard(
                          name: allFriends.profile.fullname ??
                              allFriends.profile.username,
                          profileUrl: ApiStrings.imageUrl +
                              (allFriends.profile.profilePic ?? ''),
                          onTap: () {
                            context.goNamed(
                              'friends_events',
                              extra: {
                                'friend': Profile(
                                  id: allFriends.id,
                                  username: allFriends.profile.fullname ??
                                      allFriends.profile.username,
                                  profilePic: ApiStrings.imageUrl +
                                      (allFriends.profile.profilePic ?? ''),
                                ),
                              },
                            );
                          },
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          )),
    );
  }
}
