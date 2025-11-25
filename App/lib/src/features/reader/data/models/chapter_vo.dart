import 'package:json_annotation/json_annotation.dart';

part 'chapter_vo.g.dart';

@JsonSerializable()
class ChapterVO {
  final int id;
  final int bookId;
  final String title;
  final String? content;
  final int orderNum;
  final bool isFree;
  final bool? canAccess;

  ChapterVO({
    required this.id,
    required this.bookId,
    required this.title,
    this.content,
    required this.orderNum,
    required this.isFree,
    this.canAccess,
  });

  factory ChapterVO.fromJson(Map<String, dynamic> json) => _$ChapterVOFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterVOToJson(this);
}
