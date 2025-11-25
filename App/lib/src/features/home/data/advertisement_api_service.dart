import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/services/networking/dio_provider.dart';
import 'package:book_store/src/features/home/data/models/advertisement.dart';

part 'advertisement_api_service.g.dart';

@riverpod
AdvertisementApiService advertisementApiService(Ref ref) {
  return AdvertisementApiService(ref.watch(dioProvider));
}

class AdvertisementApiService {
  final Dio _dio;

  AdvertisementApiService(this._dio);

  /// Get active advertisements
  /// @param position Optional position filter (e.g., "home_banner")
  Future<List<Advertisement>> getAdvertisements({String? position}) async {
    try {
      final response = await _dio.get(
        '/api/advertisements',
        queryParameters: position != null ? {'position': position} : null,
      );

      // Handle different response structures
      if (response.data == null) {
        return [];
      }

      // Check if response.data is the array directly or nested in 'data' field
      final dynamic dataField = response.data is Map ? response.data['data'] : response.data;

      if (dataField == null) {
        return [];
      }

      if (dataField is! List) {
        throw Exception('Expected List but got ${dataField.runtimeType}');
      }

      return dataField
          .map((json) => Advertisement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Log the error and return empty list to prevent UI crashes
      debugPrint('Error fetching advertisements: $e');
      return [];
    }
  }
}
