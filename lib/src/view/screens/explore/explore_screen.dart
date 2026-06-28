import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/config/helpers.dart';
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

import '../../../../core/config/haptic_helper.dart';
import '../../../../core/utils/constant.dart';
import '../../../controller/chat/chat_controller.dart';
import '../../widgets/custom_widgets/custom_search_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const bool forceEmptyExplore = false;

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

  Future<void> _openInfluencerChat(int influencerUserId) async {
    var chat = chatController.chats.firstWhereOrNull(
      (c) => c.users.any((user) => user.id == influencerUserId),
    );
    if (chat == null) {
      await chatController.getChats(page: 1);
      chat = chatController.chats.firstWhereOrNull(
        (c) => c.users.any((user) => user.id == influencerUserId),
      );
    }
    if (chat != null && mounted) {
      context.push('/chat/chat_message', extra: {'chat': chat});
      return;
    }
    widget.navigationShell.goBranch(1);
    navbarController.selectIndex.value = 1;
    Helpers.toast('Open your chat from the Chats tab');
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: CustomSearchBar(
        isEvents: false,
        icon: heartSearchIcon,
        title: 'Explore',
        searchHint: 'Search Friends',
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
            Obx(() {
              if (chatController.isSearching.value) {
                return const SizedBox.shrink();
              }
              final sequence = ['All', 'Popular', 'Friends'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sequence.map((cat) {
                          final isSelected = exploreScreenController.selectedCategory.value == cat;
                          return GestureDetector(
                            onTap: () {
                              HapticHelper.trigger(type: HapticFeedbackType.light);
                              exploreScreenController.changeCategory(cat);
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 3.w),
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.7.h),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : primaryColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20.sp),
                                border: Border.all(
                                  color: isSelected ? primaryColor : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: CustomTextStyle.styledTextWidget.labelMedium!.copyWith(
                                  color: isSelected ? whiteColor : primaryColor,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              );
            }),
            Expanded(
              child: Obx(() {
                if (exploreScreenController.isLoading.value &&
                    exploreScreenController.influencers.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }
                return (forceEmptyExplore || exploreScreenController.influencers.value.isEmpty)
                    ? Center(
                        child: CustomNoChat(
                          isChat: false,
                          isEvent: false,
                          title: 'No Friends Found!',
                          subtitle: '',
                          navigationShell: widget.navigationShell,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: exploreScreenController.influencers.length,
                        itemBuilder: (context, index) {
                          final influencer =
                              exploreScreenController.influencers[index];
                          final profile = influencer.profile;

                          return GestureDetector(
                            onTap: () {
                              context.push(
                                '/explore/explore-profile',
                                extra: {
                                  'influencer': influencer.toJson(),
                                  'influencerId': influencer.id.toString(),
                                  'navigationShell': widget.navigationShell,
                                },
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 0.6.h),
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(16.sp),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    offset: const Offset(0, 8),
                                    blurRadius: 24,
                                    spreadRadius: -2,
                                  )
                                ],
                              ),
                              child: SizedBox(
                                height: 6.h,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ClipOval(
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
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (profile?.fullname?.isNotEmpty == true
                                                    ? profile?.fullname
                                                    : profile?.username) ??
                                                '',
                                            overflow: TextOverflow.ellipsis,
                                            style: CustomTextStyle
                                                .styledTextWidget.labelMedium!
                                                .copyWith(
                                              color: mainTextColor,
                                              fontWeight: FontWeight.bold,
                                              height: 1.1,
                                              fontSize:
                                                  (widthScale * kTextFormFactor) * 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            profile?.username != null
                                                ? '@${profile!.username}'
                                                : '',
                                            style: CustomTextStyle
                                                .styledTextWidget.headlineLarge!
                                                .copyWith(
                                              color: textColor,
                                              fontWeight: FontWeight.w600,
                                              height: 1.1,
                                              fontSize:
                                                  (widthScale * kTextFormFactor) * 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (influencer.isFriend.value) {
                                            _openInfluencerChat(influencer.id);
                                          } else {
                                            context.push(
                                              '/explore/explore-profile',
                                              extra: {
                                                'influencer': influencer.toJson(),
                                                'influencerId':
                                                    influencer.id.toString(),
                                                'navigationShell':
                                                    widget.navigationShell,
                                              },
                                            );
                                          }
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
                                                ? "CHAT NOW"
                                                : "ADD FRIEND",
                                            style: CustomTextStyle
                                                .styledTextWidget.labelMedium!
                                                .copyWith(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize:
                                                  (widthScale * kTextFormFactor) *
                                                      10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
