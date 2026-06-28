import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:closerrr/src/controller/navbar_cntrollers/navbar_controller.dart';
import 'package:closerrr/src/models/explore/get_influencer_response.dart';
import 'package:closerrr/src/view/popup/explore/congrats_explore.dart';
import 'package:closerrr/src/view/popup/explore/term_conditions_and_privacy_policy.dart';
import 'package:closerrr/src/view/popup/explore/unsuccessful_explore.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/explore_image_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../controller/routing/routing_controller.dart';

class ExploreProfileScreen extends StatefulWidget {
  final Influencer influencer;
  final String influencerId;
  final StatefulNavigationShell? navigationShell;
  final bool isManageMode;

  const ExploreProfileScreen({
    super.key,
    required this.influencer,
    required this.influencerId,
    this.navigationShell,
    this.isManageMode = false,
  });

  @override
  State<ExploreProfileScreen> createState() => _ExploreProfileScreenState();
}

class _ExploreProfileScreenState extends State<ExploreProfileScreen> {
  final ExploreScreenController exploreController = Get.find();
  final NavbarController navbarController = Get.find();
  final ChatController chatController = Get.find();
  PageController? _pageController;
  int _lastSlidesCount = 0;
  final RxInt _activeSlide = 0.obs;
  final RxBool _isAddingFriend = false.obs;

  static const double _bannerHeight = 155.0;
  static const double _avatarDiameter = 110.0;

  PageController _getOrUpdatePageController(int count) {
    if (_pageController == null || _lastSlidesCount != count) {
      _pageController?.dispose();
      _lastSlidesCount = count;
      final initialPage = count > 0 ? (10000 ~/ count) * count : 0;
      _pageController = PageController(
        viewportFraction: 0.72,
        initialPage: initialPage,
      );
    }
    return _pageController!;
  }

  Profile? get profile => widget.influencer.profile;

  String get displayName =>
      (profile?.fullname?.isNotEmpty == true
          ? profile?.fullname
          : profile?.username) ??
      '';

  String get username => profile?.username ?? '';

  int get showcaseUserId => widget.influencer.id;

