// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterVO _$ChapterVOFromJson(Map<String, dynamic> json) => ChapterVO(
  id: (json['id'] as num).toInt(),
  bookId: (json['bookId'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String?,
  orderNum: (json['orderNum'] as num).toInt(),
  isFree: json['isFree'] as bool,
  canAccess: json['canAccess'] as bool?,
);

Map<String, dynamic> _$ChapterVOToJson(ChapterVO instance) => <String, dynamic>{
  'id': instance.id,
  'bookId': instance.bookId,
  'title': instance.title,
  'content': instance.content,
  'orderNum': instance.orderNum,
  'isFree': instance.isFree,
  'canAccess': instance.canAccess,
};
