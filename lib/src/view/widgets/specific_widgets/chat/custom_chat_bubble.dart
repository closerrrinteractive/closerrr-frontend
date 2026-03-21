import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_square_shimmer.dart';
import 'package:closerrr/src/view/widgets/media_preview_alert.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/audio_chat_bubble.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/video_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/config/helpers.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/themes/text_style.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../controller/chat/chat_controller.dart';
import 'special_chat_bubble.dart';

// Compression Wrapper Widget
class CompressionWrapper extends StatelessWidget {
  final String? status;
  final String type;
  final Widget child;
  final double? shimmerSize;
  final bool isRectangle;

  const CompressionWrapper(
      {super.key,
      required this.status,
      required this.type,
      required this.child,
      this.shimmerSize,
      this.isRectangle = false});

  @override
  Widget build(BuildContext context) {
    if (status == "initiated" || status == "uploading") {
      return SquareShimmer(
        size: shimmerSize ?? _getDefaultShimmerSize(),
        isRectangle: isRectangle,
      );
    } else if (status == "compressing") {
      return Container(
        color: whiteColor,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/gif/adding-final-touches.gif",
              width: 85,
            ),
            Text(
              "ADDING FINISHING TOUCHES!",
              style: CustomTextStyle.styledTextWidget.labelSmall,
            )
          ],
        )),
      );
    }
    return child;
  }

  double _getDefaultShimmerSize() {
    switch (type) {
      case 'image':
      case 'video':
        return 200;
      case 'audio':
        return 60;
      default:
        return 200;
    }
  }
}

class BubbleSpecialOne extends StatefulWidget {
  final bool isSender;
  final String textMessage;
  final bool tail;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final String createdAt;
  final TextStyle? textStyle;
  final Color? nameColor;
  final Color? timeColor;
  final BoxConstraints? constraints;
  final String profilePic;
  final String fullName;
  final repliedMessage;
  final String? mediaUrl;
  final String type;
  final String userId;
  final String id;
  final String? searchQuery;
  final int? activeSearch;
  final bool? isFavoriteMessage;
  final String? status;

  const BubbleSpecialOne({
    super.key,
    this.isSender = true,
    this.constraints,
    required this.textMessage,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.nameColor,
    this.timeColor,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    required this.createdAt,
    required this.profilePic,
    required this.fullName,
    this.repliedMessage,
    this.mediaUrl,
    this.searchQuery,
    this.activeSearch,
    required this.type,
    required this.userId,
    required this.id,
    this.isFavoriteMessage,
    this.status,
  });

  @override
  State<BubbleSpecialOne> createState() => _BubbleSpecialOneState();
}

