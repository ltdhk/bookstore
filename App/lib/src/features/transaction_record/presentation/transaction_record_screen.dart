import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_store/src/features/transaction_record/providers/transaction_provider.dart';
import 'package:book_store/src/features/transaction_record/data/models/order.dart';
import 'package:book_store/src/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class TransactionRecordScreen extends ConsumerStatefulWidget {
  const TransactionRecordScreen({super.key});

  @override
  ConsumerState<TransactionRecordScreen> createState() => _TransactionRecordScreenState();
}

class _TransactionRecordScreenState extends ConsumerState<TransactionRecordScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when scrolled to 90%
      final provider = ref.read(transactionRecordsProvider.notifier);
      if (provider.hasMore) {
        provider.loadMore();
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Transaction Record',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildEmptyState(context, isDark, 'Error loading user info'),
        data: (user) {
          if (user == null) {
            // User not logged in
            return _buildEmptyState(context, isDark, 'Please log in to view transaction records');
          }

          // User is logged in, show transaction records
          final transactionsAsync = ref.watch(transactionRecordsProvider);

          return transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading transactions: $error',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(transactionRecordsProvider.notifier).refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return _buildEmptyState(context, isDark, 'No transaction records yet');
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(transactionRecordsProvider.notifier).refresh();
                },
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemCount: orders.length + 1, // +1 for loading indicator
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == orders.length) {
                      // Show loading indicator at bottom if there are more items
                      final hasMore = ref.read(transactionRecordsProvider.notifier).hasMore;
                      if (hasMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final order = orders[index];
                    return _buildOrderItem(context, order, isDark);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order number and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Order ${order.orderNo}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(order.status),
                    width: 1,
                  ),
                ),
                child: Text(
                  order.statusDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subscription period
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                order.subscriptionPeriodDisplay,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Amount
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                '\$${order.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                order.platform,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Create time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(order.createTime),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),

          // Subscription dates (if applicable)
          if (order.subscriptionStartDate != null && order.subscriptionEndDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('yyyy-MM-dd').format(order.subscriptionStartDate!),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'End Date',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('yyyy-MM-dd').format(order.subscriptionEndDate!),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
