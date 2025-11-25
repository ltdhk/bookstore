import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/features/home/data/advertisement_api_service.dart';
import 'package:book_store/src/features/home/data/models/advertisement.dart';

part 'advertisements_provider.g.dart';

/// Provider for home banner advertisements
@riverpod
Future<List<Advertisement>> homeBannerAdvertisements(Ref ref) async {
  final service = ref.watch(advertisementApiServiceProvider);
  return service.getAdvertisements(position: 'home_banner');
}
