import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_store/src/features/home/providers/advertisements_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeBanner extends ConsumerWidget {
  const HomeBanner({super.key});

  void _handleBannerTap(BuildContext context, String targetType, int? targetId, String? targetUrl) {
    switch (targetType) {
      case 'book':
        if (targetId != null) {
          context.push('/read/$targetId');
        }
        break;
      case 'url':
        if (targetUrl != null && targetUrl.isNotEmpty) {
          _launchURL(targetUrl);
        }
        break;
      case 'none':
      default:
        // Do nothing
        break;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advertisementsAsync = ref.watch(homeBannerAdvertisementsProvider);

    return advertisementsAsync.when(
      data: (advertisements) {
        if (advertisements.isEmpty) {
          return const SizedBox.shrink();
        }

        return CarouselSlider(
          options: CarouselOptions(
            height: 150.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: false,
            aspectRatio: 2.5,
            viewportFraction: 1.0,
          ),
          items: advertisements.map((ad) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => _handleBannerTap(
                    context,
                    ad.targetType,
                    ad.targetId,
                    ad.targetUrl,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: ad.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
      loading: () => Container(
        height: 150.0,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) {
        debugPrint('Error loading advertisements: $err');
        return const SizedBox.shrink();
      },
    );
  }
}
