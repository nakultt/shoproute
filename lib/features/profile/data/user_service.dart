import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants/api_endpoints.dart';

class UserService {
  final ApiClient _apiClient = ApiClient.instance;

  // Favorites
  Future<
    List<
      dynamic
    >
  >
  getFavorites(
    String type,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.favorites}/$type',
      );

      if (response.data['success'] ==
          true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['error'] ??
              'Failed to fetch favorites',
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
  toggleFavorite(
    String type,
    int id,
  ) async {
    try {
      // First try to add
      final response = await _apiClient.post(
        ApiEndpoints.favorites,
        data: {
          'item_type':
              type ==
                  'products'
              ? 'product'
              : 'store',
          'item_id': id,
        },
      );

      if (response.data['success'] ==
          true) {
        final data = response.data['data'];
        // If message is "Already favorited", it implies we might want to remove it
        // BUT the backend returns the object if created.
        // Let's check: implementation plan says "Toggle".
        // The backend `POST` does `ON CONFLICT DO NOTHING`.
        // So if it returns "Already favorited" (or similar structure), we should DELETE.

        // Wait, looking at user.ts:
        // res.status(201).json({ success: true, data: result.rows[0] || { message: "Already favorited" } });

        if (data['message'] ==
            'Already favorited') {
          return await _removeFavorite(
            type,
            id,
          );
        }
        return true; // Added
      }
      return false;
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
  _removeFavorite(
    String type,
    int id,
  ) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.deleteFavorite(
          type,
          id,
        ),
      );
      return response.data['success'] ==
              true
          ? false
          : true; // request removed -> return false (not favorited)
    } on DioException {
      return true; // Failed to remove, still favorited
    }
  }
}
