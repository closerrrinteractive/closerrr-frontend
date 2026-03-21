import 'dart:convert';

import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;
import 'package:get/get_core/src/get_main.dart';

class HttpService {
  final Dio _dio = Dio();
  final String baseUrl;
  final UserInformationController userInformationController = Get.find();
  HttpService._privateConstructor(this.baseUrl) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  static final HttpService _instance =
      HttpService._privateConstructor(ApiStrings.baseUrl);
  int retryCount = 0;

  factory HttpService() {
    return _instance;
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters,
      loading,
      Options? options}) async {
    final isLoading = loading != null;

    try {
      if (isLoading) loading.value = true;
      final Response response = await _dio.get(
        path,
        options: options,
        queryParameters: queryParameters,
      );

      if (isLoading) loading.value = false;
      return response;
    } on DioException catch (e) {
      // if (retryCount > 0) return _handleError(e);
      // final errorResponse = e.response;
      // if (errorResponse?.statusCode == 401) {
      //   retryCount++;
      //   await refreshAccessToken();
      //   return get(path,
      //       queryParameters: queryParameters,
      //       loading: loading,
      //       options: options);
      // }
      // kLog(e);
      return _handleError(e);
    } catch (error) {
      // kLog(error);
      if (isLoading) loading.value = false;
      return _handleError(error);
    }
  }

  Future<Response> delete(String path,
      {Map<String, dynamic>? queryParameters, loading}) async {
    final isLoading = loading != null;

    try {
      if (isLoading) loading.value = true;
      final Response response =
          await _dio.delete(path, queryParameters: queryParameters);
      if (isLoading) loading.value = false;

      return response;
    } on DioException catch (e) {
      if (retryCount > 0) return _handleError(e);

      // final errorResponse = e.response;
      // refresh the expired token with the help of refresh token
      // if (errorResponse?.statusCode == 401) {
      //   retryCount++;
      //   await refreshAccessToken();
      //   return delete(path, queryParameters: queryParameters, loading: loading);
      // }

      return _handleError(e);
    } catch (error) {
      if (isLoading) loading.value = false;
      return _handleError(error);
    }
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? data, bool? isFormData = true, loading}) async {
    final isLoading = loading != null;
    data?.removeWhere((key, value) => value == null || value == '');

    try {
      if (isLoading) loading.value = true;
      // Create FormData
      FormData formData = FormData.fromMap(data ?? {});
      // if (isFormData ?? false) {
      //   kLog(data);
      // }
      // Make the POST request with FormData
      final Response response = await _dio.post(
        path,
        data: isFormData! ? formData : data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (isLoading) {
        loading.value = false;
      }

      resetRetryCount();
      return response;
    } on DioException catch (e) {
      if (retryCount > 0) return _handleError(e);

      // final errorResponse = e.response;
      // refresh the expired token with the help of refresh token
      // if (errorResponse?.statusCode == 401) {
      //   retryCount++;
      //   await refreshAccessToken();
      //   return post(path, data: data, isFormData: isFormData, loading: loading);
      // }

      return _handleError(e);
    } catch (error) {
      if (isLoading) loading.value = false;
      return _handleError(error);
    }
  }

  Future<Response> patch(String path,
      {Map<String, dynamic>? data, loading, bool? isFormData = true}) async {
    final isLoading = loading != null;

    try {
      if (isLoading) loading.value = true;
      FormData formData = FormData.fromMap(data ?? {});

      final Response response = await _dio.patch(
        path,
        data: isFormData! ? formData : json.encode(data),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (isLoading) {
        loading.value = false;
      }

      return response;
    } on DioException catch (e) {
      if (retryCount > 0) return _handleError(e);

      final errorResponse = e.response;
      if (errorResponse?.statusCode == 401) {
        retryCount++;
        await refreshAccessToken();
        return patch(
          path,
          data: data,
          loading: loading,
          isFormData: isFormData,
        );
      }

      return _handleError(e);
    } catch (error) {
      if (isLoading) loading.value = false;
      return _handleError(error);
    }
  }

  // Add other HTTP methods as needed

  Future<bool> refreshAccessToken() async {
    final userData = userInformationController.userData;

    final response = await post(ApiStrings.refreshAccessToken, data: {
      "refresh_token": userData["refreshToken"],
      "access_token": userData["accessToken"],
    });

    final data = response.data["data"];
    userData["accessToken"] = data["accessToken"];
    await userInformationController.setUserData(userData);
    return true;
  }

  resetRetryCount() {
    if (retryCount > 0) {
      retryCount = 0;
    }
  }

  dynamic _handleError(error) {
    print("Hey debuggggggg error");
    print(error);
    String message =
        error.response.data['error_message'] ?? "Something went wrong";
    if (message == "username must be unique") {
      message = "Username already taken.";
    }
    CustomSnackbar.show(title: '', message: message);
    // return error.response;
    throw Exception(message);
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    kLog("""BaseUrl - $baseUrl,
Method - ${options.method},
Path - ${options.path},
Data - ${options.data},
Payload - ${options.queryParameters},
Extra - ${options.extra},
Response Type - ${options.responseType},
""");
    options.baseUrl = baseUrl;
    options.contentType = Headers.jsonContentType;
    if (!options.path.contains('s3.amazonaws.com') &&
        userInformationController.userData.containsKey("accessToken")) {
      String authToken = userInformationController.userData['accessToken'];
      options.headers['Authorization'] = 'Bearer $authToken';
    }
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    kLog("""BaseUrl - ${response.requestOptions.baseUrl}
Method - ${response.requestOptions.method}
Path - ${response.requestOptions.path}
Data - ${response.requestOptions.data}
Response - ${response.data},
""");
    resetRetryCount();
    handler.next(response);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) async {
    // Handle error responses globally
    kLog("""BaseUrl - ${error.requestOptions.baseUrl} 
Method - ${error.requestOptions.method}
Path - ${error.requestOptions.path}
Data - ${error.requestOptions.data}
Error - ${error.response?.data},
""");
    if (error.response != null) {
      if (error.response!.statusCode == 401) {
        // await authServicesController.logOut();
      }
    }
    handler.next(error);
  }
}
