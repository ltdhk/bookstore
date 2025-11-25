import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/common_widgets/scaffold_with_navbar.dart';
import 'package:book_store/src/features/book_details/presentation/book_detail_screen.dart';
import 'package:book_store/src/features/reader/presentation/reader_screen.dart';
import 'package:book_store/src/features/home/presentation/home_screen.dart';
import 'package:book_store/src/features/bookshelf/presentation/bookshelf_screen.dart';
import 'package:book_store/src/features/profile/presentation/profile_screen.dart';
import 'package:book_store/src/features/settings/presentation/settings_page.dart';
import 'package:book_store/src/features/search/presentation/search_screen.dart';
import 'package:book_store/src/features/auth/presentation/login_screen.dart';
import 'package:book_store/src/features/auth/presentation/register_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SearchScreen(),
                  ),
                  GoRoute(
                    path: 'read/:id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ReaderScreen(bookId: id);
                    },
                  ),
                  GoRoute(
                    path: 'book/:id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BookDetailScreen(bookId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'read',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ReaderScreen(bookId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookshelf',
                builder: (context, state) => const BookshelfScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
