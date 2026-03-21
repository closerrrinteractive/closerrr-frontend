class ApiStrings {
  // static String get baseUrl {
  //   final UserInformationController userInformationController = Get.find();
  //   // return 'http://${userInformationController.ipAddress.value}:5253/api/v1/';
  //   return 'http://192.168.92.133:5253/api/v1/';
  // }
  // static const String baseUrl =
  //     'https://d0m8w517-5253.inc1.devtunnels.ms/api/v1/';
  // static const String imageUrl = 'https://d0m8w517-5253.inc1.devtunnels.ms/';
  // static const String socketUrl = 'https://d0m8w517-5253.inc1.devtunnels.ms/';
  static const String baseUrl = 'https://app.closerrr.com/closerrr/api/v1/';
  static const String imageUrl = 'https://app.closerrr.com/closerrr/';
  static const String socketUrl = 'https://app.closerrr.com/';
  static const String creatorTermsCondtions = 'https://closerrr.com/creator/termsandconditions';
  static const String creatorPrivacyPolicy = 'https://closerrr.com/creator/privacyandpolicy';
  static const String fanTermsCondtions = 'https://closerrr.com/TermsAndCondition';
  static const String fanPrivacyPolicy = 'https://closerrr.com/PrivacyAndPolicy';
  // static const String baseUrl = 'http://192.168.1.2:5253/api/v1/';
  // static const String imageUrl = 'http://192.168.1.2:5253/';
  // static const String socketUrl = 'http://192.168.1.2:5253/';
  static const String s3ImageUrl =
      'https://closerrr-chat-media.s3.us-east-1.amazonaws.com/';
  static const String signUp = 'auth/sign-up';
  static const String signIn = 'auth/sign-in';
  static const String socialLogin = 'auth/3rd-party-sign-in';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String sendOtp = 'auth/send-otp';
  static const String forgotPassword = 'auth/forgot-password';
  static const String onboardProfile = 'onboarding';
  static const String saveFcmToken = 'save-fcm-token';

  static const String getUserNotificationSetting =
      'notification/get-user-notification-setting';
  static const String updateUserNotificationSetting =
      'notification/update-user-notification-setting';

  static const String updateEmailAndMobileNoSendOtp =
      'auth/update-email-mobile-send-otp';
  static const String updateEmailAndMobileNo = 'auth/update-email-mobile';

  // User Data Update
  static const String updateFanUserInfo = 'profile/update-fan-profile';
  static const String updateInfluencerUserInfo =
      'profile/update-influencer-profile';
  static const String getFriends = 'friend/get';
  static const String removeFriend = 'friend/add-remove-friend';

  // Explore
  static const String getInfluencers = 'explore/get-influencers';
  static const String getInfluencerShowcase = 'profile/get-showcase';
  static const String updateShowcase = 'profile/update-showcase';
  // Events
  static const String getEvents = 'event/get';
  static const String getAllFriends = 'event/all-friends';
  static const String addEvent = 'event/add';
  static const String editEvent = 'event/edit';
  static const String deleteEvent = 'event/delete';
  static const String deleteAccount = 'delete-account';

  // FAQ
  static const String getFaq = 'faq/get-faqs';
  static const String getFaqCategories = 'faq/get-faq-categories';

  // access and refresh token
  static const String refreshAccessToken = 'auth/refresh-access-token';

  // Chat Strings
  static const String getChats = 'chat/get-chats';
  static const String getChatMessages = 'chat/get-chat-messages';
  static const String getStarredMessages = 'chat/get-starred-messages';
  static const String getChatMedia = 'chat/get-chat-media';
  static const String getUnreadMessagesCount = 'chat/get-unread-messages-count';
  static const String getChatUsers = 'chat/get-chat-users';
  static const String getStory = 'story/get-story';
  static const String generatePresignedUrls = 'generate-presigned-urls';

  static const String sendMessage = 'chat/send-message';

  static const String addAndRemoveStarredMessage =
      'chat/add-remove-starred-message';
  static const String addAndRemoveFavouriteChat =
      'chat/add-remove-favourite-chat';
  static const String addStory = 'story/add-story';

  static const String updateSeenStatus = 'chat/update-seen-status';
  static const String updateNickname = 'chat/update-nickname';
  static const String updateChatBackground = 'chat/update-chat-background';
  static const String updateChatSettings = 'chat/update-chat';
  // static const String onboardProfile = 'onboarding';
  // static const String saveFcmToken = 'save-fcm-token';
  static const String likeStory = 'story/like-unlike-story';
  static const String report = 'report';

  // InAppPurchase
  static const String createSubscription = 'subscription/create';
  static const String createTransaction = 'subscription/create-transaction';

  // Setting API
  static const String subscriptionAnalytics = 'subscription-analytics';
  static const String getPayoutUpcommingDetails = 'payout/upcomming';
  static const String getBeneficiaryDetail = 'payout/get-beneficiary-detail';
  static const String addBeneficiaryAccount = 'cashfree/add-beneficiary';
  static const String getTranscationHistory = 'payout/history';

  // Delete Message
  static const String deleteMessage = "chat/delete-message";

  // live stream
  static const String startLiveStream = "live-stream/start-live-stream";
  static const String endLiveStream = "live-stream/end-live-stream";
  static const String addComment = "live-stream/add-comment";
  static const String deleteStory = "story/delete-story";

  // Update chat group
  static const String updateChatGroup = 'chat/update-chat';
}
