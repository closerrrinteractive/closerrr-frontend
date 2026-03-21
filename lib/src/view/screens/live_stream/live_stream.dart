import 'dart:convert';
import 'dart:ui';

import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../controller/live/live_controller.dart';
import '../../popup/live_stream_control.dart';
import '../../widgets/custom_widgets/custom_button.dart';
import '../../widgets/custom_widgets/custom_text_formfield.dart';

class LiveStream extends StatefulWidget {
  final GoRouterState state;
  const LiveStream({super.key, required this.state});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  // Register dependencies
  final UserInformationController userInformationController = Get.find();
  final LiveController liveController = Get.find();
  final CoreSocketServices socketService = Get.find();
  late final Map extraData;
  final RxList<Map<String, String>> messages = [
    {'name': 'Becky Jacob', 'message': 'Lovely Weather✨😍'},
    {'name': 'Richard Jones', 'message': 'Hi! How are you??!'},
    {'name': 'Geneva Anderson', 'message': 'You look so beautiful😍😍'},
    {
      'name': 'Carla Johnson',
      'message':
          'I’ve been following you since so long.\nCan you share your skincare routine please?!'
    },
  ].obs;

  @override
  void initState() {
    super.initState();
    initStream();
  }

  initStream() {
    socketService.getNewCommentInLiveStream();
    socketService.getEndLiveStream();
    liveController.endLiveStreamEvent.listen((data) {
      extraData["call"].leave();
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    socketService.disposeListeners("new_comment");
    socketService.disposeListeners("end_live_stream");
    liveController.clearLiveStreamData();
    liveController.resetLiveActions();
    socketService.newComments.clear();
  }

  @override
  Widget build(BuildContext context) {
    extraData = widget.state.extra as Map;
    final isHost = extraData["host"] != null;
    final host = isHost
        ? extraData["host"]
        : jsonDecode(extraData["userData"]["meta_data"]);
    List<CallParticipantState> participants = [];

    return Scaffold(
        backgroundColor: blackColor,
        body: SafeArea(
          child: extraData["call"] != null
              ? WillPopScope(
                  onWillPop: () async {
                    if (!liveController.liveActions["start_live"]) {
                      return Future.value(true);
                    }
                    if (isHost) {
                      extraData["call"].end();
                      // update socket
                      await socketService.endLiveStream({
                        "user_id": userInformationController.userData["id"],
                        "id": extraData["id"],
                        "chat_id": extraData["chat_id"],
                        "profile_pic": userInformationController
                            .userData["Profile"]["profile_pic"],
                        "username": userInformationController
                            .userData["Profile"]["fullname"],
                      });
                      // update on our db
                      await liveController.endLiveStream(data: {
                        "live_stream_id": liveController.liveStreamData["id"],
                      });
                    } else {
                      extraData["call"].leave();
                    }

                    return Future.value(true);
                  },
                  child: Stack(
                    children: [
                      StreamBuilder<CallState>(
                          stream: extraData["call"].state.valueStream,
                          initialData: extraData["call"].state.value,
                          builder: (context, snapshot) {
                            final callState = snapshot.data!;
                            participants = callState.callParticipants;
                            final participant = participants.first;

                            if (!isHost) {
                              // print("isHost $isHost");
                              // print(participant.isVideoEnabled);
                              // print(
                              //     liveController.liveActions["camera_enabled"]);
                              if (participant.isVideoEnabled &&
                                  !liveController
                                      .liveActions["camera_enabled"]) {
                                extraData["call"]
                                    .setCameraEnabled(enabled: true);
                              } else if (!participant.isVideoEnabled &&
                                  liveController
                                      .liveActions["camera_enabled"]) {
                                extraData["call"]
                                    .setCameraEnabled(enabled: false);
                              }
                            }

                            if (snapshot.hasData) {
                              return
                                  // stream video render
                                  StreamVideoRenderer(
                                call: extraData["call"],
                                videoTrackType: SfuTrackType.video,
                                participant: participant,
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            // if (snapshot.hasData && callState.status.isDisconnected) {
                            return const Center(
                              child: Text('Stream is not live'),
                            );
                            // }
                          }),
                      Obx(() {
                        if (!liveController.liveActions["show_only_stream"]!) {
                          return header(
                              context,
                              extraData["call"],
                              isHost,
                              host["Profile"],
                              socketService,
                              userInformationController.userData,
                              extraData,
                              liveController);
                        }

                        return const SizedBox();
                      }),
                      Obx(() {
                        if (!liveController.liveActions["camera_enabled"]) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                child: ImageFiltered(
                                  imageFilter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Image.network(
                                    host["Profile"]["profile_pic"] ?? '',
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
                              // Centered clipped image
                              ClipOval(
                                child: Image.network(
                                  host["Profile"]["profile_pic"] ?? '',
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
                            ],
                          );
                        }

                        return const SizedBox();
                      }),
                      Positioned(
                        bottom: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!liveController
                                .liveActions["show_only_stream"]!)
                              commentsSection(socketService, messages),

                            if (!isHost)
                              addCommentSection(
                                  host["id"],
                                  extraData["userData"],
                                  userInformationController.userData,
                                  socketService,
                                  liveController
                                      .liveActions["show_only_stream"],
                                  liveController.toggleAction,
                                  messages),
                            if (isHost)
                              actionButtons(
                                  extraData["call"],
                                  liveController,
                                  userInformationController.userData,
                                  participants.length,
                                  extraData["id"],
                                  extraData["chat_id"])
                            // Text(liveController
                            //       .liveActions["show_only_stream"].toString())
                          ],
                        ),
                      ),
                      Obx(() {
                        if (liveController.isTimerRunning.value) {
                          String count =
                              liveController.counter.value.toString();
                          var style = CustomTextStyle
                              .styledTextWidget.titleMedium
                              ?.copyWith(
                            color: whiteColor,
                            fontSize: count == "0" ? 32.sp : 40.sp,
                            fontWeight: FontWeight.bold,
                          );
                          return Opacity(
                            opacity: 0.6,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: blackColor,
                              child: Center(
                                child: count == "0"
                                    ? Text("You're Live Now!", style: style)
                                    : SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Center(
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                  top: 1.5.h,
                                                  left: 6.5.w,
                                                  child: Text(count,
                                                      style: style)),
                                              Image.asset(
                                                "assets/images/timer.png", // your timer image
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                    ],
                  ))
              : const Text("Something went wrong."),
        ));
  }
}

Widget header(context, call, isHost, host, socketService, userData, extraData,
    liveController) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
    child: Row(
      children: [
        ClipOval(
          child: Image.network(
            host["profile_pic"] ?? '',
            width: 12.w,
            height: 12.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/png/live_stream.png',
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        SizedBox(width: 2.w),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 45.w),
          child: Text(
            host["username"],
            style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: whiteColor,
                overflow: TextOverflow.ellipsis),
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 2.w,
            vertical: 0.6.h,
          ),
          decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Text(
            'LIVE',
            style: CustomTextStyle.styledTextWidget.displayMedium!.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Spacer(),
        CustomIconButton(
          height: 32,
          width: 32,
          borderRadius: BorderRadius.circular(15),
          svg: isHost
              ? 'assets/svg/close_icon_color.svg'
              : 'assets/svg/chat_control.svg',
          padding: const EdgeInsets.all(8),
          onTap: () async {
            if (isHost) {
              if (liveController.liveActions["start_live"]) {
                call.end();
                // update socket
                await socketService.endLiveStream({
                  "user_id": userData["id"],
                  "id": extraData["id"],
                  "chat_id": extraData["chat_id"],
                  "profile_pic": userData["Profile"]["profile_pic"],
                  "username": userData["Profile"]["fullname"],
                });
                // update on our db
                await liveController.endLiveStream(data: {
                  "live_stream_id": liveController.liveStreamData["id"],
                });
              }
              GoRouter.of(context).pop();
            } else {
              // call.leave();
              showDialog(
                context: context,
                builder: (ctx) => LiveStreamControl(
                    call: call, userData: userData, extraData: extraData),
              );
            }
          },
        )
      ],
    ),
  );
}

Widget commentsSection(socketService, messages) {
  final ScrollController scrollController = ScrollController();

  return Container(
    height: 40.h,
    width: 100.w,
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          blackColor.withOpacity(0.5),
          blackColor.withOpacity(0.01),
        ],
      ),
    ),
    child: Obx(() => ListView.builder(
          itemCount: socketService.newComments.length,
          controller: scrollController,
          reverse: true,
          itemBuilder: (BuildContext context, int index) {
            print("newComments are here");
            print(socketService.newComments);

            return MessageItem(
              name: socketService.newComments[index]['name']!,
              message: socketService.newComments[index]['message']!,
            );
          },
        )),
  );
}

Widget bottomContainer({child}) {
  return Container(
      color: Colors.black, width: 100.w, height: 10.h, child: child);
}

Widget addCommentSection(streamId, recievedUserData, userdata, socketService,
    showOnlyStream, toggleAction, messages) {
  final messageController = TextEditingController().obs;
  return Obx(() {
    return bottomContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          !showOnlyStream
              ? Expanded(
                  child: CustomTextFormField(
                    hintText: 'Say Something...',
                    controller: messageController.value,
                    fillColor: transparentColor,
                    isBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: whiteColor,
                      ),
                    ),
                    borderColor: whiteColor,
                    radius: 50,
                    hintStyle:
                        CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                    style:
                        CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                      color: whiteColor,
                    ),
                    cursorColor: whiteColor,
                    containerWidget: GestureDetector(
                      onTap: () {
                        final userProfileData = userdata["Profile"];
                        socketService.addCommentInLiveStream({
                          "id": streamId,
                          "user_id": recievedUserData?["id"] ?? userdata["id"],
                          "name": userProfileData["fullname"],
                          "profile_pic": userProfileData["profile_pic"],
                          "message": messageController.value.text
                        });

                        messageController.value.clear();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: SvgPicture.asset(
                          'assets/svg/send_message.svg',
                          height: 2,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              toggleAction("show_only_stream");
            },
            child: SvgPicture.asset(
              'assets/svg/${showOnlyStream ? 'eye_close' : 'open_eye'}.svg',
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
    );
  });
}

Widget sizedBox13() {
  return SizedBox(width: 13.w);
}

Widget actionButtons(
    call, liveController, userData, participants, streamId, chatId) {
  final CoreSocketServices socketService = Get.find();
  return Obx(() {
    final cameraEnabled = liveController.liveActions["camera_enabled"];
    final micEnabled = liveController.liveActions["mic_enabled"];
    final liveStarted = liveController.liveActions["start_live"];
    final showOnlyStream = liveController.liveActions["show_only_stream"];

    return bottomContainer(
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              call.setCameraEnabled(enabled: !cameraEnabled);
              liveController.toggleAction("camera_enabled");
            },
            child: SvgPicture.asset(
              'assets/svg/live_camera_${!cameraEnabled ? "off_" : ""}icon.svg',
              width: 18.sp,
              height: 18.sp,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              call.setMicrophoneEnabled(enabled: !micEnabled);
              liveController.toggleAction("mic_enabled");
            },
            child: SvgPicture.asset(
              'assets/svg/live_mic_${!micEnabled ? "off_" : ""}icon.svg',
              width: 18.sp,
              height: 18.sp,
            ),
          ),
        ),
        if (!liveStarted) ...[
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // update on our db
                await liveController.startLiveStream(data: {
                  "live_stream_id": streamId,
                  "chat_id": chatId,
                  "host_profile_pic": userData["Profile"]["profile_pic"],
                  "host_name": userData["Profile"]["fullname"],
                  "title": "Live stream started.",
                  "description":
                      '${userData["Profile"]?["fullname"]} is going live'
                });
                socketService.startLiveStream({
                  "user_id": userData["id"],
                  "id": streamId,
                  "chat_id": chatId,
                  "Profile": {
                    "username": userData["Profile"]["fullname"],
                    "profile_pic": userData["Profile"]["profile_pic"],
                  }
                });
                await liveController.startTimer();
                liveController.toggleAction("start_live");
              },
              child: SvgPicture.asset(
                'assets/svg/go_live_icon.svg',
              ),
            ),
          ),
        ],
        if (liveStarted)
          Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset(
                'assets/svg/live_audience_icon.svg',
              ),
              Text(
                participants.toString(),
                style: CustomTextStyle.styledTextWidget.bodySmall
                    ?.copyWith(color: whiteColor, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              call.flipCamera();
              liveController.toggleAction("flip_camera");
            },
            child: SvgPicture.asset(
              'assets/svg/live_camera_swap_icon.svg',
              width: 18.sp,
              height: 18.sp,
            ),
          ),
        ),
        Expanded(
          child: liveStarted
              ? GestureDetector(
                  onTap: () {
                    liveController.toggleAction("show_only_stream");
                  },
                  child: SvgPicture.asset(
                    'assets/svg/${showOnlyStream ? 'eye_close' : 'open_eye'}.svg',
                    width: 18.sp,
                    height: 18.sp,
                  ),
                )
              : const SizedBox(),
        ),
      ]),
    );
  });
}

class MessageItem extends StatelessWidget {
  final String name;
  final String message;

  const MessageItem({
    super.key,
    required this.name,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          name,
          style: CustomTextStyle.styledTextWidget.titleSmall!.copyWith(
            color: whiteColor,
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          message,
          style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }
}