class _BubbleSpecialOneState extends State<BubbleSpecialOne>
    with AutomaticKeepAliveClientMixin {
  final ChatController chatController = Get.find();
  late GlobalKey messageKey;

  @override
  void initState() {
    super.initState();
    messageKey = GlobalKey();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToMessageIfMatched());
  }

  void _scrollToMessageIfMatched() {
    final query = widget.searchQuery?.trim().toLowerCase();
    if (query == null || query.isEmpty) return;

    final textMatch = widget.textMessage.toLowerCase().contains(query);
    final replyMatch = widget.repliedMessage != null &&
        widget.repliedMessage.text.toLowerCase().contains(query);

    if (textMatch || replyMatch) {
      final context = messageKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Container(
      key: messageKey,
      alignment: widget.isSender ? Alignment.topRight : Alignment.topLeft,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            widget.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isSender)
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: widget.profilePic,
                height: 36,
                width: 36,
                fit: BoxFit.cover,
                color: Colors.white,
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: backScreenColor,
                  child: Image.asset(person),
                ),
              ),
            ),
          CustomPaint(
            painter: SpecialChatBubbleOne(
              color: widget.color,
              alignment:
                  widget.isSender ? Alignment.topRight : Alignment.topLeft,
              tail: widget.tail,
            ),
            child: Container(
              constraints: widget.constraints ??
                  BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .7,
                    minWidth: 140,
                  ),
              margin: widget.isSender
                  ? const EdgeInsets.fromLTRB(10, 7, 20, 7)
                  : const EdgeInsets.fromLTRB(20, 7, 8, 7),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.isSender)
                        Text(
                          widget.fullName,
                          style: CustomTextStyle.styledTextWidget.bodyMedium!
                              .copyWith(
                            color: widget.nameColor ?? whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: (widthScale * kTextFormFactor) * 16,
                          ),
                        ),
                      SizedBox(height: 0.5.h),
                      if (widget.repliedMessage != null) ...[
                        _buildReplyMessage(widthScale),
                        SizedBox(height: 0.5.h),
                      ],
                      if (widget.mediaUrl != null) _buildMediaPreview(),
                      if (widget.textMessage.isNotEmpty)
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: widget.textStyle ??
                                CustomTextStyle.styledTextWidget.labelLarge!
                                    .copyWith(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: (widthScale * kTextFormFactor) * 14,
                                ),
                            children: Helpers.buildHighlightedTextSpans(
                              widget.textMessage,
                              widget.searchQuery,
                              widget.activeSearch,
                              widget.isSender,
                            ),
                          ),
                        ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [SizedBox(height: 2.h, width: 35.w)],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: widget.isSender ? 0 : null,
                    right: !widget.isSender ? 0 : null,
                    child: Row(
                      children: [
                        if (widget.isFavoriteMessage == true &&
                            !widget.isSender)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: SvgPicture.asset(
                              'assets/svg/memories.svg',
                              height: 14,
                              color: widget.timeColor ?? headingColor,
                            ),
                          ),
                        Text(
                          widget.createdAt.toString(),
                          style: CustomTextStyle.styledTextWidget.labelMedium!
                              .copyWith(
                            color: widget.timeColor ?? blueBack,
                            fontWeight: FontWeight.w500,
                            fontSize: (widthScale * kTextFormFactor) * 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isFavoriteMessage == true && widget.isSender)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: SvgPicture.asset(
                              'assets/svg/memories.svg',
                              height: 14,
                              color: widget.timeColor ?? headingColor,
                            ),
                          ),
                        if (!userInformationController.isInfluencer.value &&
                            widget.isSender) ...{
                          Text(
                            widget.seen ? 'Read' : 'Unread',
                            style: CustomTextStyle.styledTextWidget.labelMedium!
                                .copyWith(
                              color: whiteColor,
                              fontWeight: FontWeight.w500,
                              fontSize: (widthScale * kTextFormFactor) * 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/svg/${widget.seen ? 'message_sent_icon' : 'message_unread'}.svg',
                            color: whiteColor,
                            height: 10,
                          ),
                        }
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (widget.type == 'image') {
      return Column(
        children: [
          CompressionWrapper(
            status: widget.status,
            type: 'image',
            shimmerSize: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => MediaPreviewAlert(
                      imagesToPreview:
                          widget.mediaUrl == null ? [] : [widget.mediaUrl!],
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: widget.mediaUrl ?? '',
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 250,
                    height: 250,
                    color: backScreenColor,
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
        ],
      );
    } else if (widget.type == 'video') {
      return Column(
        children: [
          SizedBox(
            height: 250,
            width: 250,
            child: CompressionWrapper(
              status: widget.status,
              type: 'video',
              shimmerSize: 250,
              child: VideoBubbleLoader(
                mediaUrl: widget.mediaUrl!,
                isSender: widget.isSender,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
        ],
      );
    } else if (widget.type == 'audio') {
      return CompressionWrapper(
        status: widget.status,
        type: 'audio',
        isRectangle: true,
        child: AudioChatBubble(
          id: widget.id,
          isSender: widget.isSender,
          mediaUrl: widget.mediaUrl ?? '',
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Container _buildReplyMessage(double widthScale) {
    final replyMesssage = widget.repliedMessage;
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            widget.isSender ? chatRepliesColor.withOpacity(0.8) : primaryColor,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // if(replyMesssage!.metadata)

          Container(
            width: 5,
            constraints: replyMesssage!.linkPreviewData != null
                ? const BoxConstraints(maxHeight: 250)
                : BoxConstraints(minHeight: 6.h),
            decoration: BoxDecoration(
              color: !widget.isSender ? chatRepliesColor : primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(width: 2.w),
          Helpers.getRowCol(
            isRow: (replyMesssage!.linkPreviewData != null)
                ? replyMesssage!.linkPreviewData!.image!.height == 50
                : false,
            children: [
              Text(
                widget.isSender
                    ? (replyMesssage?.metadata['author'].name ?? '')
                    : replyMesssage!.metadata['author'].id == widget.userId
                        ? replyMesssage!.linkPreviewData == null
                            ? 'Replied to You: '
                            : 'Replied to Story: '
                        : 'Replied to:',
                style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                  color: !widget.isSender ? whiteColor : primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: (widthScale * kTextFormFactor) * 16,
                ),
                textAlign: TextAlign.left,
              ),
              if (replyMesssage!.linkPreviewData != null) ...{
                SizedBox(height: 1.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    replyMesssage!.linkPreviewData!.image!.url,
                    height: 60.w,
                    width: 60.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.error,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
              },
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((replyMesssage?.text ?? '').isNotEmpty) ...[
                    SizedBox(
                      width: (replyMesssage?.text ?? '').length < 200
                          ? 60.w
                          : 63.w,
                      child: Text(
                        (replyMesssage?.text ?? ''),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: CustomTextStyle.styledTextWidget.labelMedium!
                            .copyWith(
                          color: !widget.isSender ? whiteColor : blackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: (widthScale * kTextFormFactor) * 16,
                        ),
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
