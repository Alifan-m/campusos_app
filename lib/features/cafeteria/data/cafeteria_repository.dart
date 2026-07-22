import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'cafeteria_models.dart';

class CafeteriaRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<MenuCategory>> getCategories() async {
    final response = await _dio.get('/cafeteria/categories/');
    return (response.data as List)
        .map((e) => MenuCategory.fromJson(e))
        .toList();
  }

  Future<List<MenuItem>> getMenuItems({int? categoryId}) async {
    final params = categoryId != null ? {'category': categoryId} : null;
    final response = await _dio.get('/cafeteria/menu/', queryParameters: params);
    return (response.data as List).map((e) => MenuItem.fromJson(e)).toList();
  }

  Future<Order> createOrder(List<CartItem> items) async {
    final orderItems = items
        .map((ci) => {'menu_item': ci.item.id, 'quantity': ci.quantity})
        .toList();
    final response = await _dio.post('/cafeteria/orders/', data: {
      'items': orderItems,
    });
    return Order.fromJson(response.data);
  }

  Future<Order> getOrderStatus(int orderId) async {
    final response = await _dio.get('/cafeteria/orders/$orderId/');
    return Order.fromJson(response.data);
  }

  Future<List<Order>> getOrderHistory() async {
    final response = await _dio.get('/cafeteria/orders/history/');
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> initiateMpesa({
    required int orderId,
    required String phoneNumber,
  }) async {
    final response = await _dio.post('/payments/mpesa/initiate/', data: {
      'order_id': orderId,
      'phone_number': phoneNumber,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getMpesaStatus(String checkoutRequestId) async {
    final response =
        await _dio.get('/payments/mpesa/status/$checkoutRequestId/');
    return response.data;
  }
}
