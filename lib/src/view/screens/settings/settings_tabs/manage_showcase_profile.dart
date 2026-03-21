import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/authentication/verify_otp_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/custom_services.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/img_string.dart';
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
        appBar: _buildAppBar(widthScale),
        body: SingleChildScrollView(
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
    );
  }

  AppBar _buildAppBar(double widthScale) {
    return AppBar(
      leading: Container(),
      leadingWidth: 0,
      toolbarHeight: 9.h,
      surfaceTintColor: transparentColor,
      elevation: 12,
      backgroundColor: whiteColor,
      shadowColor: blueBack.withOpacity(0.1),
      title: Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Row(
          children: [
            InkWell(
              onTap: () => GoRouter.of(context).pop(),
              overlayColor: const WidgetStatePropertyAll(transparentColor),
              child: Image(
                image: const AssetImage(
                  backIcon,
                ),
                height: 5.5.h,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              'Manage Showcase Profile',
              style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                color: primaryColor,
                fontSize: (widthScale * kTextFormFactor) * 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Circe',
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
    );
  }
}
