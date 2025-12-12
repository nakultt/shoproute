import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../config/constants/api_endpoints.dart';
import '../../config/constants/app_constants.dart';

/// API Client using Dio with JWT authentication
class ApiClient {
  static ApiClient? _instance;
  static const _storage = FlutterSecureStorage();

  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.apiBase,
        connectTimeout: const Duration(
          seconds: 30,
        ),
        receiveTimeout: const Duration(
          seconds: 30,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll(
      [
        // Auth Interceptor
        InterceptorsWrapper(
          onRequest:
              (
                options,
                handler,
              ) async {
                final token = await getToken();
                if (token !=
                    null) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                handler.next(
                  options,
                );
              },
          onError:
              (
                error,
                handler,
              ) async {
                if (error.response?.statusCode ==
                    401) {
                  await clearToken();
                }
                handler.next(
                  error,
                );
              },
        ),
        // Logger (only in debug mode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      ],
    );
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  // Token management
  static Future<
    void
  >
  saveToken(
    String token,
  ) async {
    await _storage.write(
      key: AppConstants.tokenKey,
      value: token,
    );
  }

  static Future<
    String?
  >
  getToken() async {
    return await _storage.read(
      key: AppConstants.tokenKey,
    );
  }

  static Future<
    void
  >
  clearToken() async {
    await _storage.delete(
      key: AppConstants.tokenKey,
    );
  }

  static Future<
    bool
  >
  hasToken() async {
    final token = await getToken();
    return token !=
            null &&
        token.isNotEmpty;
  }

  // HTTP Methods
  Future<
    Response<
      T
    >
  >
  get<
    T
  >(
    String path, {
    Map<
      String,
      dynamic
    >?
    queryParameters,
    Options? options,
  }) async {
    return _dio.get<
      T
    >(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<
    Response<
      T
    >
  >
  post<
    T
  >(
    String path, {
    dynamic data,
    Map<
      String,
      dynamic
    >?
    queryParameters,
    Options? options,
  }) async {
    return _dio.post<
      T
    >(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<
    Response<
      T
    >
  >
  put<
    T
  >(
    String path, {
    dynamic data,
    Map<
      String,
      dynamic
    >?
    queryParameters,
    Options? options,
  }) async {
    return _dio.put<
      T
    >(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<
    Response<
      T
    >
  >
  delete<
    T
  >(
    String path, {
    dynamic data,
    Map<
      String,
      dynamic
    >?
    queryParameters,
    Options? options,
  }) async {
    return _dio.delete<
      T
    >(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
