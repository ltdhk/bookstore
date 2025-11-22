import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hive_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> hiveInit(Ref ref) async {
  await Hive.initFlutter();
  // Register adapters here
}

@riverpod
Box<dynamic> appBox(Ref ref) {
  throw UnimplementedError('AppBox not initialized');
}
