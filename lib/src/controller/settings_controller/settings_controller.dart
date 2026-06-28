import 'package:closerrr/src/models/setting/get_transaction_history.dart';
import 'package:closerrr/src/models/setting/my_friend_response.dart';
import 'package:closerrr/src/models/setting/notification.dart';
import 'package:closerrr/src/models/setting/payout_upcomming.dart';
import 'package:closerrr/src/models/setting/subscription_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/custom_services.dart';
import '../../../services/setting_services.dart';
import '../../models/setting/faq_categories.dart';
import '../../models/setting/faqs_model.dart';
import '../../models/setting/get_beneficiary_details.dart';
import '../user_information/user_info_controller.dart';

class SettingScreenController extends GetxController {
  final RxBool isSearchBarVisible = true.obs;
  late SettingServices settingServices = SettingServices();
  UserInformationController uiController = Get.find();
  RxList<Friend> friends = <Friend>[].obs;

  final TextEditingController verificationController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxString otp = ''.obs;
  final UserInformationController userInformationController = Get.find();
  var isFormFilled = false.obs;

  /// FAQs
  RxList<FAQCategory> faqCategories = <FAQCategory>[].obs;
  RxList<FAQData> faqs = <FAQData>[].obs;

  // Analytics
  RxList<AnalyticsData> analytics = <AnalyticsData>[].obs;

  // Payout
  Rx<PayoutUpcomming?> payoutUpcomming = Rx<PayoutUpcomming?>(null);
  Rx<BeneficiaryDetail?> beneficiaryDetail = Rx<BeneficiaryDetail?>(null);

  final isTransactionLoading = false.obs;
  Rx<TranscationHistory?> transcations = Rx<TranscationHistory?>(null);

  // Notification
  Rx<SettingNotification?> notifications = Rx<SettingNotification?>(null);

  Future<void> updateProfileData({
    required Map<String, dynamic> data,
    required bool isInfluencer,
  }) async {
    final response = await settingServices.updateUserInfo(
        data: data, isInfluencer: isInfluencer);
    response.fold(
      (l) => kLog(l),
      (r) async {
        final user = uiController.userData.value;
        user['Profile'] = r['data'];
        uiController.setUserData(user);
        CustomSnackbar.show(
          title: 'Success',
          message: r['message'] ?? '',
          isError: false,
        );
      },
    );
    CustomLoader.hide();
  }


  /// [GET] [Notifications]
  /// Fetch the Notifications from the server.
  Future<void> getNotifications({
    int? id,
  }) async {
    final myId = uiController.userData.value['id'];
    final influencerId = id ?? myId;
    final response = await settingServices.getNotifications(
      id: influencerId.toString(),
    );
    response.fold(
      (l) => kLog(l),
      (r) async {
        notifications.value = r.data;
        final prefs = await SharedPreferences.getInstance();
        final prefix = (id == null || id == myId) ? '' : '_$id';
        await prefs.setBool('enabled_messages$prefix', r.data.messagesEnabled);
        await prefs.setBool('enabled_events$prefix', r.data.eventsEnabled);
        await prefs.setBool('enabled_live$prefix', r.data.callsEnabled || r.data.liveStreamEnabled);
        await prefs.setBool('enabled_stories$prefix', r.data.storiesEnabled);

        // Sync call tone
        final liveSoundKey = (id == null || id == myId) ? 'call_ringtone' : 'call_ringtone_$id';
        final rawTone = r.data.callTone;
        String resolvedTone = 'Haven';
        if (rawTone != null && rawTone.isNotEmpty) {
          if (rawTone == 'Default') {
            resolvedTone = 'Haven';
          } else {
            resolvedTone = rawTone;
          }
        }
        await prefs.setString(liveSoundKey, resolvedTone);
        await prefs.setString('${liveSoundKey}_title', resolvedTone);
      },
    );
  }

  Future<void> updateUserNotificationSetting({
    required Map<String, dynamic> data,
    int? id,
  }) async {
    data['influencer_id'] =
        id ?? uiController.userData.value['id']?.toString() ?? '';

    final response = await settingServices.updateUserNotificationSetting(
      data: data,
    );
    response.fold(
      (l) => kLog(l),
      (r) async {
        getNotifications(id: int.parse(data['influencer_id'].toString()));
      },
    );
  }

  /// [Update] [Update Profile Details]
  Future<bool> sendOtp({
    required String type,
    required String value,
  }) async {
    final response = await settingServices.sendOtp(
      type: type,
      value: value,
    );
    response.fold(
      (l) {
        kLog("Error in Sending Otp $l");
        return false;
      },
      (r) {
        return true;
      },
    );
    CustomLoader.hide();
    return response.isRight();
  }

