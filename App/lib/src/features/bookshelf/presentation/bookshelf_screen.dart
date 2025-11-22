import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_store/src/features/home/data/mock_home_repository.dart';
import 'package:book_store/l10n/app_localizations.dart';

class BookshelfScreen extends ConsumerWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Reuse mock data for now
    final booksAsync = ref.watch(homeBooksProvider('shelf'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.bookshelf,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,

        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black87,
                    size: 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  isDense: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My bookshelf', // TODO: Use l10n
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  label: const Text(
                    'Edit', // TODO: Use l10n
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: booksAsync.when(
              data: (books) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio:
                        0.55, // Taller aspect ratio to match Home screen style
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 24.0,
                  ),
                  itemCount: books.length + 1,
                  itemBuilder: (context, index) {
                    if (index == books.length) {
                      return _buildAddBookItem(context);
                    }
                    final book = books[index];
                    return _buildBookItem(context, book);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: book.coverUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 32, // Fixed height for 2 lines (13 * 1.2 * 2 ~= 31.2)
          child: Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddBookItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Add book',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
