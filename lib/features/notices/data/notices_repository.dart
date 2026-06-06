import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'notices_models.dart';

class NoticesRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<Notice>> getNotices({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    final response = await _dio.get('/notices/', queryParameters: params);
    return (response.data as List).map((e) => Notice.fromJson(e)).toList();
  }

  Future<Notice> getNotice(int id) async {
    final response = await _dio.get('/notices/$id/');
    return Notice.fromJson(response.data);
  }
}
