// import 'package:closerrr/core/utils/constant_string.dart';
// import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
// import 'package:closerrr/src/models/explore/get_influencer_response.dart';
// import 'package:closerrr/src/view/screens/auth_screens/forgot_password_screen.dart';
// import 'package:closerrr/src/view/screens/auth_screens/login_with_mobile.dart';
// import 'package:closerrr/src/view/screens/auth_screens/reset_password_screen.dart';
// import 'package:closerrr/src/view/screens/auth_screens/signin_screen.dart';
// import 'package:closerrr/src/view/screens/auth_screens/signup_screen.dart';
// import 'package:closerrr/src/view/screens/auth_screens/verify_otp_screen.dart';
// import 'package:closerrr/src/view/screens/chat_screen/chat_screen.dart';
// import 'package:closerrr/src/view/screens/chat_screen/chat_setting/chat_setting.dart';
// import 'package:closerrr/src/view/screens/chat_screen/chat_setting/friends_name.dart';
// import 'package:closerrr/src/view/screens/chat_screen/chat_setting/notification.dart';
// import 'package:closerrr/src/view/screens/explore/explore_screen.dart';
// import 'package:closerrr/src/view/screens/explore/profile_explore_screen.dart';
// import 'package:closerrr/src/view/screens/live_stream/call_stream.dart';
// import 'package:closerrr/src/view/screens/live_stream/live_stream.dart';
// import 'package:closerrr/src/view/screens/onboarding_screens.dart/profile_onboard.dart';
// import 'package:closerrr/src/view/screens/onboarding_screens.dart/splash_screen.dart';
// import 'package:closerrr/src/view/screens/settings/settings_tabs/contact_us.dart';
// import 'package:closerrr/src/view/screens/settings/settings_tabs/faq_and_about.dart';
// import 'package:closerrr/src/view/screens/settings/settings_tabs/faq_and_about/account_and_profile.dart';
// import 'package:closerrr/src/view/screens/settings/settings_tabs/friends_tab.dart';
// import 'package:closerrr/src/view/screens/settings/settings_tabs/term_and_policies.dart';
// import 'package:closerrr/src/view/widgets/custom_widgets/transition_page.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';

// import '../../src/models/chat/chat_model.dart';
// import '../../src/view/screens/chat_screen/chat_message.dart';
// import '../../src/view/screens/chat_screen/chat_profile.dart';
// import '../../src/view/screens/chat_screen/chat_setting/nick_name.dart';
// import '../../src/view/screens/chat_screen/media_screen.dart';
// import '../../src/view/screens/chat_screen/media_view.dart';
// import '../../src/view/screens/chat_screen/profile/memories.dart';
// import '../../src/view/screens/chat_screen/story/story_screen.dart';
// import '../../src/view/screens/dashboard/bottom_nav.dart';
// import '../../src/view/screens/events_tab/events_tab.dart';
// import '../../src/view/screens/events_tab/friends_events_screen.dart';
// import '../../src/view/screens/events_tab/upcoming_events_screen.dart';
// import '../../src/view/screens/explore/explore_gallery_view.dart';
// import '../../src/view/screens/settings/settings.dart';
// import '../../src/view/screens/settings/settings_tabs/manage_account.dart';
// import '../../src/view/widgets/image_preview.dart';
// import 'package:stream_video/stream_video.dart' as getStreamIO;

// final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'Root');
// late StatefulNavigationShell navigationShellForOther;
// final UserInformationController userInformationController = Get.find();

// Future<String> getHomeRoute() async {
//   await userInformationController.getUserData();
//   RxMap userData = userInformationController.userData;

//   if (userData.isNotEmpty) {
//     getStreamIO.StreamVideo(Constants.getStreamIOKey,
//         user: getStreamIO.User(
//           info: getStreamIO.UserInfo(
//             name: userData["Profile"]["username"],
//             id: userData["id"].toString(),
//           ),
//         ),
//         userToken: userData["stream_token"]);

//     return '/explore';
//     // return '/chat';
//   } else {
//     return '/signin-screen';
//   }
// }

// GoRouter createRouter(int? roleId) {
//   return GoRouter(
//     initialLocation: '/',
//     navigatorKey: rootNavigatorKey,
//     redirect: (context, state) {
//       final UserInformationController userController = Get.find();
//       final userData = userController.userData.value;

