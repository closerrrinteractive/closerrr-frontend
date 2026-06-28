import 'dart:io';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/src/models/setting/notification.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';

import '../../../widgets/specific_widgets/custom_setting_tile.dart';

class ChatNotification extends StatefulWidget {
  const ChatNotification({super.key, this.influencerId});
  final int? influencerId;

  @override
  State<ChatNotification> createState() => _ChatNotificationState();
}

class _ChatNotificationState extends State<ChatNotification> {
  final SettingScreenController settingScreenController =
      SettingScreenController();

  static const MethodChannel _ringtoneChannel = MethodChannel('com.closerrr.app/ringtone_picker');
  static const MethodChannel _vibeChannel = MethodChannel('com.closerrr.app/vibrator');

  // Closerrr Live Ringtone Title
  final RxString selectedLiveRingtoneTitle = 'Haven'.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNotifications(id: widget.influencerId);
      _loadSelectedSounds();
    });

    // Reactive worker to keep UI selection in sync with backend settings
    ever(settingScreenController.notifications, (SettingNotification? notif) {
      if (notif != null) {
        final tone = notif.callTone;
        if (tone != null && tone.toString().isNotEmpty) {
          if (tone == 'Default') {
            selectedLiveRingtoneTitle.value = 'Haven'; // Map legacy default to Haven!
          } else {
            selectedLiveRingtoneTitle.value = tone.toString();
          }
        } else {
          selectedLiveRingtoneTitle.value = 'Haven';
        }
      }
    });
  }

  void getNotifications({int? id}) =>
      settingScreenController.getNotifications(id: id);

  Future<void> _loadSelectedSounds() async {
    final prefs = await SharedPreferences.getInstance();
    final liveSoundKey = widget.influencerId == null ? 'call_ringtone' : 'call_ringtone_${widget.influencerId}';
    final savedTitle = prefs.getString('${liveSoundKey}_title');
    if (savedTitle == null || savedTitle == 'Default') {
      selectedLiveRingtoneTitle.value = 'Haven';
    } else {
      selectedLiveRingtoneTitle.value = savedTitle;
    }
  }

  void _showLiveRingtoneDialog(Map<String, dynamic> data) {
    final ringtones = [
      'System Default',
      'Bloom',
      'Brisk',
      'Dusk',
      'Ember',
      'Glow',
      'Haven',
      'Horizon',
      'Joyride',
      'Meadow',
      'Picnic'
    ];
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final tempSelectedLiveRingtoneTitle = selectedLiveRingtoneTitle.value.obs;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: transparentColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: 90.w,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: popColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Live Ringtone',
                style: TextStyle(
                  fontFamily: 'Hellix',
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: (widthScale * kTextFormFactor) * 22,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Choose a custom sound for Closerrr Live streams.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Hellix',
                  color: headingColor,
                  fontWeight: FontWeight.w600,
                  fontSize: (widthScale * kTextFormFactor) * 13,
                ),
              ),
              const SizedBox(height: 20),
              
              // Ringtone List Container
              Obx(() => ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 40.h,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ringtones.map((tone) {
                      final isSelected = tempSelectedLiveRingtoneTitle.value == tone;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.06) : whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primaryColor : dividerColor.withOpacity(0.8),
                            width: isSelected ? 2 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Material(
                          color: transparentColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              tempSelectedLiveRingtoneTitle.value = tone;
                              
                              // Play preview
                              if (Platform.isIOS) {
                                try {
                                  if (tone == 'System Default') {
                                    // Mute/stop any active preview for System Default on iOS
                                    await _ringtoneChannel.invokeMethod('stopPreview');
                                  } else {
                                    await _ringtoneChannel.invokeMethod('playSystemSound', {'soundName': tone.toLowerCase()});
                                  }
                                } catch (e) {
                                  print('Error playing preview: $e');
                                }
                              } else if (Platform.isAndroid) {
                                try {
                                  if (tone == 'System Default') {
                                    await _ringtoneChannel.invokeMethod('playSystemSound');
                                    await _vibeChannel.invokeMethod('vibrate', {'duration': 100});
                                  } else {
                                    await _ringtoneChannel.invokeMethod('playCustomPreview', {'soundName': tone.toLowerCase()});
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? primaryColor : transparentColor,
                                      border: Border.all(
                                        color: isSelected ? primaryColor : underAgeColor.withOpacity(0.3),
                                        width: isSelected ? 0 : 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: whiteColor,
                                            size: 14,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      tone,
                                      style: TextStyle(
                                        fontFamily: 'Hellix',
                                        color: isSelected ? primaryColor : headingColor.withOpacity(0.8),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        fontSize: (widthScale * kTextFormFactor) * 16,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isSelected ? Icons.volume_up_rounded : Icons.music_note_rounded,
                                    color: isSelected ? primaryColor : blueBack.withOpacity(0.2),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: CustomButton(
                      width: double.infinity,
                      buttonTitle: 'CANCEL',
                      backButtonColor: popColor,
                      isTextStyle: true,
                      onlyText: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      onPress: () => Navigator.of(context).pop(),
                      bordercolor: const BorderSide(color: primaryColor),
                      titleStyle: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        fontSize: (widthScale * kTextFormFactor) * 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Set Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF752277).withOpacity(0.25),
                            offset: const Offset(0, 4),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: CustomButton(
                        width: double.infinity,
                        buttonTitle: 'SET',
                        backButtonColor: primaryColor,
                        isTextStyle: true,
                        onlyText: true,
                        onPress: () async {
                          final tone = tempSelectedLiveRingtoneTitle.value;
                          selectedLiveRingtoneTitle.value = tone;
                          final prefs = await SharedPreferences.getInstance();
                          final liveSoundKey = widget.influencerId == null ? 'call_ringtone' : 'call_ringtone_${widget.influencerId}';
                          await prefs.setString(liveSoundKey, tone);
                          await prefs.setString('${liveSoundKey}_title', tone);
                          
                          // Update backend setting
                          final Map<String, dynamic> updateData = Map<String, dynamic>.from(data);
                          updateData['call_tone'] = tone;
                          await settingScreenController.updateUserNotificationSetting(
                            data: updateData,
                            id: widget.influencerId,
                          );
                          
                          Navigator.of(context).pop();
                        },
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        titleStyle: CustomTextStyle.styledTextWidget.titleSmall?.copyWith(
                          color: whiteColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          fontSize: (widthScale * kTextFormFactor) * 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) async {
      try {
        await _ringtoneChannel.invokeMethod('stopPreview');
      } catch (e) {
        print('Error stopping preview: $e');
      }
    });
  }

  Widget _buildRingtoneTile(String label, RxString selectedTitle, bool isEnabled, VoidCallback onTap) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final color = isEnabled ? primaryColor : primaryColor.withOpacity(0.3);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
          ),
        ),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Row(
          children: [
            Text(
              label,
              style: CustomTextStyle.styledTextWidget.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: (widthScale * kTextFormFactor) * 18,
                fontFamily: 'Hellix',
              ),
            ),
            const Spacer(),
            Text(
              selectedTitle.value.isNotEmpty ? selectedTitle.value : 'System Default',
              style: CustomTextStyle.styledTextWidget.labelMedium?.copyWith(
                color: isEnabled ? primaryColor.withOpacity(0.6) : primaryColor.withOpacity(0.2),
                fontWeight: FontWeight.w600,
                fontSize: (widthScale * kTextFormFactor) * 14,
                fontFamily: 'Hellix',
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isEnabled ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.06),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

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
                    onTap: () => RouterController.current.pop(),
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
                          'Notifications',
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
      body: Obx(() {
        final notification = settingScreenController.notifications.value;
        final data = <String, dynamic>{
          "messages_enabled": notification?.messagesEnabled ?? false,
          "calls_enabled": notification?.callsEnabled ?? false,
          "live_stream_enabled": notification?.liveStreamEnabled ?? false,
          "events_enabled": notification?.eventsEnabled ?? false,
          "stories_enabled": notification?.storiesEnabled ?? false,
        };

        final bool isMessagesEnabled = data['messages_enabled'] ?? false;
        final bool isEventsEnabled = data['events_enabled'] ?? false;
        final bool isLiveEnabled = (data['calls_enabled'] ?? false) || (data['live_stream_enabled'] ?? false);
        final bool isStoriesEnabled = data['stories_enabled'] ?? false;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. New Messages Switch
              SettingTile(
                title: 'New Messages',
                value: isMessagesEnabled,
                onChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  final prefix = widget.influencerId == null ? '' : '_${widget.influencerId}';
                  await prefs.setBool('enabled_messages$prefix', value);

                  data['messages_enabled'] = value;
                  await settingScreenController.updateUserNotificationSetting(
                    data: data,
                    id: widget.influencerId,
                  );
                },
              ),
              SizedBox(height: 2.h),

              // 2. Event Updates Switch
              SettingTile(
                title: 'Event Updates',
                value: isEventsEnabled,
                onChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  final prefix = widget.influencerId == null ? '' : '_${widget.influencerId}';
                  await prefs.setBool('enabled_events$prefix', value);

                  data['events_enabled'] = value;
                  await settingScreenController.updateUserNotificationSetting(
                    data: data,
                    id: widget.influencerId,
                  );
                },
              ),
              SizedBox(height: 2.h),

              // 3. New Stories Switch
              SettingTile(
                title: 'New Stories',
                value: isStoriesEnabled,
                onChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  final prefix = widget.influencerId == null ? '' : '_${widget.influencerId}';
                  await prefs.setBool('enabled_stories$prefix', value);

                  data['stories_enabled'] = value;
                  await settingScreenController.updateUserNotificationSetting(
                    data: data,
                    id: widget.influencerId,
                  );
                },
              ),
              SizedBox(height: 2.h),

              // 4. Closerrr Live Switch
              SettingTile(
                title: 'Closerrr Live',
                value: isLiveEnabled,
                onChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  final prefix = widget.influencerId == null ? '' : '_${widget.influencerId}';
                  await prefs.setBool('enabled_live$prefix', value);

                  data['calls_enabled'] = value;
                  data['live_stream_enabled'] = value;
                  await settingScreenController.updateUserNotificationSetting(
                    data: data,
                    id: widget.influencerId,
                  );
                },
              ),
              
              // 5. Closerrr Live Ringtone Selector
              _buildRingtoneTile(
                'Ringtone',
                selectedLiveRingtoneTitle,
                isLiveEnabled,
                () => _showLiveRingtoneDialog(data),
              ),
            ],
          ),
        );
      }),
    );
  }
}
