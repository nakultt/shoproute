import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants/api_endpoints.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<
    Map<
      String,
      dynamic
    >
  >
  login(
    String email,
    String password,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email_or_username': email,
          'password': password,
        },
      );

      if (response.data['success'] ==
          true) {
        final token = response.data['data']['token'];
        if (token !=
            null) {
          await ApiClient.saveToken(
            token,
          );
        }
        return response.data['data']['user'];
      } else {
        throw Exception(
          response.data['error'] ??
              'Login failed',
        );
      }
    } on DioException catch (
      e
    ) {
      throw Exception(
        e.response?.data['error'] ??
            'Connection failed',
      );
    }
  }

  Future<
    Map<
      String,
      dynamic
    >
  >
  register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response.data['success'] ==
          true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['error'] ??
              'Registration failed',
        );
      }
    } on DioException catch (
      e
    ) {
      throw Exception(
        e.response?.data['error'] ??
            'Connection failed',
      );
    }
  }

  Future<
    Map<
      String,
      dynamic
    >
  >
  getCurrentUser() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.me,
      );

      if (response.data['success'] ==
          true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['error'] ??
              'Failed to get user profile',
        );
      }
    } on DioException catch (
      e
    ) {
      throw Exception(
        e.response?.data['error'] ??
            'Connection failed',
      );
    }
  }

  Future<
    bool
  >
  verifyEmail(
    String email,
    String otp,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyEmail,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      return response.data['success'] ==
          true;
    } on DioException catch (
      e
    ) {
      throw Exception(
        e.response?.data['error'] ??
            'Verification failed',
      );
    }
  }

  Future<
    void
  >
  resendOtp(
    String email,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resendOtp,
        data: {
          'email': email,
        },
      );

      if (response.data['success'] !=
          true) {
        throw Exception(
          response.data['error'] ??
              'Failed to resend OTP',
        );
      }
    } on DioException catch (
      e
    ) {
      throw Exception(
        e.response?.data['error'] ??
            'Connection failed',
      );
    }
  }

  Future<
    void
  >
  logout() async {
    await ApiClient.clearToken();
  }

  Future<
    bool
  >
  isLoggedIn() async {
    return await ApiClient.hasToken();
  }
}
