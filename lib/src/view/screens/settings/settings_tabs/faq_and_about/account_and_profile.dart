import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/rich_faq_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/utils/img_string.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../../controller/routing/routing_controller.dart';

class AccountAndProfile extends StatefulWidget {
  const AccountAndProfile(
      {super.key, required this.categoryId, required this.title});
  final int categoryId;
  final String title;

  @override
  State<AccountAndProfile> createState() => _AccountAndProfileState();
}

class _AccountAndProfileState extends State<AccountAndProfile> {
  final selectedIndex = (-1).obs;
  final SettingScreenController settingScreenController = Get.find();
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    settingScreenController.getFaq(categoryId: widget.categoryId);
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Obx(() => Container(
          decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blueBack.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSearching.value ? 24 : 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isSearching.value) ...[
                    GestureDetector(
                      onTap: () {
                        HapticHelper.trigger(type: HapticFeedbackType.light);
                        isSearching.value = false;
                        searchController.clear();
                        searchQuery.value = '';
                        settingScreenController.getFaq(categoryId: widget.categoryId);
                        searchFocusNode.unfocus();
                      },
                      child: Image(
                        height: 5.h,
                        width: 5.h,
                        image: const AssetImage(crossIcon),
                      ),
                    ),
                    Expanded(
                      child: CustomTextFormField(
                        keyboardType: TextInputType.text,
                        hintText: 'Search FAQs',
                        focusNode: searchFocusNode,
                        controller: searchController,
                        fillColor: primaryColor.withOpacity(0.1),
                        cursorColor: primaryColor,
                        style: CustomTextStyle.styledTextWidget.displayMedium!.copyWith(
                          color: primaryColor,
                          fontSize: (widthScale * kTextFormFactor) * 12,
                          fontWeight: FontWeight.w800,
                        ),
                        hintStyle: CustomTextStyle.styledTextWidget.displayMedium!.copyWith(
                          color: primaryColor.withOpacity(0.6),
                          fontSize: (widthScale * kTextFormFactor) * 12,
                          fontWeight: FontWeight.w800,
                        ),
                        isBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        borderColor: whiteColor,
                        radius: 20,
                        onChanged: (val) {
                          searchQuery.value = val;
                          settingScreenController.getFaq(
                            categoryId: widget.categoryId,
                            search: val,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                  ] else ...[
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
                            'FAQs',
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
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        isSearching.value = true;
                        settingScreenController.getFaq(
                          categoryId: widget.categoryId,
                          search: '',
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          searchFocusNode.requestFocus();
                        });
                      },
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
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            'assets/svg/search.svg',
                            colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Obx(() => Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              isSearching.value ? 'Search Results' : widget.title,
                              style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                                color: blueBack,
                                fontSize: (widthScale * kTextFormFactor) * 24,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Circe',
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          if (settingScreenController.faqs.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4.h),
                              child: Center(
                                child: Text(
                                  'No FAQs found matching your query.',
                                  style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                                    color: blackColor.withOpacity(0.6),
                                    fontSize: (widthScale * kTextFormFactor) * 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Hellix',
                                  ),
                                ),
                              ),
                            )
                          else
                            ...List.generate(
                              settingScreenController.faqs.length,
                              (index) => Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                                    childrenPadding: const EdgeInsets.symmetric(horizontal: 24),
                                    onExpansionChanged: (value) {
                                      HapticHelper.trigger(type: HapticFeedbackType.light);
                                      if (value) {
                                        selectedIndex.value = index;
                                      } else {
                                        selectedIndex.value = -1;
                                      }
                                    },
                                    trailing: Icon(
                                      selectedIndex.value == index
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 26,
                                      color: selectedIndex.value == index
                                          ? primaryColor
                                          : primaryColor.withOpacity(0.2),
                                    ),
                                    title: RichFaqText(
                                      text: settingScreenController.faqs[index].question,
                                      style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                                        color: primaryColor,
                                        fontSize: (widthScale * kTextFormFactor) * 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Hellix',
                                        letterSpacing: -0.3,
                                      ) ?? const TextStyle(),
                                    ),
                                    backgroundColor: expansionBackgroundColor.withOpacity(0.4),
                                    shape: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(Radius.circular(0)),
                                    ),
                                    children: [
                                      SizedBox(height: 0.8.h),
                                      RichFaqText(
                                        text: settingScreenController.faqs[index].answer,
                                        style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                                          color: blackColor,
                                          fontSize: (widthScale * kTextFormFactor) * 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Hellix',
                                        ) ?? const TextStyle(),
                                      ),
                                      SizedBox(height: 2.h)
                                    ],
                                  ),
                                  Container(
                                    width: 88.w,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Color(0xFFF0F0F8),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Still Stuck? ',
                                style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                                  color: blueBack,
                                  fontSize: (widthScale * kTextFormFactor) * 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Hellix',
                                ),
                              ),
                              GestureDetector(
                                onTap: () => RouterController.current.pushNamed('contact_us'),
                                child: Text(
                                  "We're Just A Mail Away!",
                                  style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                                    color: blueBack,
                                    height: 1,
                                    fontSize: (widthScale * kTextFormFactor) * 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Hellix',
                                    decoration: TextDecoration.underline,
                                    decorationColor: blueBack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
