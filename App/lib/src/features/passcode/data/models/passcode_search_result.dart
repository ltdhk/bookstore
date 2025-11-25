import 'package:json_annotation/json_annotation.dart';
import 'package:book_store/src/features/home/data/models/book_vo.dart';
import 'passcode_context.dart';

part 'passcode_search_result.g.dart';

@JsonSerializable()
class PasscodeSearchResult {
  final bool valid;
  final int? passcodeId;
  final int? distributorId;
  final int? bookId;
  final BookVO? book;
  final String? message;

  PasscodeSearchResult({
    required this.valid,
    this.passcodeId,
    this.distributorId,
    this.bookId,
    this.book,
    this.message,
  });

  factory PasscodeSearchResult.fromJson(Map<String, dynamic> json) =>
      _$PasscodeSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$PasscodeSearchResultToJson(this);

  /// Convert to PasscodeContext if valid
  PasscodeContext? toContext(String originalPasscode) {
    if (!valid || passcodeId == null || distributorId == null || bookId == null) {
      return null;
    }
    return PasscodeContext(
      passcodeId: passcodeId!,
      distributorId: distributorId!,
      bookId: bookId!,
      passcode: originalPasscode,
    );
  }
}
