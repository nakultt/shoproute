import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../config/constants/api_endpoints.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<dynamic>> getProducts({
    String? search,
    int? categoryId,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParameters: {
          if (search != null) 'search': search,
          if (categoryId != null) 'category': categoryId,
          'page': page,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data']['items'];
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch products');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Connection failed');
    }
  }

  Future<Map<String, dynamic>> getProductDetails(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productById(id));

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['error'] ?? 'Failed to fetch product details',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Connection failed');
    }
  }
}
