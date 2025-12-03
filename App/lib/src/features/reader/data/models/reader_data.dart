import 'package:novelpop/src/features/home/data/models/book_vo.dart';
import 'package:novelpop/src/features/reader/data/models/chapter_vo.dart';

/// Combined data for reader page - reduces multiple API calls to one
class ReaderData {
  final BookVO book;
  final List<ChapterVO> chapters;
  final bool hasValidSubscription;

  ReaderData({
    required this.book,
    required this.chapters,
    this.hasValidSubscription = false,
  });

  factory ReaderData.fromJson(Map<String, dynamic> json) {
    return ReaderData(
      book: BookVO.fromJson(json['book'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List)
          .map((e) => ChapterVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasValidSubscription: json['hasValidSubscription'] as bool? ?? false,
    );
  }
}
