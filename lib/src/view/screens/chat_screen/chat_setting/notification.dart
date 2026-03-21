import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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
  final ValueNotifier<bool> isNotificationLoading = ValueNotifier(false);
  final RxBool _isPickingNotification = false.obs;
  final RxBool _isPickingCall = false.obs;
  final RxBool isCallLoading = false.obs;

  RxString selectedNotificationTone = ''.obs;
  RxString selectedCallRingtone = ''.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNotifications(id: widget.influencerId);
      _loadSelectedSounds();
    });
  }

  void getNotifications({int? id}) =>
      settingScreenController.getNotifications(id: id);

  Future<void> _loadSelectedSounds() async {
    final prefs = await SharedPreferences.getInstance();
    selectedNotificationTone.value = prefs.getString('chat_sound') ?? '';
    selectedCallRingtone.value = prefs.getString('call_ringtone') ?? '';
  }

  Future<void> _pickNotificationTone(Map<String, dynamic> data) async {
    if (_isPickingNotification.value) return;
    _isPickingNotification.value = true;
    isNotificationLoading.value = true;

    try {
      final pickAudio = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
      );

      if (pickAudio == null) {
        Helpers.toast('No Audio Selected');
        return;
      }

      final path = pickAudio.files.first.path!;
      selectedNotificationTone.value = path;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chat_sound', path);

      data['notification_tone'] = await d.MultipartFile.fromFile(
        path,
        filename: path.split('/').last,
        contentType: d.DioMediaType(
          'audio',
          path.split('.').last.toLowerCase(),
        ),
      );
    } catch (e) {
      Helpers.toast('Error selecting file: $e');
    } finally {
      isNotificationLoading.value = false;
      _isPickingNotification.value = false;
    }
  }

  Future<void> _pickCallRingtone(Map<String, dynamic> data) async {
    if (_isPickingCall.value) return;
    _isPickingCall.value = true;
    isCallLoading.value = true;

    try {
      final pickAudio = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
      );

      if (pickAudio == null) {
        Helpers.toast('No Audio Selected');
        return;
      }

      final path = pickAudio.files.first.path!;
      selectedCallRingtone.value = path;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('call_ringtone', path);

      data['call_ringtone'] = await d.MultipartFile.fromFile(
        path,
        filename: path.split('/').last,
        contentType: d.DioMediaType(
          'audio',
          path.split('.').last.toLowerCase(),
        ),
      );
    } catch (e) {
      Helpers.toast('Error selecting file: $e');
    } finally {
      isCallLoading.value = false;
      _isPickingCall.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: ChatAppBar(
        isChatSetting: true,
        chatTitle: "Notifications",
      ),
      body: Obx(() {
        final notification = settingScreenController.notifications.value;
        final data = <String, dynamic>{
          "messages_enabled": notification?.messagesEnabled ?? false,
          "calls_enabled": notification?.callsEnabled ?? false,
          "events_enabled": notification?.eventsEnabled ?? false,
          "stories_enabled": notification?.storiesEnabled ?? false,
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SettingTile(
                title: 'Messages',
                value: data['messages_enabled'] ?? false,
                onChanged: (value) async {
                  data['messages_enabled'] = value;
                  await settingScreenController.updateUserNotificationSetting(
                    data: data,
                    id: widget.influencerId,
                  );
                },
              ),
              SizedBox(height: 1.h),
              SettingTile(
                title: 'Event Updates',
                value: data['events_enabled'] ?? false,
                onChanged: (value) async {
                  data['events_enabled'] = value;
                  await settingScreenController.updateUserNotificationSetting(
                    data: data,
                    id: widget.influencerId,
                  );
                },
              ),
              SizedBox(height: 1.h),
              ValueListenableBuilder<bool>(
                valueListenable: isNotificationLoading,
                builder: (context, isLoading, child) {
                  return TabTiles(
                    name: 'Notification Tone',
                    secondary: selectedNotificationTone.value.isNotEmpty
                        ? selectedNotificationTone.value.split('/').last
                        : 'System Default',
                    notification: true,
                    padding: EdgeInsets.zero,
                    isLoading: isLoading,
                    onTap: () => _pickNotificationTone(data),
                  );
                },
              ),
              SizedBox(height: 1.h),
              Obx(() => TabTiles(
                    name: 'Call Ringtone',
                    secondary: selectedCallRingtone.value.isNotEmpty
                        ? selectedCallRingtone.value.split('/').last
                        : 'Default',
                    notification: true,
                    padding: EdgeInsets.zero,
                    isLoading: isCallLoading.value,
                    onTap: () => _pickCallRingtone(data),
                  )),
            ],
          ),
        );
      }),
    );
  }
}
