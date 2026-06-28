import 'package:app_links/app_links.dart';
import 'package:closerrr/core/services/shared_preference_service.dart';
import 'package:closerrr/src/services/app_lock_service.dart';
import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/utils/constant_string.dart';
import 'package:closerrr/src/controller/custom_controllers/app_links_controller.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/explore/get_influencer_response.dart';
import 'package:closerrr/src/view/screens/auth_screens/forgot_password_screen.dart';
import 'package:closerrr/src/view/screens/auth_screens/login_with_mobile.dart';
import 'package:closerrr/src/view/screens/auth_screens/reset_password_screen.dart';
import 'package:closerrr/src/view/screens/auth_screens/signin_screen.dart';
import 'package:closerrr/src/view/screens/auth_screens/signup_screen.dart';
import 'package:closerrr/src/view/screens/auth_screens/verify_otp_screen.dart';
import 'package:closerrr/src/view/screens/chat_screen/chat_screen.dart';
import 'package:closerrr/src/view/screens/chat_screen/chat_setting/chat_setting.dart';
import 'package:closerrr/src/view/screens/chat_screen/chat_setting/friends_name.dart';
import 'package:closerrr/src/view/screens/chat_screen/chat_setting/notification.dart';
import 'package:closerrr/src/view/screens/events_tab/all_friend_events_screen.dart';
import 'package:closerrr/src/view/screens/events_tab/create_event_screen.dart';
import 'package:closerrr/src/view/screens/explore/explore_screen.dart';
import 'package:closerrr/src/view/screens/explore/profile_explore_screen.dart';
import 'package:closerrr/src/view/screens/live_stream/call_stream.dart';
import 'package:closerrr/src/view/screens/live_stream/live_stream.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/onboarding_screen.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/profile_onboard.dart';
import 'package:closerrr/src/view/screens/onboarding_screens.dart/splash_screen.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/contact_us.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/dashbaord_and_analytics.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/about.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/faq_and_about.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/faq_and_about/account_and_profile.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/friends_tab.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/my_payouts.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/preferences.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/my_payouts/add_bank_account.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/my_payouts/payout_informations.dart';
import 'package:closerrr/src/view/screens/settings/settings_tabs/term_and_policies.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/transition_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_video/stream_video.dart' as getStreamIO;

import '../../models/chat/chat_model.dart';
import '../../view/screens/chat_screen/all_media_view.dart';
import '../../view/screens/chat_screen/chat_message.dart';
import '../../view/screens/chat_screen/chat_profile.dart';
import '../../view/screens/chat_screen/chat_setting/nick_name.dart';
import '../../view/screens/chat_screen/media_screen.dart';
import '../../view/screens/chat_screen/profile/memories.dart';
import '../../view/screens/chat_screen/story/story_screen.dart';
import '../../view/screens/dashboard/bottom_nav.dart';
import '../../view/screens/events_tab/events_tab.dart';
import '../../view/screens/events_tab/friends_events_screen.dart';
import '../../view/screens/events_tab/upcoming_events_screen.dart';
import '../../view/screens/explore/explore_gallery_view.dart';
import '../../view/screens/settings/settings.dart';
import '../../view/screens/settings/settings_tabs/creator_faq.dart';
import '../../view/screens/settings/settings_tabs/manage_account.dart';
import '../../view/widgets/image_preview.dart';

// tuple to pass data with route
class RouteWithExtra {
  final String route;
  final dynamic extra;

  RouteWithExtra(this.route, this.extra);
}

