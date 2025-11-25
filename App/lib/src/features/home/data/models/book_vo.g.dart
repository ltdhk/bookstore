// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookVO _$BookVOFromJson(Map<String, dynamic> json) => BookVO(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  author: json['author'] as String,
  coverUrl: json['coverUrl'] as String,
  description: json['description'] as String?,
  category: json['category'] as String?,
  status: json['status'] as String?,
  views: (json['views'] as num?)?.toInt(),
  likes: (json['likes'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  completionStatus: json['completionStatus'] as String?,
  chapterCount: (json['chapterCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$BookVOToJson(BookVO instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author,
  'coverUrl': instance.coverUrl,
  'description': instance.description,
  'category': instance.category,
  'status': instance.status,
  'views': instance.views,
  'likes': instance.likes,
  'rating': instance.rating,
  'completionStatus': instance.completionStatus,
  'chapterCount': instance.chapterCount,
};
