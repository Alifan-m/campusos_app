import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'events_models.dart';

class EventsRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<Event>> getEvents({String? category, bool? upcoming}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (upcoming == true) params['upcoming'] = 'true';
    final response = await _dio.get('/events/', queryParameters: params);
    return (response.data as List).map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> getEvent(int id) async {
    final response = await _dio.get('/events/$id/');
    return Event.fromJson(response.data);
  }

  Future<bool> toggleRsvp(int eventId) async {
    final response = await _dio.post('/events/$eventId/rsvp/');
    return response.data['rsvped'] ?? false;
  }
}
