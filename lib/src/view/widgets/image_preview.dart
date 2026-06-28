import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/models/chat/chat_model.dart';
import 'package:closerrr/src/view/popup/chat/chat_media_popup.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/api_string.dart';
import '../../../core/utils/constant_string.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({
    super.key,
    required this.imagesToPreview,
    this.index,
    this.isChat,
    this.chatAdmin,
    this.chat,
    this.isEvent,
    this.eventName,
    this.eventTime,
    this.influencerProfilePic,
  });
  final List<String> imagesToPreview;
  final int? index;
  final bool? isChat;
  final UserProfile? chatAdmin;
  final ChatRowData? chat;
  final bool? isEvent;
  final String? eventName;
  final String? eventTime;
  final String? influencerProfilePic;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late PageController pageController;
  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: widget.index ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        isMediaView: true,
        chatAdmin: widget.chatAdmin,
        chatIcon: widget.chat?.groupIcon,
        isEventPreview: widget.isEvent,
        eventName: widget.eventName,
        eventTime: widget.eventTime,
        influencerProfilePic: widget.influencerProfilePic,
        controlTap: () {
          showDialog(
            context: context,
            builder: (ctx) => MediaPopup(
              chatId: widget.chat?.id ?? 0,
              mediaDownloadTitle: "Image",
              media: (widget.imagesToPreview.isNotEmpty)
                  ? widget.imagesToPreview[0]
                  : '',
              id: 0,
              chat: widget.chat,
              simulateError: false,
            ),
          );
        },
      ),
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
                    String imageUrl = widget.imagesToPreview[index];
                    if (widget.isChat ?? false) {
                      imageUrl = widget.chat?.groupIcon?.value ??
                          widget.imagesToPreview[index];
                    }
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => MediaPopup(
                            media: imageUrl,
                            id: 0,
                            mediaDownloadTitle: "Image",
                            simulateError: false,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        child: InteractiveViewer(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl.contains('http')
                                ? imageUrl
                                : ApiStrings.imageUrl + imageUrl,
                            fit: BoxFit.fitWidth,
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                              child: CircularProgressIndicator(
                                value: progress.progress,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) {
                              return SizedBox(
                                width: 80,
                                height: 100,
                                child: (widget.chat?.id ?? 0) != 0
                                    ? Image.asset(person)
                                    : Image.asset(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
