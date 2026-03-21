import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:closerrr/src/controller/navbar_cntrollers/navbar_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/custom_no_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/constant.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../../controller/routing/routing_controller.dart';
import '../../widgets/custom_widgets/custom_search_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController controller = TextEditingController();

  final ExploreScreenController exploreScreenController = Get.find();
  ChatController chatController = Get.find();
  final NavbarController navbarController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getInfluencers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !exploreScreenController.isLoading.value) {
      getInfluencers();
    }
  }

  getInfluencers() async {
    await exploreScreenController.getInfluencers(
      name: exploreScreenController.exploreSearchController.text,
    );
  }

  Timer? debounce;

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: CustomSearchBar(
        isEvents: false,
        icon: heartSearchIcon,
        title: 'Explore',
        searchHint: 'Enter Name  of Your Favorite Artist',
        gif: exploreGif,
        searchController: exploreScreenController.exploreSearchController,
        onClose: () {
          exploreScreenController.currentPage.value = 1;
          chatController.isSearching.value = false;
          exploreScreenController.exploreSearchController.clear();
          exploreScreenController.influencers.clear();
          exploreScreenController.getInfluencers(name: '');
        },
        onSearch: (value) {
          exploreScreenController.currentPage.value = 1;
          debounce?.cancel();
          debounce = Timer(const Duration(milliseconds: 800), () {
            exploreScreenController.getInfluencers(
              name: exploreScreenController.exploreSearchController.text,
            );
          });
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.w),
        child: Column(
          children: [
            Row(
              children: [
                Image(
                  image: const AssetImage(handShake),
                  height: 2.5.h,
                ),
                SizedBox(width: 1.w),
                Text(
                  "Explore All Friends",
                  style: CustomTextStyle.styledTextWidget.labelMedium!
                      .copyWith(color: headingColor, fontSize: 15.sp),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Obx(() {
                return exploreScreenController.influencers.value.isEmpty
                    ? Center(
                        child: CustomNoChat(
                          isChat: false,
                          isEvent: false,
                          title: 'No Influencer Found',
                          subtitle: '',
                          navigationShell: widget.navigationShell,
                        ),
                      )
                    : ListView.builder(
                        itemCount: exploreScreenController.influencers.length,
                        itemBuilder: (context, index) {
                          final influencer =
                              exploreScreenController.influencers[index];
                          final profile = influencer.profile;

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 1.h),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(16.sp),
                              boxShadow: [
                                BoxShadow(
                                  color: textColor.withOpacity(0.6),
                                  offset: const Offset(1, 3),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 3.w),
                              onTap: () {
                                RouterController.current.go(
                                  "/explore/explore-profile",
                                  extra: {
                                    'influencer': influencer.toJson(),
                                    'influencerId': "78612",
                                    'navigationShell': widget.navigationShell,
                                  },
                                );
                              },
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: ApiStrings.imageUrl +
                                      (profile?.profilePic ?? ''),
                                  height: 6.h,
                                  width: 6.h,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, error, stackTrace) =>
                                      Image(
                                    image: const AssetImage(person),
                                    height: 6.h,
                                    width: 6.h,
                                  ),
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      (profile?.fullname?.isNotEmpty == true
                                              ? profile?.fullname
                                              : profile?.username) ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                      style: CustomTextStyle
                                          .styledTextWidget.labelMedium!
                                          .copyWith(
                                        color: mainTextColor,
                                        fontSize:
                                            (widthScale * kTextFormFactor) * 16,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      widget.navigationShell.goBranch(1);
                                      navbarController.selectIndex.value = 1;
                                      chatController.isSearching.value = false;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0.5.h, horizontal: 4.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.sp),
                                        color: primaryColor.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        influencer.isFriend.value
                                            ? "Chat Now"
                                            : "Add Friend",
                                        style: CustomTextStyle
                                            .styledTextWidget.labelMedium!
                                            .copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize:
                                              (widthScale * kTextFormFactor) *
                                                  10,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  profile?.username ?? '',
                                  style: CustomTextStyle
                                      .styledTextWidget.headlineLarge!
                                      .copyWith(
                                    color: textColor,
                                    height: 1.5,
                                    fontSize:
                                        (widthScale * kTextFormFactor) * 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      );
              }),
            )
          ],
        ),
      ),
    );
  }
}