class RouterController extends GetxController {
  GoRouter? _router;
  int? _currentRoleId;
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'Root');
  late StatefulNavigationShell navigationShellForOther;
  final UserInformationController userInformationController = Get.find();
  GoRouter get router => _router!;
  static GoRouter get current => Get.find<RouterController>()._router!;
  Uri? appLinkUri;

  Future<void> processDeepLink(Uri? uri) async {
    if (uri == null) return;

    final pathSegments = uri.pathSegments;
    if (pathSegments.length >= 3 &&
        pathSegments[0] == 'closerrr' &&
        pathSegments[1] == 'profile') {
      final influencerId = pathSegments[2];
      final deepLinkController = Get.find<AppLinkController>();
      final exploreController = Get.find<ExploreScreenController>();

      // Check user authentication
      await userInformationController.getUserData();
      final userData = userInformationController.userData;

      if (userData.isEmpty) {
        // Store for later processing after auth
        deepLinkController
            .setPendingRoute('explore-profile', {'influencerId': influencerId});
        router.go('/signin-screen');
        return;
      }

      // User authenticated - process immediately
      exploreController.currentPage.value = 1;
      final influencer = await exploreController.getInfluencers(
        influencerId: influencerId,
      );

      deepLinkController.clearPendingRoute();
      router.go(
        '/explore/explore-profile',
        extra: {
          'influencerId': influencerId,
          'influencer': influencer.toJson(),
          'navigationShell': navigationShellForOther,
        },
      );
    }
  }

  void handleAppLinks() {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri == null) return;
      appLinkUri = uri;
      print("appLinkUri");
      processDeepLink(uri);
    });
  }

  void handleInitialAppLink() async {
    final appLinks = AppLinks();
    try {
      final initialUri = await appLinks.getInitialLink();
      appLinkUri = initialUri;
      print("initialUri");
      await Future.delayed(
          const Duration(seconds: 3), () => {processDeepLink(initialUri)});
    } catch (e) {
      debugPrint('Initial app link error: $e');
    }
  }

  Future<void> initializeRouter(int? roleId) async {
    if (_router == null || roleId != _currentRoleId) {
      _currentRoleId = roleId;
      _router?.dispose();
      _router = _createRouter(roleId);
      handleAppLinks();
      handleInitialAppLink();
    }
  }

  Future<RouteWithExtra?> getHomeRoute({isNavigate = false}) async {
    await userInformationController.getUserData();
    final userData = userInformationController.userData;
    const signInRoute = '/signin-screen';

    print("heinnnn");
    print(userData);

    if (userData.isNotEmpty) {
      //  is_email_verified: false, is_mobile_verified: false
      if (userData["is_email_verified"] != true &&
          userData["is_mobile_verified"] != true) {
        return RouteWithExtra(signInRoute, null);
      }

      if (userData["is_onboarded"] != true) {
        return RouteWithExtra('/onboard-profile', null);
      }

      try {
        getStreamIO.StreamVideo(
          Constants.getStreamIOKey,
          user: getStreamIO.User(
            info: getStreamIO.UserInfo(
                name: userData["Profile"]?["fullname"],
                id: userData["id"].toString(),
                role: userData["role_id"] == 3 ? "host" : "user"),
          ),
          userToken: userData["stream_token"],
        );
      } catch (e) {
        debugPrint(e.toString());
      }

      // Check for pending deep links after successful auth
      // Handle pending deep links AFTER auth
      final deepLinkController = Get.find<AppLinkController>();
      final CoreSocketServices socketService = Get.find();
      if (deepLinkController.hasPendingRoute) {
        final route = deepLinkController.pendingRoute;
        final extra = deepLinkController.pendingExtra;

        deepLinkController.clearPendingRoute();
        if (route == 'explore-profile') {
          final influencerId = extra!['influencerId'];
          final exploreController = Get.find<ExploreScreenController>();
          exploreController.currentPage.value = 1;

          // Add null check here too
          final influencer = await exploreController.getInfluencers(
            influencerId: influencerId,
          );

          return RouteWithExtra(
            '/explore/explore-profile',
            {
              'influencerId': influencerId,
              'influencer': influencer.toJson(),
              'navigationShell': navigationShellForOther,
              'is_friend': extra['is_friend'],
            },
          );
        }
      }

      // intilize the socket for user level messages
      socketService.joinUserRoom(userData["id"]);
      socketService.listenUserRoom(userData["id"]);
      return RouteWithExtra(_currentRoleId == 3 ? '/chat' : '/explore', null);
    } else {
      return RouteWithExtra(signInRoute, null);
    }
  }

  GoRouter _createRouter(int? roleId) {
    String initialRoute =
        initilized == null || initilized == false ? "/on-boarding" : "/splash";

    return GoRouter(
      initialLocation: initialRoute,
      navigatorKey: rootNavigatorKey,
      debugLogDiagnostics: true,
      redirect: (context, state) async {
        // Define public routes that don't require authentication
        final publicRoutes = [
          '/splash',
          '/signup-screen',
          '/signin-screen',
          '/verify-otp',
          '/mobile-login',
          '/forgot-password',
          '/reset-password',
          '/onboard-profile',
          '/transition',
          '/on-boarding'
        ];

        print("Route - ${state.fullPath}");
        // Skip redirect for public routes
        if (publicRoutes.any((route) => state.fullPath!.startsWith(route))) {
          return null;
        }

        // Check authentication status
        await userInformationController.getUserData();
        final isAuthenticated = userInformationController.userData.isNotEmpty;

        // Redirect unauthenticated users to sign-in
        if (!isAuthenticated) {
          return initialRoute;
        }

        if (userInformationController.userData["is_onboarded"] != true) {
          return '/onboard-profile';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/on-boarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) => CupertinoPage(
            child: SplashScreen(
              onInit: () async {
                // Start both the home route check and timer simultaneously
                final homeRouteFuture = getHomeRoute();
                final minDurationFuture =
                    Future.delayed(const Duration(milliseconds: 3500));

                // Wait for both to complete
                final results =
                    await Future.wait([homeRouteFuture, minDurationFuture]);
                final routeWithExtra = results[0] as RouteWithExtra;
                Future.microtask(() {
                  context.go(routeWithExtra.route,
                      extra: routeWithExtra.extra);
                  Get.find<AppLockService>().triggerLockAfterSplash();
                });
              },
            ),
          ),
        ),
        GoRoute(
          path: '/signup-screen',
          builder: (context, state) => const SingupScreen(),
        ),
        GoRoute(
          path: '/signin-screen',
          builder: (context, state) => const SigninScreen(),
        ),
        GoRoute(
          path: '/verify-otp/:type/:event',
          builder: (context, state) {
            final String event = state.pathParameters['event'] ?? "signin";
            final String type = state.pathParameters['type'] ?? "email";
            return VerifyOtpScreen(
              verifyEvent: event,
              verifyType: type,
            );
          },
        ),
        GoRoute(
          path: '/mobile-login',
          builder: (context, state) => const MobileLoginScreen(),
        ),
        GoRoute(
          path: '/transition',
          builder: (context, state) {
            final String imagePath =
                (state.extra as Map<String, String>)['imagePath'] ?? '';
            return TransitionPage(imagePath: imagePath);
          },
          // builder: (context, state) => TransitionPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => const ResetPasswordScreen(),
        ),
        GoRoute(
          path: '/onboard-profile',
          builder: (context, state) => const ProfileOnboardPage(),
        ),
        // Main app routes
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) {
            navigationShellForOther = navigationShell;
            return CupertinoPage(
              child: HomeDashboard(
                navigationShell: navigationShell,
              ),
            );
          },
          branches: [
            // Conditionally include Explore branch based on roleId
            if (roleId != 3)
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/explore',
                  pageBuilder: (context, state) {
                    return CupertinoPage(
                        child: ExploreScreen(
                      navigationShell: navigationShellForOther,
                    ));
                  },
                  routes: [
                    GoRoute(
                      path: 'explore-profile',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;

                        return ExploreProfileScreen(
                          influencer: Influencer.fromJson(
                            extra['influencer'],
                          ),
                          influencerId: extra["influencerId"] ?? '',
                          navigationShell: extra['navigationShell'],
                        );
                      },
                      parentNavigatorKey: rootNavigatorKey,
                      routes: [
                        GoRoute(
                          path: 'explore-media',
                          builder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;

                            return ExploreGalleryView(
                              influencer:
                                  Influencer.fromJson(extra['influencer']),
                              showcaseData: extra['showcase_slides'],
                              initialIndex: extra['initial_index'] ?? 0,
                            );
                          },
                          parentNavigatorKey: rootNavigatorKey,
                        ),
                      ],
                    ),
                  ],
                )
              ]),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/chat',
                  name: 'chat',
                  pageBuilder: (context, state) {
                    return CupertinoPage(
                      child: ChatScreen(
                        navigationShell: navigationShellForOther,
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: '/chat_setting',
                      name: 'chat_setting',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return CupertinoPage(
                          child: ChatSetting(
                            chatId: extra['chat_id'],
                            friendId: extra['friend_id'],
                            chatUser: extra['chat_user'],
                            profile: extra['profile'],
                            chat: extra['chat'],
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: '/friend_name',
                          name: 'friend_name',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: FriendName(
                                chatId: extra['chat_id'],
                                friendId: extra['friend_id'],
                                chatUser: extra['chat_user'] != null
                                    ? extra['chat_user'].runtimeType != ChatUser
                                        ? ChatUser.fromJson(extra['chat_user'])
                                        : extra['chat_user']
                                    : null,
                              ),
                            );
                          },
                        ),
                        GoRoute(
                          path: '/nick_name',
                          name: 'nick_name',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: YourNickName(
                                  chatId: extra['chat_id'],
                                  friendId: extra['friend_id'],
                                  chatUser: extra['chat_user'] is ChatUser
                                      ? extra['chat_user']
                                      : extra['chat_user'] != null
                                          ? ChatUser.fromJson(
                                              extra['chat_user'])
                                          : null,
                                  isInfluencer: extra['is_influencer']),
                            );
                          },
                        ),
                        GoRoute(
                          path: '/chat_notifications',
                          name: 'chat_notifications',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>?;
                            return CupertinoPage(
                              child: ChatNotification(
                                influencerId: extra?['influencerId'] ?? extra?['influencer_id'],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: '/story_screen',
                      name: 'story_screen',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return CupertinoPage(
                          child: StoryScreen(
                            user: extra['user'],
                            chatId: extra['chat_id'],
                            chat: extra['chat'],
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: '/chat_profile',
                      name: 'chat_profile',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        final profile = UserProfile.fromJson(extra['profile']);
                        final chatUser = ChatUser.fromJson(extra['chat_user']);
                        final closerDays = extra['closer_days'] ?? '';
                        return CupertinoPage(
                          child: ChatProfile(
                            profile: profile,
                            closerDays: closerDays,
                            chatId: extra['chat_id'],
                            chatUser: chatUser,
                            chat: extra['chat'],
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: '/chat_image_preview_screen',
                          name: 'chat_image_preview_screen',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: ImagePreviewScreen(
                                imagesToPreview: extra['imagesToPreview'],
                                chatAdmin: extra['chatAdmin'],
                                chat: extra['chat'],
                                isChat: true,
                              ),
                            );
                          },
                        ),
                        GoRoute(
                          path: '/chat_memories',
                          name: 'chat_memories',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: Memories(
                                chatId: int.parse(extra['chat_id']),
                              ),
                            );
                          },
                        ),
                        GoRoute(
                          path: '/profile_chat_media_screen',
                          name: 'profile_chat_media_screen',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: ChatMediaScreen(
                                chatId: extra['chat_id'],
                                chatUser: extra['user'],
                                profile: extra['profile'],
                                chat: extra['chat'],
                                navigationShell: navigationShellForOther,
                              ),
                            );
                          },
                          routes: [
                            GoRoute(
                              path: '/profile_media_view_screen',
                              name: 'profile_media_view_screen',
                              parentNavigatorKey: rootNavigatorKey,
                              pageBuilder: (context, state) {
                                final extra =
                                    state.extra as Map<String, dynamic>;
                                return CupertinoPage(
                                  child: ChatMediaView(
                                    mediaType: extra['type'],
                                    media: extra['media'],
                                    mediaList: extra['media_list'],
                                    chatUser: extra['user'],
                                    loggedInUser: extra['profile'],
                                    chat: extra['chat'],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    GoRoute(
                      path: '/chat_message',
                      name: 'chat_message',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return CupertinoPage(
                          child: ChatMessage(
                            chat: extra['chat'],
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'chat_media_screen',
                          name: 'chat_media_screen',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: ChatMediaScreen(
                                chatId: extra['chat_id'],
                                chatUser: extra['user'],
                                profile: extra['profile'],
                                chat: extra['chat'],
                                navigationShell: navigationShellForOther,
                              ),
                            );
                          },
                          routes: [
                            GoRoute(
                              path: '/media_view_screen',
                              name: 'media_view_screen',
                              parentNavigatorKey: rootNavigatorKey,
                              pageBuilder: (context, state) {
                                final extra =
                                    state.extra as Map<String, dynamic>;
                                return CupertinoPage(
                                  child: ChatMediaView(
                                    mediaType: extra['type'],
                                    media: extra['media'],
                                    mediaList: extra['media_list'],
                                    chatUser: extra['user'],
                                    loggedInUser: extra['profile'],
                                    chat: extra['chat'],
                                  ),
                                );
                              },
                            ),
                            GoRoute(
                              path: '/chat_message_notifications',
                              name: 'chat_message_notifications',
                              parentNavigatorKey: rootNavigatorKey,
                              pageBuilder: (context, state) {
                                final extra =
                                    state.extra as Map<String, dynamic>;
                                return CupertinoPage(
                                  child: ChatNotification(
                                    influencerId: extra['influencer_id'],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        GoRoute(
                          path: '/chat_friends_events',
                          name: 'chat_friends_events',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: FriendsEventsScreen(
                                profile: extra['friend'],
                                isChat: true,
                                chatId: extra['chat_id'],
                                chat: extra['chat'],
                              ),
                            );
                          },
                          routes: [
                            GoRoute(
                              path: '/chat_friends_create_event',
                              name: 'chat_friends_create_event',
                              parentNavigatorKey: rootNavigatorKey,
                              pageBuilder: (context, state) {
                                final extra =
                                    state.extra as Map<String, dynamic>;

                                return CupertinoPage(
                                  child: CreateEvents(
                                    profile: extra['friend'],
                                    event: extra['event'],
                                    isEdit: extra['isEdit'],
                                    isChat: true,
                                  ),
                                );
                              },
                              routes: [
                                GoRoute(
                                  path: '/chat_create_image_preview_screen',
                                  name: 'chat_create_image_preview_screen',
                                  parentNavigatorKey: rootNavigatorKey,
                                  pageBuilder: (context, state) {
                                    final extra =
                                        state.extra as Map<String, dynamic>;
                                    return CupertinoPage(
                                      child: ImagePreviewScreen(
                                        imagesToPreview:
                                            (extra['imagesToPreview'] as List?)?.cast<String>() ?? [],
                                        isChat: true,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/events',
                  pageBuilder: (context, state) {
                    return CupertinoPage(
                      child: EventsTab(
                        navigationShell: navigationShellForOther,
                      ),
                    );
                  },
                  routes: [
                     GoRoute(
                       path: '/image_preview_screen',
                       name: 'image_preview_screen',
                       parentNavigatorKey: rootNavigatorKey,
                       pageBuilder: (context, state) {
                         final extra = state.extra as Map<String, dynamic>;
                         return CupertinoPage(
                           child: ImagePreviewScreen(
                             imagesToPreview:
                                 (extra['imagesToPreview'] as List?)?.cast<String>() ?? [],
                             isEvent: extra['isEvent'] as bool?,
                             eventName: extra['eventName'] as String?,
                             eventTime: extra['eventTime'] as String?,
                             influencerProfilePic: extra['influencerProfilePic'] as String?,
                           ),
                         );
                       },
                     ),
                    GoRoute(
                      path: '/upcoming_events',
                      name: 'upcoming_events',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return const CupertinoPage(
                          child: UpcomingEventsScreen(),
                        );
                      },
                    ),
                    GoRoute(
                      path: '/friends_events',
                      name: 'friends_events',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return CupertinoPage(
                          child: FriendsEventsScreen(
                            profile: extra['friend'],
                            chat: extra['chat'],
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                            path: '/create_event',
                            name: 'friends_create_event',
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) {
                              final extra = state.extra as Map<String, dynamic>;

                              return CupertinoPage(
                                child: CreateEvents(
                                  profile: extra['friend'],
                                  event: extra['event'],
                                  isEdit: extra['isEdit'],
                                ),
                              );
                            },
                            routes: [
                              GoRoute(
                                path: '/create_image_preview_screen',
                                name: 'create_image_preview_screen',
                                parentNavigatorKey: rootNavigatorKey,
                                pageBuilder: (context, state) {
                                  final extra =
                                      state.extra as Map<String, dynamic>;
                                  return CupertinoPage(
                                    child: ImagePreviewScreen(
                                      imagesToPreview:
                                          (extra['imagesToPreview'] as List?)?.cast<String>() ?? [],
                                    ),
                                  );
                                },
                              ),
                            ]),
                      ],
                    ),
                    GoRoute(
                      path: '/all_friends',
                      name: 'all_friends',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return const CupertinoPage(
                          child: AllFriendEventsScreen(),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  pageBuilder: (context, state) {
                    return const CupertinoPage(
                      child: SettingScreen(),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: '/manage_account',
                      name: 'manage_account',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return CupertinoPage(
                          child: ManageAccount(
                            user: extra['user'],
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: '/friends',
                      name: 'friends',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return CupertinoPage(
                          child: FriendTab(
                            navigationShell: navigationShellForOther,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: '/notification_settings',
                      name: 'notification_settings',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return const CupertinoPage(
                          child: ChatNotification(),
                        );
                      },
                    ),
                    GoRoute(
                      path: '/preferences',
                      name: 'preferences',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return const CupertinoPage(
                          child: PreferencesScreen(),
                        );
                      },
                    ),
                    GoRoute(
                      path: '/manage_showcase_profile',
                      name: 'manage_showcase_profile',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;

                        return CupertinoPage(
                          child: ExploreProfileScreen(
                            influencer: Influencer.fromJson(
                              extra['influencer'],
                            ),
                            influencerId: extra["influencerId"] ?? '',
                          ),
                        );
                      },
                    ),
                    GoRoute(
                        path: '/my_payouts',
                        name: 'my_payouts',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          return const CupertinoPage(
                            child: MyPayouts(),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: '/add_bank_account',
                            name: 'add_bank_account',
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) {
                              return const CupertinoPage(
                                child: AddBankAccounts(),
                              );
                            },
                          ),
                          GoRoute(
                            path: '/payout_informations',
                            name: 'payout_informations',
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) {
                              return const CupertinoPage(
                                child: PayoutInfornmations(),
                              );
                            },
                          ),
                          GoRoute(
                            path: '/dashboard_and_analytics',
                            name: 'dashboard_and_analytics',
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) {
                              return const CupertinoPage(
                                child: DashboardAndAnalytics(),
                              );
                            },
                          ),
                        ]),

                    GoRoute(
                      path: '/faqs_and_about',
                      name: 'faqs_and_about',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return const CupertinoPage(
                          child: FAQAndAbout(),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: '/faq_account_profile',
                          name: 'faq_account_profile',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return CupertinoPage(
                              child: AccountAndProfile(
                                categoryId: extra['category_id'],
                                title: extra['title'],
                              ),
                            );
                          },
                          routes: [
                            GoRoute(
                              path: '/faq_contact_us',
                              name: 'faq_contact_us',
                              parentNavigatorKey: rootNavigatorKey,
                              pageBuilder: (context, state) {
                                return const CupertinoPage(
                                  child: ContactUs(),
                                );
                              },
                              routes: [
                                GoRoute(
                                  path: '/faq_contact_us_page',
                                  name: 'faq_contact_us_page',
                                  parentNavigatorKey: rootNavigatorKey,
                                  pageBuilder: (context, state) {
                                    return const CupertinoPage(
                                      child: FAQAndAbout(),
                                    );
                                  },
                                  routes: [
                                    GoRoute(
                                      path: '/faq_contact_us_profile',
                                      name: 'faq_contact_us_profile',
                                      parentNavigatorKey: rootNavigatorKey,
                                      pageBuilder: (context, state) {
                                        final extra =
                                            state.extra as Map<String, dynamic>;
                                        return CupertinoPage(
                                          child: AccountAndProfile(
                                            categoryId: extra['category_id'],
                                            title: extra['title'],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    GoRoute(
                      path: '/terms_and_policies',
                      name: 'terms_and_policies',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return CupertinoPage(
                          child: TermAndPolicies(
                            title: extra['title'],
                            path: extra['path'],
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: '/contact_us',
                      name: 'contact_us',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return const CupertinoPage(
                          child: ContactUs(),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: '/contact_us_faqs_and_about',
                          name: 'contact_us_faqs_and_about',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            return const CupertinoPage(
                              child: FAQAndAbout(),
                            );
                          },
                          routes: [
                            GoRoute(
                              path: '/contact_us_faq_account_profile',
                              name: 'contact_us_faq_account_profile',
                              parentNavigatorKey: rootNavigatorKey,
                              pageBuilder: (context, state) {
                                final extra =
                                    state.extra as Map<String, dynamic>;
                                return CupertinoPage(
                                  child: AccountAndProfile(
                                    categoryId: extra['category_id'],
                                    title: extra['title'],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        GoRoute(
                          path: '/contact_us_creator_faq',
                          name: 'contact_us_creator_faq',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) {
                            return const CupertinoPage(
                              child: CreatorFaq(),
                            );
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: '/about',
                      name: 'about',
                      parentNavigatorKey: rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return const CupertinoPage(
                          child: AboutScreen(),
                        );
                      },
                    ),
                    // GoRoute(
                    //   path: '/manage_showcase_profile',
                    //   name: 'manage_showcase_profile',
                    //   parentNavigatorKey: rootNavigatorKey,
                    //   pageBuilder: (context, state) {
                    //     final extra = state.extra as Map<String, dynamic>;

                    //     return CupertinoPage(
                    //       child: ExploreProfileScreen(
                    //         influencer: Influencer.fromJson(
                    //           extra['influencer'],
                    //         ),
                    //         influencerId: extra["influencerId"] ?? '',
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/closerrr/profile/:influencerId',
          redirect: (context, state) => null, // Handled in main redirect
          builder: (context, state) => const SplashScreen(),
        ),
        //  Home Screen
        GoRoute(
          path: '/home-screen',
          builder: (context, state) => HomeDashboard(
            navigationShell: navigationShellForOther,
          ),
        ),
        // live stream
        GoRoute(
          path: '/live_stream',
          name: 'live_stream',
          builder: (context, state) {
            return LiveStream(state: state);
          },
        ),
        // stream call
        GoRoute(
          path: '/stream_call',
          name: 'stream_call',
          builder: (context, state) {
            return StreamCall(state: state);
          },
        )
      ],
    );
  }

  @override
  void onClose() {
    _router?.dispose();
    super.onClose();
  }
}
