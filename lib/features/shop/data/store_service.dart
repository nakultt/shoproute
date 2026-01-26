import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants/api_endpoints.dart';

class StoreService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<
    List<
      dynamic
    >
  >
  getNearbyStores({
    required double lat,
    required double lng,
    double radius = 5000,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.nearbyStores,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
      );

      if (response.data['success'] ==
          true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['error'] ??
              'Failed to fetch stores',
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
  getStoreDetails(
    int id, {
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.storeById(
          id,
        ),
        queryParameters:
            lat !=
                    null &&
                lng !=
                    null
            ? {
                'lat': lat,
                'lng': lng,
              }
            : null,
      );

      if (response.data['success'] ==
          true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['error'] ??
              'Failed to fetch store details',
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
}
