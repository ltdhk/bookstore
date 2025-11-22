import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_store/src/features/home/presentation/widgets/home_banner.dart';
import 'package:book_store/src/features/home/data/mock_home_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:book_store/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                8.0,
                16.0,
                4.0,
              ), // Reduced vertical padding
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[400],
                labelStyle: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                dividerColor: Colors.transparent,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.only(right: 24.0),
                tabs: const [
                  Tab(text: 'Hot'),
                  Tab(text: 'New'),
                  Tab(text: 'Free'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  HomeTabContent(category: 'hot'),
                  HomeTabContent(category: 'new'),
                  HomeTabContent(category: 'free'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTabContent extends ConsumerWidget {
  final String category;

  const HomeTabContent({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(homeBooksProvider(category));
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0,
              4.0,
              16.0,
              8.0,
            ), // Reduced top padding
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for novel',
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
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: HomeBanner(),
          ),
        ),
        booksAsync.when(
          data: (books) {
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.65, // Adjusted back to 0.65 to reduce height
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 20.0,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = books[index];
                  return GestureDetector(
                    onTap: () => context.push('/book/${book.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: book.coverUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height:
                              40, // Fixed height for 2 lines of text (15 * 1.3 * 2 ~= 39)
                          child: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.3,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 7,
                              backgroundColor: Color(0xFFE0E0E0),
                              child: Icon(
                                Icons.person,
                                size: 9,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                book.author,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.favorite_border,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '2.3万',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }, childCount: books.length),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) =>
              SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}
