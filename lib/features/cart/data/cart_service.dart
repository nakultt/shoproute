import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants/api_endpoints.dart';

class CartService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cart);

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch cart');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Connection failed');
    }
  }

  Future<void> addToCart({
    required int productId,
    required int storeId,
    int quantity = 1,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.cart}/add', // Assuming base is /api/cart, verify ApiEndpoints
        data: {
          'product_id': productId,
          'store_id': storeId,
          'quantity': quantity,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to add to cart');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Connection failed');
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.cart}/update/$itemId',
        data: {'quantity': quantity},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to update cart');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Connection failed');
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.cart}/remove/$itemId',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to remove from cart');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Connection failed');
    }
  }

  Future<void> clearCart() async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.cart}/clear');

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to clear cart');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Connection failed');
    }
  }
}
