import 'dart:convert';
import 'dart:ui';

import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/live/live_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../services/live_stream_service.dart';

class StreamCall extends StatefulWidget {
  final GoRouterState state;
  const StreamCall({super.key, required this.state});

  @override
  State<StreamCall> createState() => _StreamCallState();
}

class _StreamCallState extends State<StreamCall> {
  final callEnd = false.obs;
  final callAccept = false.obs;
  final LiveController liveController = Get.find();
  final CoreSocketServices socketService = Get.find();
  final ChatController chatController = Get.find();

  @override
  void initState() {
    super.initState();
    chatController.userEvent.listen((data) {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final extraData = widget.state.extra as Map?;
    final userData = extraData?["userData"];

    return Scaffold(
        body: userData != null
            ? Obx(() => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Image.network(
                          ApiStrings.s3ImageUrl + userData["profile_pic"],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/png/live_stream.png',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: callAccept.value || callEnd.value ? 1 : 2,
                          child: const SizedBox(),
                        ),
                        Expanded(
                          flex: callAccept.value || callEnd.value ? 1 : 2,
                          child: Column(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  ApiStrings.s3ImageUrl +
                                      userData["profile_pic"],
                                  width: 40.w, // adjust as needed
                                  height: 40.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/png/live_stream.png',
                                      width: 30.w,
                                      height: 30.w,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                callAccept.value
                                    ? userData["username"]
                                    : callEnd.value
                                        ? 'Live Call Ended'
                                        : userData["username"],
                                style: CustomTextStyle
                                    .styledTextWidget.bodySmall!
                                    .copyWith(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!callAccept.value && !callEnd.value)
                                Text(
                                  'Calling You Closerrr...',
                                  style: CustomTextStyle
                                      .styledTextWidget.labelMedium!
                                      .copyWith(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (!callEnd.value && !callAccept.value) ...{
                                _buildCallButton(
                                  icon: Icons.call,
                                  color: callAcceptColor,
                                  label: 'Accept',
                                  onPressed: () async {
                                    callAccept.value = true;
                                    await Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () async {
                                      String streamId = jsonDecode(
                                          userData["meta_data"])["id"];
                                      final data = await LiveStreamService()
                                          .startLivestream(
                                              id: userData["id"],
                                              join: true,
                                              streamId: streamId);
                                      await socketService.startLiveStream({
                                        "user_id": userData["id"],
                                        "id": streamId,
                                        "isJoin": true
                                      });
                                      context.pushReplacementNamed(
                                          "live_stream",
                                          extra: {
                                            'call': data["call"],
                                            'userData': userData
                                          });
                                    });
                                  },
                                ),
                                _buildCallButton(
                                  icon: Icons.call_end,
                                  color: callHangColor,
                                  label: 'Decline',
                                  onPressed: () {
                                    callEnd.value = true;
                                    context.pop();
                                  },
                                ),
                              } else ...{
                                Column(
                                  children: [
                                    Text(
                                      callAccept.value
                                          ? 'Hang Tight!'
                                          : callEnd.value
                                              ? 'Thanks For Joining!'
                                              : 'Stay Tuned',
                                      style: CustomTextStyle
                                          .styledTextWidget.labelLarge!
                                          .copyWith(
                                        color: whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    SizedBox(
                                      width: 50.w,
                                      child: Text(
                                        callAccept.value
                                            ? 'Just A Few Final Touches... Fun Starts Soon!'
                                            : callEnd.value
                                                ? 'See You Soon.'
                                                : 'Will Be Back In A Moment.',
                                        textAlign: TextAlign.center,
                                        style: CustomTextStyle
                                            .styledTextWidget.labelMedium!
                                            .copyWith(
                                          color: whiteColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              }
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ))
            : const SizedBox());
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required String label,
    required Function()? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: whiteColor,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
              color: whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
