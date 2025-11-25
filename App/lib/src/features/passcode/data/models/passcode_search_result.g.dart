// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passcode_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasscodeSearchResult _$PasscodeSearchResultFromJson(
  Map<String, dynamic> json,
) => PasscodeSearchResult(
  valid: json['valid'] as bool,
  passcodeId: (json['passcodeId'] as num?)?.toInt(),
  distributorId: (json['distributorId'] as num?)?.toInt(),
  bookId: (json['bookId'] as num?)?.toInt(),
  book: json['book'] == null
      ? null
      : BookVO.fromJson(json['book'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$PasscodeSearchResultToJson(
  PasscodeSearchResult instance,
) => <String, dynamic>{
  'valid': instance.valid,
  'passcodeId': instance.passcodeId,
  'distributorId': instance.distributorId,
  'bookId': instance.bookId,
  'book': instance.book,
  'message': instance.message,
};