//       if (userData.isEmpty) {
//         return '/signin-screen';
//       } else {
//         // Additional redirect logic if needed
//         return null;
//       }
//     },
//     debugLogDiagnostics: true,
//     routes: [
//       StatefulShellRoute.indexedStack(
//         pageBuilder: (context, state, navigationShell) {
//           navigationShellForOther = navigationShell;
//           return CupertinoPage(
//             child: HomeDashboard(
//               navigationShell: navigationShell,
//             ),
//           );
//         },
//         branches: [
//           // Conditionally include Explore branch based on roleId
//           if (roleId != 3)
//             StatefulShellBranch(routes: [
//               GoRoute(
//                 path: '/explore',
//                 pageBuilder: (context, state) {
//                   return const CupertinoPage(child: ExploreScreen());
//                 },
//                 routes: [
//                   GoRoute(
//                     path: 'explore-profile',
//                     builder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;

//                       return ExploreProfileScreen(
//                         influencer: Influencer.fromJson(
//                           extra['influencer'],
//                         ),
//                         influencerId: extra["influencerId"] ?? '',
//                       );
//                     },
//                     parentNavigatorKey: rootNavigatorKey,
//                     routes: [
//                       GoRoute(
//                         path: 'explore-media',
//                         builder: (context, state) {
//                           final extra = state.extra as Map<String, dynamic>;

