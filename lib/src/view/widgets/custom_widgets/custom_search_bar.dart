import 'package:closerrr/src/controller/chat/chat_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/text_style.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/img_string.dart';

// ignore: must_be_immutable
class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomSearchBar({
    super.key,
    required this.isEvents,
    required this.title,
    this.searchHint = 'Search Chats',
    required this.gif,
    required this.icon,
    this.onSearch,
    this.searchController,
    this.onClose,
  });

  final bool isEvents;
  final String title;
  final String searchHint;
  final String gif;
  final String icon;
  final Function(dynamic value)? onSearch;
  final Function()? onClose;
  final TextEditingController? searchController;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(20.h);
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final ChatController chatController = Get.find<ChatController>();
  FocusNode searchFocusNode = FocusNode();
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.searchController ?? TextEditingController();
    chatController.isSearching.listen((value) {
      if (mounted) {
        setState(() {});
        if (value) {
          // 🔑 request focus after rebuild so keyboard opens reliably
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FocusScope.of(context).requestFocus(searchFocusNode);
          });
        } else {
          searchFocusNode.unfocus();
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _controller?.dispose(); // only dispose if created here
    }
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return SafeArea(
      child: Obx(
        () => Container(
          color: whiteColor,
          height: chatController.isSearching.value ? 8.h : 18.h,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!chatController.isSearching.value) ...{
                    Row(
                      children: [
                        Image.asset(
                          mainLogo,
                          scale: 7.5,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "Closerrr...",
                          style: CustomTextStyle.styledTextWidget.titleLarge!
                              .copyWith(
                            fontSize: (widthScale * kTextFormFactor) * 26,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  } else ...{
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Image(
                        height: 5.h,
                        width: 5.h,
                        image: const AssetImage(crossIcon),
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Expanded(
                      child: CustomTextFormField(
                        keyboardType: TextInputType.text,
                        hintText: widget.searchHint,
                        focusNode: searchFocusNode,
                        controller: _controller!,
                        fillColor: primaryColor.withOpacity(0.1),
                        cursorColor: primaryColor,
                        style: CustomTextStyle.styledTextWidget.displayMedium!
                            .copyWith(
                          color: primaryColor,
                          fontSize: (widthScale * kTextFormFactor) * 12,
                          fontWeight: FontWeight.w800,
                        ),
                        hintStyle: CustomTextStyle
                            .styledTextWidget.displayMedium!
                            .copyWith(
                          color: primaryColor.withOpacity(0.6),
                          fontSize: (widthScale * kTextFormFactor) * 12,
                          fontWeight: FontWeight.w800,
                        ),
                        isBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        borderColor: whiteColor,
                        radius: 20,
                        onChanged: widget.onSearch,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                  },
                  if (!widget.isEvents) ...{
                    if (!chatController.isSearching.value)
                      GestureDetector(
                        onTap: () => chatController.isSearching.value = true,
                        child: Image(
                          height: 6.h,
                          width: 6.h,
                          image: const AssetImage(searchIcon),
                        ),
                      ),
                  }
                ],
              ),
              SizedBox(height: 1.h),
              if (!chatController.isSearching.value)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.icon.contains('.svg')
                        ? SvgPicture.asset(
                            widget.icon,
                            height: 38,
                          )
                        : Image(
                            image: AssetImage(widget.icon),
                            height: 5.h,
                          ),
                    SizedBox(width: 3.w),
                    Text(
                      widget.title,
                      style:
                          CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                        fontSize: (widthScale * kTextFormFactor) * 40,
                        color: headingColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Circe',
                      ),
                    ),
                    const Spacer(),
                    Image(
                      image: AssetImage(widget.gif),
                      height: 75,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
