import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/settings_controller/preferences_controller.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';
import 'package:closerrr/core/config/haptic_helper.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final PreferencesController prefController = Get.find<PreferencesController>();

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
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
                          'Preferences',
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
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreferenceTile(
                title: 'App Lock',
                subtitle: 'Secure Closerrr using biometrics (Face ID / Touch ID) or your device passcode.',
                value: prefController.isAppLockEnabled.value,
                onChanged: (val) async {
                  final success = await prefController.toggleAppLock(val);
                  if (!success) {
                    setState(() {});
                  }
                },
              ),
              _buildPreferenceTile(
                title: 'Picture in Picture',
                subtitle: 'Continue watching Closerrr Live streams in a miniature player when swiping to the home screen.',
                value: prefController.isPipEnabled.value,
                onChanged: (val) {
                  prefController.togglePip(val);
                },
              ),
              _buildPreferenceTile(
                title: 'Haptic Feedback',
                subtitle: 'Trigger subtle vibrations on taps, long-presses, and keyboard text messaging input.',
                value: prefController.isHapticEnabled.value,
                onChanged: (val) {
                  prefController.toggleHaptic(val);
                },
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: dividerColor,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyle.styledTextWidget.bodySmall!.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Hellix',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    fontFamily: 'Hellix',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: (val) {
              HapticHelper.trigger(type: HapticFeedbackType.medium);
              onChanged(val);
            },
            activeColor: whiteColor,
            activeTrackColor: primaryColor,
            inactiveThumbColor: whiteColor,
            inactiveTrackColor: primaryColor.withOpacity(0.15),
            trackOutlineWidth: const WidgetStatePropertyAll(0),
          ),
        ],
      ),
    );
  }
}
