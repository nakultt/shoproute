import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants/api_endpoints.dart';

class AiService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<
    Map<
      String,
      dynamic
    >
  >
  sendMessage({
    required String message,
    List<
      Map<
        String,
        dynamic
      >
    >?
    conversationHistory,
    Map<
      String,
      double
    >?
    userLocation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.aiChat,
        data: {
          'message': message,
          if (conversationHistory !=
              null)
            'conversation_history': conversationHistory,
          if (userLocation !=
              null)
            'user_location': userLocation,
        },
      );

      if (response.data['success'] ==
          true) {
        return response.data;
      } else {
        throw Exception(
          response.data['error'] ??
              'Failed to get AI response',
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
    List<
      dynamic
    >
  >
  getConversationHistory() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.aiConversationHistory,
      );

      if (response.data['success'] ==
          true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['error'] ??
              'Failed to fetch conversation history',
        );
      }
    } on DioException catch (
      e
    ) {
      // Handle 404/Empty properly?
      throw Exception(
        e.response?.data['error'] ??
            'Connection failed',
      );
    }
  }

  Future<
    void
  >
  clearConversationHistory() async {
    try {
      await _apiClient.delete(
        ApiEndpoints.aiConversationHistory,
      );
    } on DioException catch (
      e
    ) {
      throw Exception(
        e.response?.data['error'] ??
            'Connection failed',
      );
    }
  }
}
