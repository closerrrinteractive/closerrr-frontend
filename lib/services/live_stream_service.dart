import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/services/http_service.dart';
import 'package:closerrr/core/services/socket_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/constant_string.dart';
import 'package:closerrr/core/utils/failure.dart' as utils;
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stream_video/stream_video.dart';

class LiveStreamService {
  final HttpService httpService = HttpService();
  final CoreSocketServices socketService = Get.find();
  final UserInformationController userInformationController = Get.find();

  Future startLivestream({String? id, bool join = false, streamId}) async {
    final userData = userInformationController.userData;

    try {
      if (!StreamVideo.isInitialized()) {
        await userInformationController.getUserData();
        StreamVideo(Constants.getStreamIOKey,
            user: User(
              info: UserInfo(
                  name: userData["Profile"]?["fullname"],
                  id: userData["id"].toString(),
                  role: userData["role_id"] == 3 ? "host" : "user"),
            ),
            userToken: userData["stream_token"]);
      }

      String liveStreamId =
          "livestream_${userData["id"]}_${DateTime.now().millisecondsSinceEpoch}";
      // Set up our call object
      var call = StreamVideo.instance.makeCall(
          callType: StreamCallType.liveStream(),
          id: join ? streamId! : liveStreamId);
      // Create the call and set the current user as a host
      final result = await call.getOrCreate(members: [
        MemberRequest(
          userId: StreamVideo.instance.currentUser.id,
          role: join ? 'user' : 'host',
        ),
      ], custom: {
        "data": userData
      });

      if (result.isFailure) {
        debugPrint('Not able to create a call.');
        return;
      }

      if (!join) {
        // Configure the call to allow users to join before it starts by setting a future start time
        // and specifying how many seconds in advance they can join via `joinAheadTimeSeconds`
        final updateResult = await call.update(
          startsAt: DateTime.now().toUtc().add(const Duration(seconds: 120)),
          backstage: const StreamBackstageSettings(
            enabled: true,
            joinAheadTimeSeconds: 120,
          ),
        );

        if (updateResult.isFailure) {
          debugPrint('Not able to update the call.');
          return;
        }
      }

      // Set some default behaviour for how our devices should be configured once we join a call
      final connectOptions = CallConnectOptions(
        camera: TrackOption.enabled(),
        microphone: TrackOption.enabled(),
      );
      // Our local app user can join and receive events
      await call.join(connectOptions: connectOptions);

      if (join) {
        socketService.joinLiveStream({
          "userId": id,
        });
      }

      return {"call": call, "id": liveStreamId};
    } catch (e) {
      debugPrint('Error while creating a live stream');
      debugPrint(e.toString());
      return false;
    } finally {
      CustomLoader.hide();
    }
  }

  Future<Either<utils.Failure, Map<String, dynamic>>> startLiveStream(
      {required Map<String, dynamic> data}) async {
    try {
      final response =
          await httpService.post(ApiStrings.startLiveStream, data: data);
      return Right(response.data);
    } catch (e) {
      return Left(utils.ServerFailure(message: e.toString()));
    }
  }

  Future<Either<utils.Failure, Map<String, dynamic>>> endLiveStream(
      {required Map<String, dynamic> data}) async {
    try {
      final response =
          await httpService.post(ApiStrings.endLiveStream, data: data);
      return Right(response.data);
    } catch (e) {
      return Left(utils.ServerFailure(message: e.toString()));
    }
  }

  Future<Either<utils.Failure, Map<String, dynamic>>> addCommentToLiveStream(
      {required Map<String, dynamic> data}) async {
    try {
      final response =
          await httpService.post(ApiStrings.addComment, data: data);
      return Right(response.data);
    } catch (e) {
      return Left(utils.ServerFailure(message: e.toString()));
    }
  }
}
