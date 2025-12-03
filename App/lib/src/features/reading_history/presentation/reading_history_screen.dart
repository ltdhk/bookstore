import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:novelpop/src/features/reading_history/providers/reading_history_provider.dart';
import 'package:intl/intl.dart';

class ReadingHistoryScreen extends ConsumerWidget {
  const ReadingHistoryScreen({super.key});

  String _formatReadingTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return 'Today ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 2) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('MM-dd HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(readingHistoryProvider);

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
          'Reading history',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          historyAsync.maybeWhen(
            data: (history) => history.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      _showClearConfirmDialog(context, ref);
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading history: $error',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reading history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: history.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
            ),
            itemBuilder: (context, index) {
              final item = history[index];
              return _buildHistoryItem(context, ref, item, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    dynamic item,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => context.push('/read/${item.bookId}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: isDark ? const Color(0xFF121212) : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: item.effectiveCoverUrl,
                width: 80,
                height: 110,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                  child: const Icon(Icons.book, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book title
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Reading time
                  Text(
                    'reading time: ${_formatReadingTime(item.lastReadAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Author tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Clear Reading History',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to clear all reading history? This action cannot be undone.',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(readingHistoryProvider.notifier).clearAll();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reading history cleared')),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
