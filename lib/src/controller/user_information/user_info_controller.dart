import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInformationController extends GetxController {
  RxMap userData = {}.obs;
  RxMap appleUserData = {}.obs;
  RxMap twoFactorAuthData = {}.obs;
  RxString chatId = ''.obs;
  String userDataKey = 'userData';
  String twoFactorAuth = '2FaAuth';
  RxString ipAddress = ''.obs;

  RxBool isInfluencer = false.obs;

  Future<void> saveChatId(int usChatId) async {
    try {
      // Save Google Sign-In data in shared preferences
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('chatId', usChatId.toString());
    } catch (error) {
      // Handle errors
      kLog('Error during sign-in: $error');
    }
  }

  Future<void> getChatId() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    String? userChatID = sharedPreferences.getString('chatId');
    chatId.value = userChatID ?? '';
  }

  Future<void> removeChatId() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('chatId');
  }

  Future<void> signIn(userData) async {
    try {
      // Save Google Sign-In data in shared preferences
      setUserData(userData);
    } catch (error) {
      // Handle errors
      kLog('Error during sign-in: $error');
    }
  }

  Future<void> setUserData(userData) async {
    setDataInShared(userDataKey, userData);
    getUserData();
  }

  Future<void> deleteUserData() async {
    deleteDataFromShared(userDataKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await getDataFromShared(userDataKey);
    // log(data.toString());
    if (data != null) {
      userData.value = data;
      getRole(data);
    }
    return data;
  }

  Future<void> getRole(data) async {
    if (data['role_id'] == 3) {
      isInfluencer.value = true;
    } else {
      isInfluencer.value = false;
    }
  }

  Future<void> twoFaAuth(userData) async {
    try {
      // Save Google Sign-In data in shared preferences
      setTwoFaAuth(userData);
    } catch (error) {
      // Handle errors
      kLog('Error during sign-in: $error');
    }
  }

  Future<void> setTwoFaAuth(userData) async {
    setDataInShared(twoFactorAuth, userData);
    getTwoFaAuth();
  }

  Future<void> getTwoFaAuth() async {
    final data = await getDataFromShared(twoFactorAuth);

    if (data != null) {
      twoFactorAuthData.value = data;
    }
  }
}
