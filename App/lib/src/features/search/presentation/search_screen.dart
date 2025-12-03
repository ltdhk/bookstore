import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:novelpop/src/features/home/providers/book_provider.dart';
import 'package:novelpop/src/features/home/data/book_api_service.dart';
import 'package:novelpop/src/features/home/data/models/book_vo.dart';
import 'package:novelpop/src/features/passcode/utils/passcode_detector.dart';
import 'package:novelpop/src/features/passcode/data/passcode_api_service.dart';
import 'package:novelpop/src/features/passcode/data/models/passcode_search_result.dart';
import 'package:novelpop/src/features/passcode/providers/passcode_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchHistory = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // Passcode search state
  bool _isPasscodeSearch = false;
  bool _isPasscodeLoading = false;
  PasscodeSearchResult? _passcodeResult;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() {
      _searchHistory = [];
    });
  }

  void _addToSearchHistory(String query) {
    if (query.isEmpty) return;

    setState(() {
      // Remove if already exists
      _searchHistory.remove(query);
      // Add to beginning
      _searchHistory.insert(0, query);
      // Keep only last 10
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    _saveSearchHistory();
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    // Check if input is a passcode
    if (PasscodeDetector.isPasscode(query)) {
      _performPasscodeSearch(query);
    } else {
      // Normal keyword search
      _addToSearchHistory(query);
      setState(() {
        _isSearching = true;
        _isPasscodeSearch = false;
        _passcodeResult = null;
        _searchQuery = query;
      });
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _performPasscodeSearch(String passcode) async {
    setState(() {
      _isSearching = true;
      _isPasscodeSearch = true;
      _isPasscodeLoading = true;
      _passcodeResult = null;
    });
    _searchFocusNode.unfocus();

    try {
      final apiService = ref.read(passcodeApiServiceProvider);
      final result = await apiService.searchByPasscode(
        PasscodeDetector.normalize(passcode),
      );

      if (mounted) {
        setState(() {
          _passcodeResult = result;
          _isPasscodeLoading = false;
        });

        // Save passcode context for tracking if valid
        if (result.valid && result.book != null) {
          final context = result.toContext(PasscodeDetector.normalize(passcode));
          if (context != null) {
            ref.read(activePasscodeContextProvider.notifier).setContext(context);

            // Track 'use' action - passcode validated/used
            try {
              final prefs = await SharedPreferences.getInstance();
              final userIdStr = prefs.getString('user_id');
              final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
              await apiService.trackUse(passcodeId: context.passcodeId, userId: userId);
              debugPrint('Passcode use action tracked: ${context.passcodeId}, userId: $userId');
            } catch (e) {
              debugPrint('Failed to track passcode use: $e');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passcodeResult = PasscodeSearchResult(
            valid: false,
            message: 'Failed to validate passcode: $e',
          );
          _isPasscodeLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _isPasscodeSearch = false;
      _isPasscodeLoading = false;
      _passcodeResult = null;
      _searchQuery = '';
    });
  }

  Future<void> _likeBook(int bookId) async {
    try {
      // Update local state immediately for instant UI feedback
      ref.read(searchResultsProvider(_searchQuery).notifier).updateBookLikes(bookId);

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final popularBooks = ref.watch(booksByCategoryProvider('hot'));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true,
                        onSubmitted: _performSearch,
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
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isSearching
                  ? (_isPasscodeSearch
                      ? _buildPasscodeResults(isDark)
                      : _buildSearchResults(isDark))
                  : _buildInitialScreen(isDark, popularBooks),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialScreen(bool isDark, AsyncValue booksAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search history
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search History',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onPressed: _clearSearchHistory,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _searchHistory.map((query) {
                return InkWell(
                  onTap: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      query,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Popular stories
          Text(
            'Most Popular Stories',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          booksAsync.when(
            data: (books) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: books.length > 5 ? 5 : books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return InkWell(
                    onTap: () => context.push('/read/${book.id}'),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          // Rank badge
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: index == 0
                                    ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                    : index == 1
                                        ? [const Color(0xFFC0C0C0), const Color(0xFF808080)]
                                        : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Book cover
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: CachedNetworkImage(
                              imageUrl: book.effectiveCoverUrl,
                              width: 80,
                              height: 110,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book, size: 24, color: Colors.grey),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Book info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    _buildTag('Romance', isDark),
                                    _buildTag('Magic', isDark),
                                  ],
                                ),
                              ],
                            ),
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
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    final searchState = ref.watch(searchResultsProvider(_searchQuery));

    if (searchState.isLoading && searchState.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.error != null && searchState.books.isEmpty) {
      return Center(child: Text('Error: ${searchState.error}'));
    }

    final filteredBooks = searchState.books;

    if (filteredBooks.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        final book = filteredBooks[index];
        return GestureDetector(
          onTap: () => context.push('/read/${book.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: book.effectiveCoverUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Book title
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              // Author and likes in one row
              Row(
                children: [
                  CircleAvatar(
                    radius: 7,
                    backgroundColor: isDark
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFE0E0E0),
                    child: Icon(
                      Icons.person,
                      size: 9,
                      color: isDark ? Colors.grey[400] : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      book.author,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _likeBook(book.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatLikes(book.likes ?? 0),
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
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
      },
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[700],
          fontSize: 12,
        ),
      ),
    );
  }

  /// Build passcode search results
  Widget _buildPasscodeResults(bool isDark) {
    if (_isPasscodeLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_passcodeResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_passcodeResult!.valid || _passcodeResult!.book == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                _passcodeResult!.message ?? 'Invalid or expired passcode',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Please check your passcode and try again',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final book = _passcodeResult!.book!;
    return _buildPasscodeBookCard(book, isDark);
  }

  /// Build passcode book card with success indicator
  Widget _buildPasscodeBookCard(BookVO book, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Passcode success indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF4CAF50)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
                SizedBox(width: 10),
                Text(
                  'Passcode Valid',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Book card - tap to read
          GestureDetector(
            onTap: () => _openBookWithPasscode(book),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Book cover
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: book.effectiveCoverUrl,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 280,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 280,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 48),
                      ),
                    ),
                  ),
                  // Book info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.author,
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (book.description != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            book.description!,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Read button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _openBookWithPasscode(book),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Start Reading',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Open book with passcode tracking
  void _openBookWithPasscode(BookVO book) {
    // Navigate to reader - tracking will be done in ReaderScreen
    context.push('/read/${book.id}');
  }
}
