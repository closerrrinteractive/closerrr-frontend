import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/themes/colors.dart';
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
    this.initialIndex = 0,
  });

  final RxList<ShowcaseData> showcaseData;
  final Influencer influencer;
  final int initialIndex;

  @override
  State<ExploreGalleryView> createState() => _ExploreGalleryViewState();
}

class _ExploreGalleryViewState extends State<ExploreGalleryView> {
  final RxInt selectedIndex = 0.obs;
  late final PageController _pageController;
  ExploreScreenController exploreScreenController = Get.find();

  Profile? get profile => widget.influencer.profile;

  String get displayName =>
      (profile?.fullname?.isNotEmpty == true
          ? profile?.fullname
          : profile?.username) ??
      '';

  String get avatarUrl {
    final pic = profile?.profilePic;
    if (pic != null && pic.toString().isNotEmpty) {
      return ApiStrings.imageUrl + pic.toString();
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    selectedIndex.value = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Obx(() {
          final slides = widget.showcaseData;
          if (slides.isEmpty) {
            return const Center(
              child: Text(
                'No photos',
                style: TextStyle(fontFamily: 'Hellix', color: textColor),
              ),
            );
          }
          return Column(
            children: [
              // ── Header: avatar + name + close ──────────────────────────
              _buildHeader(widthScale),
              // ── Main image (full width, expands) ───────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (i) => selectedIndex.value = i,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: ApiStrings.imageUrl + slides[index].path,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 1.5,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: textColor, size: 48),
                      ),
                    );
                  },
                ),
              ),
              // ── Thumbnail strip ────────────────────────────────────────
              _buildThumbnailStrip(slides, bottomPad),
            ],
          );
        }),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double widthScale) {
    return Container(
      color: whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
            ),
            child: ClipOval(
              child: avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _defaultAvatar(),
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 1,
                        ),
                      ),
                    )
                  : _defaultAvatar(),
            ),
          ),
          const SizedBox(width: 8),
          // Name
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontFamily: 'Hellix',
                color: primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: (widthScale * kTextFormFactor) * 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () => RouterController.current.pop(context),
            child: SvgPicture.asset(
              icrossSvgIcon,
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }

  // ── Thumbnail strip ───────────────────────────────────────────────────────

  Widget _buildThumbnailStrip(List<ShowcaseData> slides, double bottomPad) {
    return Container(
      color: whiteColor,
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + bottomPad,
      ),
      child: Obx(() {
        final children = List.generate(slides.length, (index) {
          final isSelected = selectedIndex.value == index;
          return GestureDetector(
            onTap: () {
              selectedIndex.value = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColorFiltered(
                  colorFilter: isSelected
                      ? const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        )
                      : ColorFilter.mode(
                          Colors.white.withOpacity(0.45),
                          BlendMode.lighten,
                        ),
                  child: CachedNetworkImage(
                    imageUrl: ApiStrings.imageUrl + slides[index].path,
                    fit: BoxFit.cover,
                    width: 64,
                    height: 64,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFFE8E8E8),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFE8E8E8),
                      child: const Icon(Icons.broken_image_outlined,
                          size: 22, color: textColor),
                    ),
                  ),
                ),
              ),
            ),
          );
        });

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        );
      }),
    );
  }

  Widget _defaultAvatar() => Image.asset(person, fit: BoxFit.cover);
}
