import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:book_store/src/features/home/data/mock_home_repository.dart';

class BookListSection extends ConsumerWidget {
  final String title;
  final String category;

  const BookListSection({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(homeBooksProvider(category));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: booksAsync.when(
            data: (books) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return GestureDetector(
                    onTap: () => context.go('/book/${book.id}'),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: book.coverUrl,
                              height: 160,
                              width: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
