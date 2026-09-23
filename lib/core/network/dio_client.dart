import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

class DioClient {
  static const String baseUrl = 'https://dummyjson.com';

  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(tokenStorage: tokenStorage, baseUrl: baseUrl),
    );

    // Log utile en dev — à retirer/adapter en prod
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );

    return dio;
  }
}
