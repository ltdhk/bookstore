import 'package:json_annotation/json_annotation.dart';

part 'book_vo.g.dart';

@JsonSerializable()
class BookVO {
  final int id;
  final String title;
  final String author;
  final String coverUrl;
  final String? description;
  final String? category;
  final String? status;
  final int? views;
  final int? likes;
  final double? rating;
  final String? completionStatus;
  final int? chapterCount;

  BookVO({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.description,
    this.category,
    this.status,
    this.views,
    this.likes,
    this.rating,
    this.completionStatus,
    this.chapterCount,
  });

  factory BookVO.fromJson(Map<String, dynamic> json) => _$BookVOFromJson(json);
  Map<String, dynamic> toJson() => _$BookVOToJson(this);

  BookVO copyWith({
    int? id,
    String? title,
    String? author,
    String? coverUrl,
    String? description,
    String? category,
    String? status,
    int? views,
    int? likes,
    double? rating,
    String? completionStatus,
    int? chapterCount,
  }) {
    return BookVO(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      rating: rating ?? this.rating,
      completionStatus: completionStatus ?? this.completionStatus,
      chapterCount: chapterCount ?? this.chapterCount,
    );
  }
}
