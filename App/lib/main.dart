import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelpop/src/app.dart';
import 'package:novelpop/src/features/bookshelf/data/bookshelf_local_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 统一设置状态栏样式，避免页面切换时闪烁
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await Hive.initFlutter();

  // Pre-initialize bookshelf storage
  final bookshelfStorage = BookshelfLocalStorage();
  await bookshelfStorage.init();

  runApp(
    ProviderScope(
      overrides: [
        bookshelfLocalStorageProvider.overrideWithValue(AsyncData(bookshelfStorage)),
      ],
      child: const MyApp(),
    ),
  );
}
