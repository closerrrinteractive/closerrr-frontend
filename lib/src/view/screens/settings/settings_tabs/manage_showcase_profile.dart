import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/authentication/verify_otp_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/custom_services.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/img_string.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../controller/authentication/auth_controller.dart';
import '../../../../controller/settings_controller/settings_controller.dart';
import '../../../widgets/custom_widgets/custom_button.dart';

class ManageShowcaseProfile extends StatefulWidget {
  const ManageShowcaseProfile({super.key});

  @override
  State<ManageShowcaseProfile> createState() => _ManageShowcaseProfileState();
}

class _ManageShowcaseProfileState extends State<ManageShowcaseProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();
  final UserInformationController userInformationController = Get.find();
  final VerifyOtpController verifyOtpController = Get.find();
  final SettingScreenController settingScreenController =
      Get.find<SettingScreenController>();

  final RxBool isSomethingChanged = false.obs;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> getDetails() async {
    // await authController.logout();
    await userInformationController.getUserData();
  }

  Future<void> _onSave() async {
    CustomLoader.show();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return PopScope(
      child: Scaffold(
        backgroundColor: whiteColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticHelper.trigger(type: HapticFeedbackType.light);
                        GoRouter.of(context).pop();
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
                            'Manage Showcase Profile',
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
                    Obx(
                      () => CustomButton(
                        height: 40,
                        borderRadius: 16,
                        padding: const EdgeInsets.all(10),
                        buttonTitle: 'SAVE',
                        titleStyle:
                            CustomTextStyle.styledTextWidget.titleSmall!.copyWith(
                          color: isSomethingChanged.value
                              ? primaryColor
                              : primaryColor.withOpacity(0.5),
                          fontSize: (widthScale * kTextFormFactor) * 14,
                          letterSpacing: 2,
                        ),
                        onPress: isSomethingChanged.value ? _onSave : () {},
                        backButtonColor: whiteColor,
                        isTextStyle: true,
                        bordercolor: BorderSide(
                          width: 1,
                          color: isSomethingChanged.value
                              ? primaryColor
                              : primaryColor.withOpacity(0.2),
                        ),
                        onlyText: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
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
