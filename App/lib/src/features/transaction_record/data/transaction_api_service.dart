import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/services/networking/dio_provider.dart';
import 'package:novelpop/src/features/transaction_record/data/models/order.dart';

part 'transaction_api_service.g.dart';

@riverpod
TransactionApiService transactionApiService(Ref ref) {
  return TransactionApiService(ref.watch(dioProvider));
}

class TransactionApiService {
  final Dio _dio;

  TransactionApiService(this._dio);

  /// Get current user's orders (transaction records)
  /// @param page Page number (default 1)
  /// @param size Page size (default 10)
  Future<Map<String, dynamic>> getMyOrders({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/api/orders',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    return response.data['data'] as Map<String, dynamic>;
  }

  /// Get order detail by ID
  /// @param id Order ID
  Future<Order> getOrderById(int id) async {
    final response = await _dio.get('/api/orders/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return Order.fromJson(data);
  }
}
