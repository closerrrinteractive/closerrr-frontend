import 'package:closerrr/src/view/popup/chat/chat_media_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/api_string.dart';
import '../../../core/utils/constant_string.dart';
import '../../../core/utils/img_string.dart';

class MediaPreviewAlert extends StatefulWidget {
  const MediaPreviewAlert(
      {super.key, required this.imagesToPreview, this.index});
  final List<String> imagesToPreview;
  final int? index;

  @override
  State<MediaPreviewAlert> createState() => _MediaPreviewAlertState();
}

class _MediaPreviewAlertState extends State<MediaPreviewAlert> {
  late PageController pageController;
  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: widget.index ?? 0);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: widget.imagesToPreview.length,
                  itemBuilder: (context, index) {
                    String eventPoster = widget.imagesToPreview[index];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => MediaPopup(
                            media: eventPoster,
                            id: 0,
                            mediaDownloadTitle: "Image",
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        child: InteractiveViewer(
                          child: Image.network(
                            eventPoster.contains('http')
                                ? eventPoster
                                : ApiStrings.baseUrl + eventPoster,
                            // width: double.maxFinite,
                            fit: BoxFit.fitWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                width: 80,
                                height: 100,
                                child: Image.asset(
                                  Constants.eventImage,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // height: 320,
                // width: 100.w,
                // child:
                //     Image.network(eventPoster.contains('http') ? eventPoster : ApiStrings.baseUrl + eventPoster,
                //         // width: double.maxFinite,
                //         fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                //   return SizedBox(
                //     width: 80,
                //     height: 100,
                //     child: Image.asset(
                //       Constants.eventImage,
                //       fit: BoxFit.cover,
                //     ),
                //   );
                // }),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Image(
                    height: 54,
                    width: 54,
                    image: AssetImage(backIcon),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