//                           return ExploreGalleryView(
//                             influencer:
//                                 Influencer.fromJson(extra['influencer']),
//                             showcaseData: extra['showcase_slides'],
//                           );
//                         },
//                         parentNavigatorKey: rootNavigatorKey,
//                       ),
//                     ],
//                   ),
//                 ],
//               )
//             ]),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/chat',
//                 name: 'chat',
//                 pageBuilder: (context, state) {
//                   return CupertinoPage(
//                     child: ChatScreen(
//                       navigationShell: navigationShellForOther,
//                     ),
//                   );
//                 },
//                 routes: [
//                   GoRoute(
//                     path: '/chat_setting',
//                     name: 'chat_setting',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       return CupertinoPage(
//                         child: ChatSetting(
//                           chatId: extra['chat_id'],
//                           friendId: extra['friend_id'],
//                           chatUser: extra['chat_user'],
//                           profile: extra['profile'],
//                         ),
//                       );
//                     },
//                     routes: [
//                       GoRoute(
//                         path: '/friend_name',
//                         name: 'friend_name',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final extra = state.extra as Map<String, dynamic>;
//                           return CupertinoPage(
//                             child: FriendName(
//                               chatId: extra['chat_id'],
//                               friendId: extra['friend_id'],
//                               chatUser: extra['chat_user'],
//                             ),
//                           );
//                         },
//                       ),
//                       GoRoute(
//                         path: '/nick_name',
//                         name: 'nick_name',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final extra = state.extra as Map<String, dynamic>;
//                           return CupertinoPage(
//                             child: YourNickName(
//                               chatId: extra['chat_id'],
//                               friendId: extra['friend_id'],
//                               chatUser: extra['chat_user'],
//                             ),
//                           );
//                         },
//                       ),
//                       GoRoute(
//                         path: '/chat_notifications',
//                         name: 'chat_notifications',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           return const CupertinoPage(
//                             child: ChatNotification(),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   GoRoute(
//                     path: '/story_screen',
//                     name: 'story_screen',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       return CupertinoPage(
//                         child: StoryScreen(
//                           user: extra['user'],
//                           chatId: extra['chat_id'],
//                         ),
//                       );
//                     },
//                   ),
//                   GoRoute(
//                     path: '/chat_profile',
//                     name: 'chat_profile',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       final profile = UserProfile.fromJson(extra['profile']);
//                       final chatUser = ChatUser.fromJson(extra['chat_user']);
//                       final closerDays = extra['closer_days'];
//                       return CupertinoPage(
//                         child: ChatProfile(
//                           profile: profile,
//                           closerDays: closerDays,
//                           chatId: extra['chat_id'],
//                           chatUser: chatUser,
//                         ),
//                       );
//                     },
//                     routes: [
//                       GoRoute(
//                         path: '/chat_memories',
//                         name: 'chat_memories',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final extra = state.extra as Map<String, dynamic>;
//                           return CupertinoPage(
//                             child: Memories(
//                               chatId: int.parse(extra['chat_id']),
//                             ),
//                           );
//                         },
//                       ),
//                       GoRoute(
//                         path: '/chat_profile/chat_media_screen',
//                         name: 'profile_chat_media_screen',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final extra = state.extra as Map<String, dynamic>;
//                           return CupertinoPage(
//                             child: ChatMediaScreen(
//                               chatId: extra['chat_id'],
//                               chatUser: extra['user'],
//                               profile: extra['profile'],
//                               navigationShell: navigationShellForOther,
//                             ),
//                           );
//                         },
//                         routes: [
//                           GoRoute(
//                             path:
//                                 '/chat_profile/chat_media_screen/media_view_screen',
//                             name: 'profile_media_view_screen',
//                             parentNavigatorKey: rootNavigatorKey,
//                             pageBuilder: (context, state) {
//                               final extra = state.extra as Map<String, dynamic>;
//                               return CupertinoPage(
//                                 child: ChatMediaView(
//                                   mediaType: extra['type'],
//                                   media: extra['media'],
//                                   mediaList: extra['media_list'],
//                                   chatUser: extra['user'],
//                                   loggedInUser: extra['profile'],
//                                 ),
//                               );
//                             },
//                             routes: const [],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   GoRoute(
//                     path: '/chat_message',
//                     name: 'chat_message',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       return CupertinoPage(
//                         child: ChatMessage(
//                           chat: extra['chat'],
//                         ),
//                       );
//                     },
//                     routes: [
//                       GoRoute(
//                         path: 'chat_media_screen',
//                         name: 'chat_media_screen',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final extra = state.extra as Map<String, dynamic>;
//                           return CupertinoPage(
//                             child: ChatMediaScreen(
//                               chatId: extra['chat_id'],
//                               chatUser: extra['user'],
//                               profile: extra['profile'],
//                               navigationShell: navigationShellForOther,
//                             ),
//                           );
//                         },
//                         routes: [
//                           GoRoute(
//                             path: '/media_view_screen',
//                             name: 'media_view_screen',
//                             parentNavigatorKey: rootNavigatorKey,
//                             pageBuilder: (context, state) {
//                               final extra = state.extra as Map<String, dynamic>;
//                               return CupertinoPage(
//                                 child: ChatMediaView(
//                                   mediaType: extra['type'],
//                                   media: extra['media'],
//                                   mediaList: extra['media_list'],
//                                   chatUser: extra['user'],
//                                   loggedInUser: extra['profile'],
//                                 ),
//                               );
//                             },
//                             routes: const [],
//                           ),
//                           GoRoute(
//                             path: '/chat_message_notifications',
//                             name: 'chat_message_notifications',
//                             parentNavigatorKey: rootNavigatorKey,
//                             pageBuilder: (context, state) {
//                               return const CupertinoPage(
//                                 child: ChatNotification(),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/events',
//                 pageBuilder: (context, state) {
//                   return CupertinoPage(
//                     child: EventsTab(
//                       navigationShell: navigationShellForOther,
//                     ),
//                   );
//                 },
//                 routes: [
//                   GoRoute(
//                     path: '/image_preview_screen',
//                     name: 'image_preview_screen',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       return CupertinoPage(
//                         child: ImagePreviewScreen(
//                           eventPoster: extra['eventPoster'],
//                         ),
//                       );
//                     },
//                   ),
//                   GoRoute(
//                     path: '/upcoming_events',
//                     name: 'upcoming_events',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       return const CupertinoPage(
//                         child: UpcomingEventsScreen(),
//                       );
//                     },
//                   ),
//                   GoRoute(
//                     path: '/friends_events',
//                     name: 'friends_events',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       return CupertinoPage(
//                         child: FriendsEventsScreen(
//                           profile: extra['friend'],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               )
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/settings',
//                 pageBuilder: (context, state) {
//                   return const CupertinoPage(
//                     child: SettingScreen(),
//                   );
//                 },
//                 routes: [
//                   GoRoute(
//                     path: '/manage_account',
//                     name: 'manage_account',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       return CupertinoPage(
//                         child: ManageAccount(
//                           user: extra['user'],
//                         ),
//                       );
//                     },
//                   ),
//                   GoRoute(
//                     path: '/friends',
//                     name: 'friends',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       return CupertinoPage(
//                         child: FriendTab(
//                           navigationShell: navigationShellForOther,
//                         ),
//                       );
//                     },
//                   ),
//                   GoRoute(
//                     path: '/notification_settings',
//                     name: 'notification_settings',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       return const CupertinoPage(
//                         child: ChatNotification(),
//                       );
//                     },
//                   ),
//                   GoRoute(
//                     path: '/faqs_and_about',
//                     name: 'faqs_and_about',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       return const CupertinoPage(
//                         child: FAQAndAbout(),
//                       );
//                     },
//                     routes: [
//                       GoRoute(
//                         path: '/faq_account_profile',
//                         name: 'faq_account_profile',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final extra = state.extra as Map<String, dynamic>;
//                           return CupertinoPage(
//                             child: AccountAndProfile(
//                               categoryId: extra['category_id'],
//                               title: extra['title'],
//                             ),
//                           );
//                         },
//                         routes: [
//                           GoRoute(
//                             path: '/faq_contact_us',
//                             name: 'faq_contact_us',
//                             parentNavigatorKey: rootNavigatorKey,
//                             pageBuilder: (context, state) {
//                               return const CupertinoPage(
//                                 child: ContactUs(),
//                               );
//                             },
//                             routes: [
//                               GoRoute(
//                                 path: '/faq_contact_us_page',
//                                 name: 'faq_contact_us_page',
//                                 parentNavigatorKey: rootNavigatorKey,
//                                 pageBuilder: (context, state) {
//                                   return const CupertinoPage(
//                                     child: FAQAndAbout(),
//                                   );
//                                 },
//                                 routes: [
//                                   GoRoute(
//                                     path: '/faq_contact_us_profile',
//                                     name: 'faq_contact_us_profile',
//                                     parentNavigatorKey: rootNavigatorKey,
//                                     pageBuilder: (context, state) {
//                                       final extra =
//                                           state.extra as Map<String, dynamic>;
//                                       return CupertinoPage(
//                                         child: AccountAndProfile(
//                                           categoryId: extra['category_id'],
//                                           title: extra['title'],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   GoRoute(
//                     path: '/terms_and_policies',
//                     name: 'terms_and_policies',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       final extra = state.extra as Map<String, dynamic>;
//                       return CupertinoPage(
//                         child: TermAndPolicies(
//                           title: extra['title'],
//                           path: extra['path'],
//                         ),
//                       );
//                     },
//                   ),
//                   GoRoute(
//                     path: '/contact_us',
//                     name: 'contact_us',
//                     parentNavigatorKey: rootNavigatorKey,
//                     pageBuilder: (context, state) {
//                       return const CupertinoPage(
//                         child: ContactUs(),
//                       );
//                     },
//                     routes: [
//                       GoRoute(
//                         path: '/contact_us_faqs_and_about',
//                         name: 'contact_us_faqs_and_about',
//                         parentNavigatorKey: rootNavigatorKey,
//                         pageBuilder: (context, state) {
//                           return const CupertinoPage(
//                             child: FAQAndAbout(),
//                           );
//                         },
//                         routes: [
//                           GoRoute(
//                             path: '/contact_us_faq_account_profile',
//                             name: 'contact_us_faq_account_profile',
//                             parentNavigatorKey: rootNavigatorKey,
//                             pageBuilder: (context, state) {
//                               final extra = state.extra as Map<String, dynamic>;
//                               return CupertinoPage(
//                                 child: AccountAndProfile(
//                                   categoryId: extra['category_id'],
//                                   title: extra['title'],
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//       GoRoute(
//         path: '/',
//         builder: (context, state) => FutureBuilder<String>(
//           future: getHomeRoute(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return SplashScreen();
//             } else if (snapshot.hasData) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 Future.delayed(const Duration(seconds: 3), () {
//                   // ignore: use_build_context_synchronously
//                   context.go(snapshot.data!);
//                 });
//               });
//               return SplashScreen();
//             } else {
//               return const SigninScreen();
//             }
//           },
//         ),
//       ),
//       // GoRoute(
//       //   path: '/on-boarding',
//       //   builder: (context, state) => const OnboardingScreen(),
//       // ),
//       GoRoute(
//         path: '/signup-screen',
//         builder: (context, state) => const SingupScreen(),
//       ),
//       GoRoute(
//         path: '/signin-screen',
//         builder: (context, state) => const SigninScreen(),
//       ),
//       GoRoute(
//         path: '/verify-otp/:type/:event',
//         builder: (context, state) {
//           final String event = state.pathParameters['event'] ?? "signin";
//           final String type = state.pathParameters['type'] ?? "email";
//           return VerifyOtpScreen(
//             verifyEvent: event,
//             verifyType: type,
//           );
//         },
//       ),
//       GoRoute(
//         path: '/mobile-login',
//         builder: (context, state) => const MobileLoginScreen(),
//       ),
//       GoRoute(
//         path: '/transition',
//         builder: (context, state) {
//           final String imagePath =
//               (state.extra as Map<String, String>)['imagePath'] ?? '';
//           return TransitionPage(imagePath: imagePath);
//         },
//         // builder: (context, state) => TransitionPage(),
//       ),
//       GoRoute(
//         path: '/forgot-password',
//         builder: (context, state) => const ForgotPasswordScreen(),
//       ),
//       GoRoute(
//         path: '/reset-password',
//         builder: (context, state) => const ResetPasswordScreen(),
//       ),
//       GoRoute(
//         path: '/onboard-profile',
//         builder: (context, state) => ProfileOnboardPage(),
//       ),
//       //  Home Screen
//       GoRoute(
//         path: '/home-screen',
//         builder: (context, state) => ChatScreen(
//           navigationShell: navigationShellForOther,
//         ),
//       ),
//       // live stream
//       GoRoute(
//         path: '/live_stream',
//         name: 'live_stream',
//         builder: (context, state) {
//           return LiveStream(state: state);
//         },
//       ),
//       // stream call
//       GoRoute(
//         path: '/stream_call',
//         name: 'stream_call',
//         builder: (context, state) {
//           return StreamCall(state: state);
//         },
//       )
//     ],
//   );
// }
