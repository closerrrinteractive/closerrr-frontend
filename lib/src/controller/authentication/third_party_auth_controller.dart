import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/main.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../routing/routing_controller.dart';

/// 🔹 Third Party Auth Controller
/// [Login with Google {controller.signInWithGoogle}, Login with Apple {controller.signInWithApple}]
class ThirdPartyAuthController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        "1073593113343-l62dbkq2l6pnskhkgh2r21dgorkpp5id.apps.googleusercontent.com",
    scopes: [
      'email',
      'profile',
      'openid',
      'https://www.googleapis.com/auth/userinfo.email'
    ],
    forceCodeForRefreshToken: true,
  );
  final UserInformationController userInformationController = Get.find();
  final TextEditingController deleteAccountController = TextEditingController();
  final obscureText = true.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final user = await googleSignIn.signIn();
      if (user == null) return kLog('Google sign-in canceled');

      final googleAuth = await user.authentication;
      if (googleAuth.idToken == null) throw Exception('Failed to get ID token');

      await sendResponseToBackend(
        googleIdToken: googleAuth.idToken!,
        // signInType: 'google',
        name: user.displayName,
        email: user.email,
        profileUrl: user.photoUrl,
      );
      kLog(user);
    } catch (error) {
      kLog('Error signing in with Google: $error');
    }
  }

  Future signInWithApple() async {
    try {
      SignInWithApple.isAvailable().then((value) async {
        if (value) {
          final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

          print("Heinnn what");
          print(credential.identityToken);

          sendResponseToBackend(
            appleIdToken: credential.identityToken,
            name: credential.givenName,
            email: credential.email,
          );
        }
      });
    } on Exception catch (e) {
      kLog("here is your error $e");
    }
  }

  Future<void> sendResponseToBackend({
    String? googleIdToken,
    String? appleIdToken,
    String? name,
    String? email,
    String? profileUrl,
  }) async {
    try {
      Map<String, dynamic> requestData = {};
      if (appleIdToken != null) {
        requestData = {
          "token": appleIdToken,
          "role": "FAN",
          "sign_in_type": "apple"
        };
      }
      if (name == null && email == null) {
        requestData = {
          "token": appleIdToken,
          "role": "FAN",
          "sign_in_type": "apple"
        };
      }
      if (googleIdToken != null) {
        requestData = {
          "role": "FAN",
          "token": googleIdToken,
          "sign_in_type": "google"
        };
      }
      final response = await httpService.post(
        ApiStrings.socialLogin,
        data: requestData,
      );
      print("social login ");
      print(response.data);
      if (isSuccessStatusCode(response.statusCode!)) {
        await userInformationController.setUserData(response.data['data']);
        await Future.delayed(const Duration(
            milliseconds: 300)); // without this redirects to splash

        if (response.data['is_onboarded'] != true) {
          // Push the TransitionPage onto the stack
          // RouterController.current
          //     .push('/transition', extra: {'imagePath': verifyDetail});
          _playTransition(verifyDetail, mainLogo1);

          // Replace the TransitionPage with the forgot-password page
          RouterController.current.go(
            '/onboard-profile',
          );
        } else {
          // Determine the image based on the sign_in_type in requestData
          String signInType = requestData['sign_in_type'] ?? '';
          String imagePath = signInType == 'google' ? googleStep : appleStep;

          // Push the TransitionPage with the determined imagePath
          _playTransition(imagePath);
          // RouterController.current
          //     .push('/transition', extra: {'imagePath': imagePath});

          // Navigate to onboard-profile
          RouterController.current.go('/explore');
        }
      }
    } catch (e) {
      kLog('SendToBackend Error: $e');
    }
  }

  Future<void> _playTransition(String firstImage, [String? secondImage]) async {
    RouterController.current
        .push('/transition', extra: {'imagePath': firstImage});
    await Future.delayed(const Duration(seconds: 2));
    if (secondImage != null) {
      RouterController.current
          .push('/transition', extra: {'imagePath': secondImage});
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
