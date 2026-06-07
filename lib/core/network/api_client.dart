import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://campusos-backend-skl7.onrender.com/api'\;

  static Dio get instance {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await SecureStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                '$baseUrl/auth/token/refresh/',
                data: {'refresh': refreshToken},
              );
              final newAccessToken = response.data['access'];
              final newRefreshToken = response.data['refresh'];
              await SecureStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await Dio().fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (e) {
              await SecureStorage.clearAll();
            }
          }
        }
        return handler.next(error);
      },
    ));
    return dio;
  }
}
