import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelpop/src/features/home/presentation/widgets/home_banner.dart';
import 'package:novelpop/src/features/home/providers/books_pagination_provider.dart';
import 'package:novelpop/src/features/home/providers/advertisements_provider.dart';
import 'package:novelpop/src/features/home/data/models/book_vo.dart';
import 'package:novelpop/src/features/home/data/book_api_service.dart';
import 'package:novelpop/src/features/settings/data/locale_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:novelpop/l10n/app_localizations.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: const ValueKey(
        'home_screen_4_tabs',
      ), // Force rebuild with new tab count
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
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
                key: const ValueKey('tab_bar_4_tabs'), // Force rebuild
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
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
                tabs: [
                  Tab(text: l10n.hot),
                  Tab(text: l10n.newTab),
                  Tab(text: l10n.male),
                  Tab(text: l10n.female),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                key: const ValueKey('tab_bar_view_4_tabs'), // Force rebuild
                controller: _tabController,
                children: const [
                  HomeTabContent(category: 'hot'),
                  HomeTabContent(category: 'new'),
                  HomeTabContent(category: 'male'),
                  HomeTabContent(category: 'female'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTabContent extends ConsumerStatefulWidget {
  final String category;

  const HomeTabContent({super.key, required this.category});

  @override
  ConsumerState<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends ConsumerState<HomeTabContent>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app resumes from background, retry if books are empty and there was an error
    if (state == AppLifecycleState.resumed) {
      final paginationState = ref.read(booksPaginationProvider(widget.category));
      if (paginationState.books.isEmpty && paginationState.error != null) {
        ref.read(booksPaginationProvider(widget.category).notifier).refresh();
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when scrolled to 90%
      if (mounted) {
        ref
            .read(booksPaginationProvider(widget.category).notifier)
            .loadNextPage();
      }
    }
  }

  Future<void> _onRefresh() async {
    // Refresh both books and advertisements
    ref.invalidate(homeBannerAdvertisementsProvider);
    await ref.read(booksPaginationProvider(widget.category).notifier).refresh();
  }

  void _handleLikeBook(BuildContext context, WidgetRef ref, BookVO book) {
    // Allow liking without login
    _likeBook(book.id);
  }

  Future<void> _likeBook(int bookId) async {
    try {
      // Update local state immediately for instant UI feedback
      ref
          .read(booksPaginationProvider(widget.category).notifier)
          .updateBookLikes(bookId);

      // Call API to like book on backend
      final bookService = ref.read(bookApiServiceProvider);
      await bookService.likeBook(bookId);
    } catch (e) {
      // If API call fails, could implement revert logic here if needed
      debugPrint('Error liking book: $e');
    }
  }

  String _formatLikes(int likes) {
    if (likes >= 10000) {
      return '${(likes / 10000).toStringAsFixed(1)}万';
    }
    return likes.toString();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final paginationState = ref.watch(booksPaginationProvider(widget.category));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for locale changes and refresh books
    ref.listen(localeControllerProvider, (previous, next) {
      final prevLang = previous?.value?.languageCode;
      final nextLang = next.value?.languageCode;
      if (prevLang != null && nextLang != null && prevLang != nextLang) {
        ref.read(booksPaginationProvider(widget.category).notifier).refresh(forceLanguage: nextLang);
      }
    });

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
              child: GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: AbsorbPointer(
                    child: TextField(
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for novel',
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Banner
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: HomeBanner(),
            ),
          ),
          // Books grid
          if (paginationState.books.isEmpty && paginationState.isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (paginationState.books.isEmpty && !paginationState.isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: paginationState.error != null
                      ? _NetworkErrorRetryWidget(
                          onRetry: _onRefresh,
                          category: widget.category,
                        )
                      : const Text('No books found'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 20.0,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = paginationState.books[index];
                  return GestureDetector(
                    onTap: () => context.push('/read/${book.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: CachedNetworkImage(
                              imageUrl: book.effectiveCoverUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.book,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          child: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.3,
                              color: isDark ? Colors.white : Colors.black87,
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
                            GestureDetector(
                              onTap: () => _handleLikeBook(context, ref, book),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 12,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatLikes(book.likes ?? 0),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }, childCount: paginationState.books.length),
              ),
            ),
          // Loading indicator at bottom
          if (paginationState.isLoading && paginationState.books.isNotEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          // End message
          if (!paginationState.hasMore && paginationState.books.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No more books',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

/// Widget that auto-retries after network permission is granted
class _NetworkErrorRetryWidget extends StatefulWidget {
  final Future<void> Function() onRetry;
  final String category;

  const _NetworkErrorRetryWidget({
    required this.onRetry,
    required this.category,
  });

  @override
  State<_NetworkErrorRetryWidget> createState() => _NetworkErrorRetryWidgetState();
}

class _NetworkErrorRetryWidgetState extends State<_NetworkErrorRetryWidget> {
  bool _hasAutoRetried = false;

  @override
  void initState() {
    super.initState();
    // Auto retry after 2 seconds (gives time for network permission to be granted)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasAutoRetried) {
        _hasAutoRetried = true;
        widget.onRetry();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Network error, please check your connection',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: widget.onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
