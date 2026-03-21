import 'package:closerrr/core/services/http_service.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/failure.dart';
import 'package:dartz/dartz.dart';

class InAppPurchaseServices {
  final HttpService httpService = HttpService();

  Future<Either<Failure, Map<String, dynamic>>> createSubscription({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.createSubscription,
        data: data,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // create transaction
  Future<Either<Failure, Map<String, dynamic>>> createTransaction({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await httpService.post(
        ApiStrings.createTransaction,
        data: data,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
