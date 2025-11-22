import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_store/src/features/home/data/mock_home_repository.dart';

class HomeBanner extends ConsumerWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(homeBannersProvider);

    return bannersAsync.when(
      data: (banners) {
        return CarouselSlider(
          options: CarouselOptions(
            height: 150.0, // Reduced height to match typical banner proportions
            autoPlay: true,
            enlargeCenterPage: false,
            aspectRatio: 2.5, // Wider aspect ratio
            viewportFraction: 1.0,
          ),
          items: banners.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  // margin removed as parent handles padding
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(i),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