  @override
  void initState() {
    super.initState();
    exploreController.acceptPpAndTAC.value = false;
    _loadShowcase();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadShowcase() async {
    await exploreController.getInfluencerShowcase(id: showcaseUserId);
  }

  Future<void> _openInfluencerChat() async {
    var chat = chatController.chats.firstWhereOrNull(
      (c) => c.users.any((user) => user.id == widget.influencer.id),
    );
    if (chat == null) {
      await chatController.getChats(page: 1);
      chat = chatController.chats.firstWhereOrNull(
        (c) => c.users.any((user) => user.id == widget.influencer.id),
      );
    }
    if (chat != null && mounted) {
      context.push('/chat/chat_message', extra: {'chat': chat});
      return;
    }
    widget.navigationShell?.goBranch(1);
    navbarController.selectIndex.value = 1;
    Helpers.toast('Open your chat from the Chats tab');
  }

  Future<void> _handlePrimaryAction() async {
    if (widget.influencer.isFriend.value) {
      await _openInfluencerChat();
      return;
    }

    if (!exploreController.acceptPpAndTAC.value) {
      Helpers.toast('Please accept the Terms and Conditions');
      return;
    }

    _isAddingFriend.value = true;
    try {
      final successResult = await exploreController.addFriend(
        influencerUserId: widget.influencer.id,
      );
      if (!successResult) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => UnsuccessfulExplore(
              onTryAgain: () {
                Helpers.toast('Retrying payment...', backgroundColor: success);
                _handlePrimaryAction();
              },
              onCancel: () {
                Helpers.toast('Payment cancelled.', backgroundColor: failed);
              },
            ),
          );
        }
        return;
      }
      widget.influencer.isFriend.value = true;
      await chatController.getChats(page: 1);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const CongratsExplore(),
        ).then((_) => _openInfluencerChat());
      }
    } finally {
      _isAddingFriend.value = false;
    }
  }

  void _openGallery(int index) {
    if (exploreController.showcaseSlides.isEmpty) return;
    RouterController.current.push(
      '/explore/explore-profile/explore-media',
      extra: {
        'influencer': widget.influencer.toJson(),
        'showcase_slides': exploreController.showcaseSlides,
        'initial_index': index,
      },
    );
  }

  void _shareProfile() {
    final name = displayName;
    final userId = widget.influencer.id;
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out $name on Closerrr! https://closerrr.com/closerrr/profile/$userId',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(widthScale),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerAndProfileStack(widthScale),
                    const SizedBox(height: 68),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameBlock(widthScale),
                          if ((profile?.description ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDescription(widthScale),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildShowcaseCarousel(widthScale),
                    const SizedBox(height: 20),
                    Obx(() {
                      final isFriend = widget.influencer.isFriend.value;
                      if (isFriend) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildBenefitsBox(widthScale),
                      );
                    }),
                    Obx(() {
                      if (widget.isManageMode) return const SizedBox.shrink();
                      final isFriend = widget.influencer.isFriend.value;
                      if (isFriend) {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildActionButton(widthScale),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildTermsCheckbox(widthScale),
                          ),
                          const SizedBox(height: 28),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildActionButton(widthScale),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(double widthScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticHelper.trigger(type: HapticFeedbackType.light);
              RouterController.current.pop();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.08),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    backSvgIcon,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Explore Profile',
                  style: TextStyle(
                    fontFamily: 'Hellix',
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: (widthScale * kTextFormFactor) * 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner + Profile Section Stack ────────────────────────────────────────

  Widget _buildBannerAndProfileStack(double widthScale) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner Image
        _buildBannerSection(),
        // Profile Avatar (overlaps bottom edge of banner)
        Positioned(
          left: 16,
          bottom: -(_avatarDiameter / 2),
          child: Obx(() {
            final showcaseProfileData = exploreController.showcaseProfileImage.value;
            final profilePicUrl = profile?.profilePic;

            final String avatarUrl;
            if (showcaseProfileData != null) {
              avatarUrl = ApiStrings.imageUrl + showcaseProfileData.path;
            } else if (profilePicUrl != null &&
                profilePicUrl.toString().isNotEmpty) {
              avatarUrl = ApiStrings.imageUrl + profilePicUrl.toString();
            } else {
              avatarUrl = '';
            }

            return Container(
              width: _avatarDiameter,
              height: _avatarDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: whiteColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _defaultAvatar(),
                        placeholder: (_, __) => _avatarLoading(),
                      )
                    : _defaultAvatar(),
              ),
            );
          }),
        ),
        // Share Button (positioned bottom right of the banner area)
        Positioned(
          right: 16,
          bottom: -20,
          child: GestureDetector(
            onTap: _shareProfile,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.08),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                shareSvgIcon,
                width: 40,
                height: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    return Obx(() {
      final bannerData = exploreController.showcaseBannerImage.value;
      return _buildBannerImage(bannerData);
    });
  }

  Widget _buildBannerImage(dynamic bannerData) {
    if (bannerData != null) {
      return CachedNetworkImage(
        imageUrl: ApiStrings.imageUrl + bannerData.path,
        height: _bannerHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _gradientBanner(),
        placeholder: (_, __) => _gradientBanner(),
      );
    }
    return _gradientBanner();
  }

  Widget _gradientBanner() {
    return Container(
      height: _bannerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, blueBack],
        ),
      ),
    );
  }

  Widget _defaultAvatar() => Container(
        width: _avatarDiameter,
        height: _avatarDiameter,
        color: backScreenColor,
        child: Image.asset(person, fit: BoxFit.cover),
      );

  Widget _avatarLoading() => Container(
        color: backScreenColor,
        child: const Center(
          child: CircularProgressIndicator(color: primaryColor, strokeWidth: 1.5),
        ),
      );

  // ── Name + username + description ────────────────────────────────────────

  Widget _buildNameBlock(double widthScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: TextStyle(
            fontFamily: 'Hellix',
            color: primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: (widthScale * kTextFormFactor) * 24,
          ),
        ),
        if (username.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            '@$username',
            style: TextStyle(
              fontFamily: 'Hellix',
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: (widthScale * kTextFormFactor) * 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(double widthScale) {
    return Text(
      profile!.description!,
      style: TextStyle(
        fontFamily: 'Hellix',
        color: const Color(0xFF2D2D2D),
        fontWeight: FontWeight.w600,
        fontSize: (widthScale * kTextFormFactor) * 14,
        height: 1.55,
      ),
    );
  }

  // ── Showcase carousel ────────────────────────────────────────────────────

  Widget _buildShowcaseCarousel(double widthScale) {
    return Obx(() {
      final slides = exploreController.showcaseSlides;
      if (slides.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: backScreenColor,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              'No showcase photos yet',
              style: TextStyle(
                fontFamily: 'Hellix',
                color: textColor,
                fontSize: (widthScale * kTextFormFactor) * 14,
              ),
            ),
          ),
        );
      }
      final controller = _getOrUpdatePageController(slides.length);
      return SizedBox(
        height: 380,
        child: PageView.builder(
          controller: controller,
          onPageChanged: (index) => _activeSlide.value = index % slides.length,
          itemBuilder: (context, index) {
            final slideIndex = index % slides.length;
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                double scale = 0.88;
                if (controller.hasClients && controller.position.haveDimensions) {
                  final page = controller.page ?? 0.0;
                  final diff = (page - index).abs();
                  scale = (1.0 - (diff * 0.12)).clamp(0.88, 1.0);
                } else {
                  scale = (index % slides.length) == _activeSlide.value ? 1.0 : 0.88;
                }
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () => _openGallery(slideIndex),
                child: ExploreImageView(
                  isActive: true,
                  showcaseData: slides[slideIndex],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── Benefits box ──────────────────────────────────────────────────────────

  Widget _buildBenefitsBox(double widthScale) {
    final name = displayName;
    return SnakeBorderBorder(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _benefitItem(
              widthScale,
              bold: 'Chat Privately With $name:',
              body:
                  ' Connect directly with your beloved artist, and rest assured—your messages stay private, just between you two! 🤫',
            ),
            const SizedBox(height: 14),
            _benefitItem(
              widthScale,
              bold: 'Stay In Sync With $name:',
              body:
                  ' Be the first to know and stay updated with your favorite artists\' schedules, events, and behind-the-scenes magic! 📅',
            ),
            const SizedBox(height: 14),
            _benefitItem(
              widthScale,
              bold: 'Enjoy Exclusive Content From $name:',
              body:
                  ' Get exclusive access to live streams, behind-the-scenes glimpses, and much more! 🌟',
            ),
            const SizedBox(height: 14),
            Text(
              'Add $name as your Friend and Chat Privately and Securely with them anytime!',
              style: TextStyle(
                fontFamily: 'Hellix',
                color: const Color(0xFF2D2D2D),
                fontWeight: FontWeight.w600,
                fontSize: (widthScale * kTextFormFactor) * 13,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitItem(double widthScale,
      {required String bold, required String body}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Hellix',
          color: const Color(0xFF2D2D2D),
          fontWeight: FontWeight.w500,
          fontSize: (widthScale * kTextFormFactor) * 13,
          height: 1.55,
        ),
        children: [
          TextSpan(
            text: bold,
            style: TextStyle(
              fontFamily: 'Hellix',
              fontWeight: FontWeight.w800,
              color: mainTextColor,
              fontSize: (widthScale * kTextFormFactor) * 13,
            ),
          ),
          TextSpan(text: body),
        ],
      ),
    );
  }

  // ── T&C checkbox ──────────────────────────────────────────────────────────

  Widget _buildTermsCheckbox(double widthScale) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: exploreController.acceptPpAndTAC.value,
              onChanged: (v) =>
                  exploreController.acceptPpAndTAC.value = v ?? false,
              activeColor: primaryColor,
              side: const BorderSide(color: primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Hellix',
                  fontSize: (widthScale * kTextFormFactor) * 13,
                  color: const Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'I have read and accept all the '),
                  TextSpan(
                     text: 'Terms and Conditions',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => showDialog(
                            context: context,
                            builder: (_) =>
                                const TermConditionsAndPrivacyPolicy(),
                          ),
                    style: TextStyle(
                      fontFamily: 'Hellix',
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                      fontSize: (widthScale * kTextFormFactor) * 13,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => showDialog(
                            context: context,
                            builder: (_) =>
                                const TermConditionsAndPrivacyPolicy(),
                          ),
                    style: TextStyle(
                      fontFamily: 'Hellix',
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                      fontSize: (widthScale * kTextFormFactor) * 13,
                    ),
                  ),
                  const TextSpan(
                      text: ', and will adhere to them unconditionally.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ADD FRIEND / CHAT NOW button ──────────────────────────────────────────

  Widget _buildActionButton(double widthScale) {
    return Obx(() {
      final isLoading = _isAddingFriend.value;
      final acceptTnC = exploreController.acceptPpAndTAC.value;
      final isFriend = widget.influencer.isFriend.value;

      return PulsingButtonShadow(
        isActive: isFriend ? false : acceptTnC,
        child: ElevatedButton(
          onPressed: isLoading ? null : _handlePrimaryAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFriend
                ? primaryColor
                : (acceptTnC ? primaryColor : const Color(0xFF9672C4)),
            disabledBackgroundColor: isFriend
                ? primaryColor
                : (acceptTnC ? primaryColor : const Color(0xFF9672C4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            minimumSize: const Size(double.infinity, 58),
            padding: const EdgeInsets.symmetric(horizontal: 28),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: whiteColor, strokeWidth: 2),
                )
              : isFriend
                  ? Center(
                      child: Text(
                        'CHAT NOW',
                        style: TextStyle(
                          fontFamily: 'Hellix',
                          color: whiteColor,
                          fontWeight: FontWeight.w800,
                          fontSize: (widthScale * kTextFormFactor) * 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ADD FRIEND',
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: whiteColor,
                            fontWeight: FontWeight.w800,
                            fontSize: (widthScale * kTextFormFactor) * 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '₹349/month',
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: whiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: (widthScale * kTextFormFactor) * 16,
                          ),
                        ),
                      ],
                    ),
        ),
      );
    });
  }
}

class PulsingButtonShadow extends StatefulWidget {
  final Widget child;
  final bool isActive;
  const PulsingButtonShadow({super.key, required this.child, required this.isActive});

  @override
  State<PulsingButtonShadow> createState() => _PulsingButtonShadowState();
}

class _PulsingButtonShadowState extends State<PulsingButtonShadow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingButtonShadow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = widget.isActive ? _animation.value : 0.0;
        final scale = widget.isActive ? (1.0 + (val * 0.03)) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.isActive
                      ? const Color(0xFFB15EFF).withOpacity(0.35 + (val * 0.35))
                      : Colors.transparent,
                  blurRadius: widget.isActive ? (14 + (val * 12)) : 0.0,
                  spreadRadius: widget.isActive ? (val * 2.0) : 0.0,
                  offset: widget.isActive ? Offset(0, 4 + (val * 2)) : Offset.zero,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class SnakeBorderBorder extends StatefulWidget {
  final Widget child;
  const SnakeBorderBorder({super.key, required this.child});

  @override
  State<SnakeBorderBorder> createState() => _SnakeBorderBorderState();
}

class _SnakeBorderBorderState extends State<SnakeBorderBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: SnakeBorderPainter(
            animationValue: _controller.value,
            strokeWidth: 0.8,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class SnakeBorderPainter extends CustomPainter {
  final double animationValue;
  final double strokeWidth;

  SnakeBorderPainter({
    required this.animationValue,
    this.strokeWidth = 0.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidthOffset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      strokeWidthOffset,
      strokeWidthOffset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final totalLength = metric.length;

    // 1. Draw static thin background outline gradient of pink and purple (extremely fine hairline)
    final basePaint = Paint()
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    
    final baseGradient = LinearGradient(
      colors: [
        const Color(0xFF7A02FA).withOpacity(0.18), // subtle purple
        const Color(0xFFF77BAD).withOpacity(0.18), // subtle pink
        const Color(0xFF7A02FA).withOpacity(0.18),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    basePaint.shader = baseGradient.createShader(rect);
    canvas.drawPath(path, basePaint);

    // 2. Draw moving trace segments (two snakes opposite each other)
    final segmentLength = totalLength * 0.18; // elegant tracer length
    Path tracePath = Path();

    // Snake 1
    final start1 = animationValue * totalLength;
    final end1 = start1 + segmentLength;
    if (end1 <= totalLength) {
      tracePath.addPath(metric.extractPath(start1, end1), Offset.zero);
    } else {
      tracePath.addPath(metric.extractPath(start1, totalLength), Offset.zero);
      tracePath.addPath(metric.extractPath(0.0, end1 - totalLength), Offset.zero);
    }

    // Snake 2 (opposite position)
    final start2 = ((animationValue + 0.5) % 1.0) * totalLength;
    final end2 = start2 + segmentLength;
    if (end2 <= totalLength) {
      tracePath.addPath(metric.extractPath(start2, end2), Offset.zero);
    } else {
      tracePath.addPath(metric.extractPath(start2, totalLength), Offset.zero);
      tracePath.addPath(metric.extractPath(0.0, end2 - totalLength), Offset.zero);
    }

    final tracerGradient = LinearGradient(
      colors: [
        const Color(0xFF7A02FA), // prominent purple
        const Color(0xFFF77BAD), // pink
        const Color(0xFF7A02FA),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final glowGradient = LinearGradient(
      colors: [
        const Color(0xFF7A02FA).withOpacity(0.35),
        const Color(0xFFF77BAD).withOpacity(0.35),
        const Color(0xFF7A02FA).withOpacity(0.35),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Outer subtle glow line (extremely thin)
    final glowPaint = Paint()
      ..shader = glowGradient.createShader(rect)
      ..strokeWidth = strokeWidth * 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(tracePath, glowPaint);

    // Inner bright trace line (extremely thin)
    final corePaint = Paint()
      ..shader = tracerGradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(tracePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant SnakeBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
