import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login/', data: {
        'phone_number': phoneNumber,
        'password': password,
      });
      final tokens = AuthTokens.fromJson(response.data['tokens']);
      await SecureStorage.saveTokens(
        accessToken: tokens.access,
        refreshToken: tokens.refresh,
      );
      return {'success': true, 'user': response.data['user']};
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final error = e.response?.data?['error'] ?? 'Something went wrong.';
      if (statusCode == 403) {
        return {'success': false, 'pending': true, 'error': error};
      }
      return {'success': false, 'pending': false, 'error': error};
    }
  }

  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String fullName,
    required String studentId,
    required String course,
    required int yearOfStudy,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register/', data: {
        'phone_number': phoneNumber,
        'full_name': fullName,
        'student_id': studentId,
        'course': course,
        'year_of_study': yearOfStudy,
        'password': password,
      });
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      final errors = e.response?.data;
      String message = 'Registration failed.';
      if (errors is Map) {
        final first = errors.values.first;
        message = first is List ? first.first.toString() : first.toString();
      }
      return {'success': false, 'error': message};
    }
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me/');
    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
  }
}
