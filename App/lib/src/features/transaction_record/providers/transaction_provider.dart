import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/transaction_record/data/transaction_api_service.dart';
import 'package:novelpop/src/features/transaction_record/data/models/order.dart';

part 'transaction_provider.g.dart';

/// Provider for transaction records (orders)
@riverpod
class TransactionRecords extends _$TransactionRecords {
  int _currentPage = 1;
  final int _pageSize = 10;
  List<Order> _allOrders = [];
  bool _hasMore = true;

  @override
  Future<List<Order>> build() async {
    _currentPage = 1;
    _allOrders = [];
    _hasMore = true;
    return _fetchOrders();
  }

  Future<List<Order>> _fetchOrders() async {
    final apiService = ref.read(transactionApiServiceProvider);

    try {
      final response = await apiService.getMyOrders(
        page: _currentPage,
        size: _pageSize,
      );

      final records = response['records'] as List;
      final orders = records
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();

      final total = response['total'] as int;
      _hasMore = (_currentPage * _pageSize) < total;

      if (_currentPage == 1) {
        _allOrders = orders;
      } else {
        _allOrders.addAll(orders);
      }

      return List.from(_allOrders);
    } catch (e) {
      rethrow;
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMore() async {
    if (!_hasMore) return;

    _currentPage++;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrders());
  }

  /// Refresh orders
  Future<void> refresh() async {
    _currentPage = 1;
    _allOrders = [];
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrders());
  }

  /// Check if there are more orders to load
  bool get hasMore => _hasMore;
}

/// Provider for getting a single order by ID
@riverpod
Future<Order> orderDetail(Ref ref, int orderId) async {
  final apiService = ref.read(transactionApiServiceProvider);
  return apiService.getOrderById(orderId);
}
