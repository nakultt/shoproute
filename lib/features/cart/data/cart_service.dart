import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants/api_endpoints.dart';

class CartService {
  static final CartService instance = CartService._internal();

  factory CartService() {
    return instance;
  }

  CartService._internal();

  final ApiClient _apiClient = ApiClient.instance;

  // Notifier for the total count of items in the cart
  final ValueNotifier<
    int
  >
  cartCountNotifier =
      ValueNotifier<
        int
      >(
        0,
      );

  Future<
    void
  >
  refreshCartCount() async {
    try {
      final cart = await getCart();
      // Assuming cart['items'] is a list, or cart object has item_count
      // getCart returns Map<String, dynamic> with 'item_count' based on previous view
      if (cart.containsKey(
        'item_count',
      )) {
        cartCountNotifier.value =
            cart['item_count']
                as int;
      } else if (cart.containsKey(
        'items',
      )) {
        cartCountNotifier.value =
            (cart['items']
                    as List)
                .length;
      }
    } catch (
      e
    ) {
      debugPrint(
        "Failed to refresh cart count: $e",
      );
    }
  }

  Future<
    Map<
      String,
      dynamic
    >
  >
  getCart() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.cart,
      );

      if (response.data['success'] ==
          true) {
        final data = response.data['data'];
        // Update notifier on fetch
        if (data
            is Map<
              String,
              dynamic
            >) {
          if (data.containsKey(
            'item_count',
          )) {
            cartCountNotifier.value =
                data['item_count']
                    as int;
          } else if (data.containsKey(
            'items',
          )) {
            cartCountNotifier.value =
                (data['items']
                        as List)
                    .length;
          }
        }
        return data;
      } else {
        throw Exception(
          response.data['error'] ??
              'Failed to fetch cart',
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
  addToCart({
    required int productId,
    required int storeId,
    int quantity = 1,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.cart}/add',
        data: {
          'product_id': productId,
          'store_id': storeId,
          'quantity': quantity,
        },
      );

      if (response.data['success'] !=
          true) {
        throw Exception(
          response.data['error'] ??
              'Failed to add to cart',
        );
      }
      refreshCartCount();
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
  updateQuantity(
    int itemId,
    int quantity,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.cart}/update/$itemId',
        data: {
          'quantity': quantity,
        },
      );

      if (response.data['success'] !=
          true) {
        throw Exception(
          response.data['error'] ??
              'Failed to update cart',
        );
      }
      refreshCartCount(); // Quantity change might not change item count, but good to sync
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
  removeItem(
    int itemId,
  ) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.cart}/remove/$itemId',
      );

      if (response.data['success'] !=
          true) {
        throw Exception(
          response.data['error'] ??
              'Failed to remove from cart',
        );
      }
      refreshCartCount();
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
  clearCart() async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.cart}/clear',
      );

      if (response.data['success'] !=
          true) {
        throw Exception(
          response.data['error'] ??
              'Failed to clear cart',
        );
      }
      cartCountNotifier.value = 0;
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