  Future<bool> verifyOtp({
    required String type,
  }) async {
    final response = await settingServices.verifyOtp(
      type: type,
      value:
          type == 'mobile' ? mobileNumberController.text : emailController.text,
      otp: verificationController.text,
    );
    response.fold(
      (l) {
        kLog("Error in Verifying Otp $l");
        otp.value = '';
        return false;
      },
      (r) {
        otp.value = '';
        return true;
      },
    );
    CustomLoader.hide();
    return response.isRight();
  }

  /// [GET] [Fatch Friends]
  /// Fetch the user's friends from the server.
  Future<void> getFriends() async {
    final response = await settingServices.getFriends();
    response.fold(
      (l) => kLog(l),
      (r) async {
        friends.addAll(r.data.rows);
      },
    );
    CustomLoader.hide();
  }

  Future<void> removeFriend({required int id}) async {
    final response = await settingServices.removeFriend(id: id);
    response.fold(
      (l) => kLog(l),
      (r) async {
        friends.removeWhere((element) => element.id == id);
      },
    );
    CustomLoader.hide();
  }

  Future<void> deleteAccount({required int id}) async {
    final response = await settingServices.deleteAccount(id: id);
    response.fold(
      (l) => kLog(l),
      (r) async {
        friends.removeWhere((element) => element.id == id);
      },
    );
    CustomLoader.hide();
  }

  /// [GET] [FAQs]
  Future<void> getFaqCategories({String? audience}) async {
    final response = await settingServices.getFaqCategories(audience: audience);
    response.fold(
      (l) => kLog(l),
      (r) async {
        faqCategories.assignAll(r.data.rows);
        CustomLoader.hide();
      },
    );
  }

  Future<void> getFaq({int? categoryId, String? search, String? audience}) async {
    final response = await settingServices.getFaq(
        categoryId: categoryId, search: search, audience: audience);
    response.fold(
      (l) => kLog(l),
      (r) async {
        faqs.assignAll(r.data.rows);
        CustomLoader.hide();
      },
    );
  }

  /// [GET] [Analytics]
  Future<void> subscriptionAnalytics() async {
    final response = await settingServices.subscriptionAnalytics();
    response.fold(
      (l) => kLog(l),
      (r) {
        analytics.value = r.data;
        CustomLoader.hide();
      },
    );
  }

  /// [GET] [Payout Upcomming Details]
  Future<void> getPayoutUpcommingDetails() async {
    try {
      final response = await settingServices.getPayoutUpcommingDetails();
      response.fold(
        (l) => kLog(l),
        (r) {
          payoutUpcomming.value = r;
          CustomLoader.hide();
        },
      );
    } catch (e) {
      // catch error while getting payout upcomming details
      kLog(e.toString());
    }
  }

  /// [GET] [Beneficiary Detail]
  Future<void> getBeneficiaryDetail() async {
    try {
      final response = await settingServices.getBeneficiaryDetail();
      response.fold(
        (l) => kLog(l),
        (r) {
          beneficiaryDetail.value = r;
          CustomLoader.hide();
        },
      );
    } catch (e) {
      // catch error while getting beneficiary detail
      kLog(e.toString());
    }
  }

  Future<bool> addBeneficiaryAccount({
    required Map<String, dynamic> data,
  }) async {
    try {
      CustomLoader.show();
      final response = await settingServices.addBeneficiaryAccount(data: data);
      bool isSuccess = false;
      response.fold(
        (failure) {
          CustomLoader.hide();
          isSuccess = false;
        },
        (result) {
          CustomLoader.hide();
          isSuccess = true;
        },
      );

      return isSuccess;
    } catch (e, stack) {
      CustomLoader.hide();
      kLog("Error: $e\nStacktrace: $stack");
      return false;
    }
  }

  Future<void> getTranscationHistory({
    required int limit,
    required String startDate,
    required String endDate,
    required int page,
  }) async {
    isTransactionLoading.value = true;
    final response = await settingServices.getTranscationHistory(data: {
      'limit': limit,
      if (startDate.isNotEmpty) 'start_date': startDate,
      if (endDate.isNotEmpty) 'end_date': endDate,
      'page': page,
    });
    response.fold(
      (l) {
        CustomLoader.hide();
        isTransactionLoading.value = false;
        return kLog(l);
      },
      (r) {
        transcations.value = r;
        CustomLoader.hide();
        isTransactionLoading.value = false;
      },
    );
  }
}
