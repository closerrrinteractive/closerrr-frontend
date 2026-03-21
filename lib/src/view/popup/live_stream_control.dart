import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/src/controller/live/live_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_popup_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/colors.dart';
import '../../../core/themes/text_style.dart';
import '../../controller/routing/routing_controller.dart';

class LiveStreamControl extends StatefulWidget {
  final bool? isMessageSent;
  final bool? isDownloading;
  final dynamic call;
  final dynamic userData;
  final dynamic extraData;
  // final bool? isReporting;

  const LiveStreamControl(
      {super.key,
      this.isMessageSent,
      this.isDownloading,
      this.call,
      this.userData,
      this.extraData
      // this.isReporting,
      });

  @override
  State<LiveStreamControl> createState() => _LiveStreamControlState();
}

class _LiveStreamControlState extends State<LiveStreamControl> {
  final isReporting = false.obs;
  final LiveController liveController = Get.find();
  final CoreSocketServices socketService = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparentColor,
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: popColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Options',
                style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              PopupCustomBtn(
                isActions: true,
                isChat: isReporting.value ? false : true,
                title:
                    isReporting.value ? 'Report Comment' : 'Exit Closerrr Live',
                svg: isReporting.value ? null : 'assets/svg/exit.svg',
                icon: isReporting.value ? Icons.report : null,
                ontap: () async {
                  // close the popUp
                  Navigator.pop(context);
                  // kll karenge
                  if (isReporting.value) {
                    RouterController.current.pop();
                  } else {
                    // function to end stream from getStream.io
                    widget.call.end();
                    // update socket
                    await socketService.endLiveStream({
                      "user_id": widget.userData["id"],
                      "id": widget.extraData["id"],
                      "chat_id": widget.extraData["chat_id"],
                      "profile_pic": widget.userData["Profile"]["profile_pic"],
                      "username": widget.userData["Profile"]["username"],
                    });
                    // update on our db
                    await liveController.endLiveStream(data: {
                      "live_stream_id": liveController.liveStreamData["id"],
                    });
                    RouterController.current.pop();
                  }
                },
              ),
              if (!isReporting.value) ...{
                SizedBox(height: 1.h),
                PopupCustomBtn(
                  isActions: true,
                  icon: Icons.report,
                  title: 'Report Live',
                  ontap: () {
                    isReporting.value = true;
                  },
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
