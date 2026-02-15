import '../../../../core/network/api_client.dart';

class NavigationService {
  final _apiClient = ApiClient.instance;

  Future<
    Map<
      String,
      dynamic
    >
  >
  optimizeRoute({
    required List<
      String
    >
    products,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.post(
      '/ai/route-optimization',
      data: {
        'products': products,
        'user_location': {
          'latitude': latitude,
          'longitude': longitude,
        },
      },
    );
    return response.data['data'];
  }

  Future<
    Map<
      String,
      dynamic
    >
  >
  chatWithAI({
    required String message,
    required double latitude,
    required double longitude,
    List<
          Map<
            String,
            String
          >
        >
        history =
        const [],
    List<
          String
        >
        products =
        const [], // Optional context
  }) async {
    final response = await _apiClient.post(
      '/ai/chat',
      data: {
        'message': message,
        'user_location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'conversation_history': history,
        'context_products': products,
      },
    );
    return response.data['data'];
  }
}
