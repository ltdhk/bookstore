import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_store/src/features/bookshelf/data/bookshelf_local_storage.dart';
import 'package:book_store/src/features/bookshelf/providers/bookshelf_provider.dart';
import 'package:book_store/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class BookshelfScreen extends ConsumerStatefulWidget {
  const BookshelfScreen({super.key});

  @override
  ConsumerState<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends ConsumerState<BookshelfScreen> {
  bool _isEditMode = false;
  final Set<String> _selectedBooks = {};

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedBooks.clear();
      }
    });
  }

  void _toggleBookSelection(String bookId) {
    setState(() {
      if (_selectedBooks.contains(bookId)) {
        _selectedBooks.remove(bookId);
      } else {
        _selectedBooks.add(bookId);
      }
    });
  }

  Future<void> _deleteSelectedBooks() async {
    if (_selectedBooks.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Books'),
        content: Text('Delete ${_selectedBooks.length} book(s) from your bookshelf?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Delete books from local storage
        await ref
            .read(bookshelfProvider.notifier)
            .removeBooks(_selectedBooks.toList());

        setState(() {
          _selectedBooks.clear();
          _isEditMode = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Books removed from bookshelf'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing books: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final booksAsync = ref.watch(bookshelfProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.bookshelf,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: AbsorbPointer(
                  child: TextField(
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.grey[400] : Colors.black87,
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Header with edit button
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My bookshelf',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: _toggleEditMode,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _isEditMode ? 'cancel' : 'Edit',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Book grid
          Expanded(
            child: booksAsync.when(
              data: (books) {
                if (books.isEmpty && !_isEditMode) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No books in your bookshelf',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Browse books'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 20.0,
                  ),
                  itemCount: _isEditMode ? books.length : books.length + 1,
                  itemBuilder: (context, index) {
                    if (!_isEditMode && index == books.length) {
                      return _buildAddBookItem();
                    }
                    final book = books[index];
                    return _buildBookItem(book, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),

          // Delete button (shown in edit mode)
          if (_isEditMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _selectedBooks.isEmpty ? null : _deleteSelectedBooks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFF5F5F5),
                  foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                  disabledBackgroundColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFE0E0E0),
                  disabledForegroundColor: Colors.grey[500],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookItem(BookshelfItem book, bool isDark) {
    final isSelected = _selectedBooks.contains(book.id);

    return GestureDetector(
      onTap: _isEditMode
          ? () => _toggleBookSelection(book.id)
          : () => context.push('/read/${book.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    imageUrl: book.effectiveCoverUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.menu_book,
                          size: 48,
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isEditMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.blue
                            : Colors.white.withValues(alpha: 0.9),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBookItem() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Navigate to home page (index 0 in bottom navigation)
        context.go('/');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area with same aspect ratio as book covers
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Empty space to align with book titles
          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }
}
