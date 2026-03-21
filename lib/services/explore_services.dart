import 'package:closerrr/core/services/http_service.dart';
import 'package:closerrr/src/models/explore/get_influencer_response.dart';
import 'package:dartz/dartz.dart';

import '../core/utils/api_string.dart';
import '../core/utils/failure.dart';
import '../src/models/showcase/get_showcase.dart';

class ExploreScreenServices {
  final HttpService httpService = HttpService();

  Future<Either<Failure, Influencers>> getInfluencers(
      {required int page,
      required int limit,
      required String sort,
      String? name,
      String? influencerId}) async {
    try {
      //Stan
      final response = await httpService.get(
        ApiStrings.getInfluencers,
        queryParameters: {
          'name': name,
          'page': page,
          'limit': 10,
          'sort': sort,
          'influencer_id': influencerId
        },
      );
      return Right(Influencers.fromJson(response.data));
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

  Future<Either<Failure, GetShowcaseResponse>> getInfluencerShowcase(
      {required int id}) async {
    try {
      final response = await httpService.get(
        '${ApiStrings.getInfluencerShowcase}/$id',
      );
      return Right(GetShowcaseResponse.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> updateShowcase(
      {required Map<String, dynamic> data}) async {
    try {
      final response =
          await httpService.post(ApiStrings.updateShowcase, data: data);
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
