import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'map_models.dart';

class MapRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<MapLocation>> getLocations({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    final response = await _dio.get('/map/', queryParameters: params);
    return (response.data as List)
        .map((e) => MapLocation.fromJson(e))
        .toList();
  }
}
