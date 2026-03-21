import 'package:closerrr/core/services/http_service.dart';
import 'package:closerrr/src/models/setting/get_transaction_history.dart';
import 'package:closerrr/src/models/setting/my_friend_response.dart';
import 'package:closerrr/src/models/setting/notification.dart';
import 'package:closerrr/src/models/setting/payout_upcomming.dart';
import 'package:closerrr/src/models/setting/subscription_analytics.dart';
import 'package:dartz/dartz.dart';

import '../core/utils/api_string.dart';
import '../core/utils/failure.dart';
import '../src/models/setting/faq_categories.dart';
import '../src/models/setting/faqs_model.dart';
import '../src/models/setting/get_beneficiary_details.dart';

class SettingServices {
  final HttpService httpService = HttpService();

  Future<Either<Failure, Map<String, dynamic>>> updateUserInfo({
    required Map<String, dynamic> data,
    required bool isInfluencer,
  }) async {
    try {
      data.removeWhere(
          (key, value) => value == null || value.toString().trim().isEmpty);
      final response = await httpService.patch(
        isInfluencer
            ? ApiStrings.updateInfluencerUserInfo
            : ApiStrings.updateFanUserInfo,
        data: data,
        isFormData: true,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, MyFriendsResponse>> getFriends() async {
    try {
      final response = await httpService.get(ApiStrings.getFriends);
      return Right(MyFriendsResponse.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> removeFriend({
    required int id,
  }) async {
    try {
      final response =
          await httpService.get(ApiStrings.removeFriend, queryParameters: {
        'friend_id': id,
      });
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, UserNotifications>> getNotifications(
      {required String id}) async {
    try {
      final response = await httpService.get(
        ApiStrings.getUserNotificationSetting,
        queryParameters: {
          'influencer_id': id,
        },
      );
      return Right(UserNotifications.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> updateUserNotificationSetting({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await httpService.patch(
        ApiStrings.updateUserNotificationSetting,
        data: data,
        isFormData: true,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> sendOtp(
      {required String type, required String value}) async {
    try {
      final response = await httpService.post(
        ApiStrings.updateEmailAndMobileNoSendOtp,
        data: {
          'type': type,
          'value': value,
        },
        isFormData: false,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> verifyOtp({
    required String type,
    required String value,
    required String otp,
  }) async {
    try {
      final response = await httpService.post(ApiStrings.updateEmailAndMobileNo,
          data: {
            'type': type,
            'value': value,
            'otp': otp,
          },
          isFormData: false);
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> deleteAccount({
    required int id,
  }) async {
    try {
      final response =
          await httpService.get(ApiStrings.deleteAccount, queryParameters: {
        'soft_delete': true,
      });
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// [FAQData]
  Future<Either<Failure, FaqCategories>> getFaqCategories() async {
    try {
      final response = await httpService.get(ApiStrings.getFaqCategories);
      return Right(FaqCategories.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, FaQs>> getFaq({
    required int categoryId,
  }) async {
    try {
      final response =
          await httpService.get(ApiStrings.getFaq, queryParameters: {
        'category_id': categoryId,
      });
      return Right(FaQs.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, SubscriptionAnalytics>> subscriptionAnalytics() async {
    try {
      final response = await httpService.get(ApiStrings.subscriptionAnalytics);
      return Right(SubscriptionAnalytics.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, PayoutUpcomming>> getPayoutUpcommingDetails() async {
    try {
      final response =
          await httpService.get(ApiStrings.getPayoutUpcommingDetails);
      return Right(PayoutUpcomming.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, BeneficiaryDetail>> getBeneficiaryDetail() async {
    try {
      final response = await httpService.get(ApiStrings.getBeneficiaryDetail);
      return Right(BeneficiaryDetail.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> addBeneficiaryAccount({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.addBeneficiaryAccount,
        data: data,
        isFormData: false,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, TranscationHistory>> getTranscationHistory({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await httpService.get(
        ApiStrings.getTranscationHistory,
        queryParameters: data,
      );
      return Right(TranscationHistory.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
