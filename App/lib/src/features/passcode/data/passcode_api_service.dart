import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/services/networking/dio_provider.dart';
import 'package:novelpop/src/features/passcode/data/models/passcode_search_result.dart';

part 'passcode_api_service.g.dart';

@riverpod
PasscodeApiService passcodeApiService(Ref ref) {
  return PasscodeApiService(ref.watch(dioProvider));
}

class PasscodeApiService {
  final Dio _dio;

  PasscodeApiService(this._dio);

  /// Search book by passcode only
  Future<PasscodeSearchResult> searchByPasscode(String passcode) async {
    final response = await _dio.post(
      '/api/v1/passcodes/search',
      data: {'passcode': passcode},
    );
    return PasscodeSearchResult.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  /// Track passcode action
  /// actionType: 'use' - passcode validated, 'open' - book opened, 'sub' - subscription
  Future<void> trackAction({
    required int passcodeId,
    required String actionType,
    int? userId,
  }) async {
    await _dio.post(
      '/api/v1/passcodes/track',
      data: {
        'passcodeId': passcodeId,
        'actionType': actionType,
        if (userId != null) 'userId': userId,
      },
    );
  }

  /// Track 'use' action - when passcode is validated
  Future<void> trackUse({required int passcodeId, int? userId}) async {
    await trackAction(passcodeId: passcodeId, actionType: 'use', userId: userId);
  }

  /// Track 'open' action - when book is opened for reading
  Future<void> trackOpen({required int passcodeId, int? userId}) async {
    await trackAction(passcodeId: passcodeId, actionType: 'open', userId: userId);
  }

  /// Track 'sub' action - when user subscribes via passcode book
  Future<void> trackSubscription({required int passcodeId, int? userId}) async {
    await trackAction(passcodeId: passcodeId, actionType: 'sub', userId: userId);
  }

  /// @deprecated Use trackAction instead
  /// Use passcode to open a book (increment usedCount and viewCount)
  Future<void> usePasscode({
    required String passcode,
    required int bookId,
    int? userId,
  }) async {
    await _dio.post(
      '/api/v1/passcodes/use',
      data: {
        'passcode': passcode,
        'bookId': bookId,
        if (userId != null) 'userId': userId,
      },
    );
  }
}
