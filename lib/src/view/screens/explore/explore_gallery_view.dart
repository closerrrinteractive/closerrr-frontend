import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';
import '../../../controller/routing/routing_controller.dart';
import '../../../models/explore/get_influencer_response.dart';
import '../../../models/showcase/get_showcase.dart';

class ExploreGalleryView extends StatefulWidget {
  const ExploreGalleryView({
    super.key,
    required this.showcaseData,
    required this.influencer,
  });

  final RxList<ShowcaseData> showcaseData;
  final Influencer influencer;

  @override
  State<ExploreGalleryView> createState() => _ExploreGalleryViewState();
}

class _ExploreGalleryViewState extends State<ExploreGalleryView> {
  final selectedIndex = 0.obs;
  ExploreScreenController exploreScreenController = Get.find();
  UserInformationController userInformationController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: Container(),
        leadingWidth: 0,
        toolbarHeight: 10.h,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () {
                RouterController.current.pop(context);
              },
              child: Image(
                height: 4.h,
                width: 4.h,
                image: const AssetImage(
                  crossIcon,
                ),
              ),
            ),
          )
        ],
        title: Row(
          children: [
            CachedNetworkImage(
              imageUrl: ApiStrings.s3ImageUrl +
                  (widget.influencer.profile?.profilePic ?? ''),
              fit: BoxFit.cover,
              errorWidget: (context, error, stackTrace) {
                return const CircleAvatar(
                  backgroundColor: whiteColor,
                  radius: 22,
                  child: Image(
                    image: AssetImage(person),
                    fit: BoxFit.cover,
                  ),
                );
              },
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 1,
                  ),
                );
              },
            ),
            SizedBox(width: 2.w),
            Text(
              widget.influencer.profile?.fullname ?? widget.influencer.profile?.username ?? '',
              style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                color: primaryColor,
                fontSize: (widthScale * kTextFormFactor) * 18,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() => Container(
            height: 100.h,
            color: whiteColor,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                      imageUrl: ApiStrings.s3ImageUrl +
                          widget.showcaseData[selectedIndex.value].path,
                      width: 100.w,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100.w,
                  height: 30.w,
                  padding: EdgeInsets.only(bottom: 4.w),
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemCount: userInformationController.isInfluencer.value
                        ? widget.showcaseData.length + 1
                        : widget.showcaseData.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (index == widget.showcaseData.length) {
                                return;
                              }
                              selectedIndex.value = index;
                            },
                            child: Container(
                              height: 65,
                              width: 65,
                              padding: EdgeInsets.all(
                                selectedIndex.value == index ? 0 : 5,
                              ),
                              margin: EdgeInsets.only(
                                right: (userInformationController
                                            .isInfluencer.value
                                        ? widget.showcaseData.length != index
                                        : widget.showcaseData.length !=
                                            index + 1)
                                    ? 4
                                    : 40.w,
                                left: index != 0 ? 4 : 40.w,
                                bottom: 20,
                                top: 20,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: index == widget.showcaseData.length
                                    ? Container(
                                        color: primaryColor,
                                        padding: const EdgeInsets.all(14),
                                        child: SvgPicture.asset(
                                          addIcon,
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: ApiStrings.s3ImageUrl +
                                            widget.showcaseData[index].path,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        colorBlendMode: BlendMode.dstOut,
                                        color: selectedIndex.value == index
                                            ? Colors.transparent
                                            : Colors.white.withOpacity(0.5),
                                      ),
                              ),
                            ),
                          ),
                          if (index != widget.showcaseData.length)
                            Positioned(
                              top: 16,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (index == widget.showcaseData.length) {
                                    return;
                                  }
                                  widget.showcaseData.removeAt(index);
                                  selectedIndex.value =
                                      index != 0 ? index - 1 : index;
                                },
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor,
                                  ),
                                  child: SvgPicture.asset(
                                    closeIcon,
                                    color: whiteColor,
                                    height: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
