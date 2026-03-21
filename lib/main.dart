import 'package:closerrr/core/services/dependency_injection.dart';
import 'package:closerrr/core/services/http_service.dart';
import 'package:closerrr/core/services/shared_preference_service.dart';
import 'package:closerrr/firebase_options.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:sizer/sizer.dart';

import 'src/controller/routing/routing_controller.dart';

final HttpService httpService = HttpService();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late final UserInformationController userInformationController;

// Add to main.dart (outside any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);

  // const channel = MethodChannel('call_channel');
  // void dismissFlutterCallScreen() {
  //   try {
  //     RouterController.current.pushNamed('stream_call', extra: {});
  //   } catch (e) {
  //     kLog("Error in Router Controller main.dart:53 : $e");
  //   }
  // }
  // channel.setMethodCallHandler((callMetaData) async {
  //   switch (callMetaData.method) {
  //     case 'onCallAnswered':
  //       // Handle the answer in Flutter
  //       final data = callMetaData.arguments as Map<dynamic, dynamic>;
  //       final call = await LiveStreamService()
  //           .startLivestream(id: data['callerId'], join: true);

  //       RouterController.current.pushNamed('live_stream', extra: {
  //         'call': call,
  //         'userData': {
  //           'id': data['callerId'],
  //           'name': data['callerName'],
  //           'Profile': {"username": "ssjsjs", "profile_pic": ""}
  //         }
  //       });

  //       break;
  //     case 'onCallNotificationClicked':
  //       // Handle the answer in Flutter

  //       break;
  //     case 'onCallDeclined':
  //       // Handle the decline in Flutter
  //       dismissFlutterCallScreen();
  //       break;
  //   }
  // });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DependencyInjection.inject();
  userInformationController = Get.find();
  await userInformationController.getUserData();
  await setInitialData();

  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return Obx(() {
          final userController = Get.find<UserInformationController>();
          final userData = userController.userData;
          final roleId = userData['role_id'];

          final router = Get.find<RouterController>();
          router.initializeRouter(roleId);

          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaterialApp.router(
              key: navigatorKey,
              localizationsDelegates: const [
                MonthYearPickerLocalizations.delegate
              ],
              supportedLocales: const [
                Locale('en'),
              ],
              locale: const Locale('en'),
              debugShowCheckedModeBanner: false,
              routerConfig: router.router,
            ),
          );
        });
      },
    ),
  );
}

// UserInfo Controller UserData
// {
//   "id": 26,
//   "email": "Influencer_test@gmail.com",
//   "mobile": "8653247852",
//   "password": "$2b$10$kw2oapOcCtvNzbTORjIUD.yeSFs5szB6MPNEXUsgYi0OYL9dKcilG",
//   "user_id": null,
//   "is_email_verified": true,
//   "is_mobile_verified": true,
//   "role_id": 3,
//   "fcm_token": "fdUn-d74TXCA3Ow40LhHhn:APA91bEao4-dBXOmlmzYULIbYNvts8LnWrvZzze5UGbWWnqRQvdm_gd2KM2heEwBvSuqVeiJ38dHKN3RjN0Ub4gFxjo1vr28L9FMRLDdyOoBYQ19cA3_b5k",
//   "stream_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoic3Rhbm55MSIsInVzZXJfaWQiOiIyNiIsImlhdCI6MTczODkwNzIyMX0.DWC-UCNZOk0rpOvGa_6oOLzka-zLSkCDjYlnvv8zm3A",
//   "sign_in_type": null,
//   "is_onboarded": true,
//   "deleted_at": null,
//   "createdAt": "2025-01-14 02:00:08",
//   "updatedAt": "2025-09-29 01:02:46",
//   "deletedAt": null,
//   "Profile": {
//     "id": 17,
//     "username": "Olivia",
//     "profile_pic": "profile_pics/1757856308337-1000118686.jpg",
//     "bio": "Hey there! This is my Closerrr account. Add me as your friend and let's connect! Looking forward to sharing awesome moments together",
//     "gender": "Female",
//     "address": "bhopal",
//     "birthday": "2001-08-15",
//     "user_id": 26,
//     "createdAt": "2025-02-07 11:17:00",
//     "updatedAt": "2025-09-21 09:02:26"
//   },
//   "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjYsImVtYWlsIjoiSW5mbHVlbmNlcl90ZXN0QGdtYWlsLmNvbSIsIm1vYmlsZSI6Ijg2NTMyNDc4NTIiLCJ1c2VyX2lkIjpudWxsLCJzaWduX2luX3R5cGUiOm51bGwsInJvbGVfaWQiOjMsImlhdCI6MTc1OTA4ODA1MX0.Bk1mQwnl_NCyd9bysVwJ9I4rD0LIgepmwDYxjFg9Jow",
//   "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjYsImVtYWlsIjoiSW5mbHVlbmNlcl90ZXN0QGdtYWlsLmNvbSIsIm1vYmlsZSI6Ijg2NTMyNDc4NTIiLCJ1c2VyX2lkIjpudWxsLCJzaWduX2luX3R5cGUiOm51bGwsInJvbGVfaWQiOjMsImlhdCI6MTc1OTA4ODA1MX0.wm3kOc4-AG6tBI_AMFiVYtdq4X5dg5sUmFIAu1K4vCw"
// }
