import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthRemoteDataSourceImpl({required this.dio, required this.tokenStorage});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'username': username,
        'password': password,
        // durée de vie du token côté DummyJSON, en secondes
        'expiresInMins': 30,
      });

      final data = response.data as Map<String, dynamic>;

      await tokenStorage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // DummyJSON n'a pas de vrai /auth/register persistant, on utilise
      // /users/add pour simuler la création de compte puis on connecte
      // automatiquement l'utilisateur. Avec ton propre backend, remplace
      // simplement cet appel par POST /auth/register.
      final response = await dio.post('/users/add', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;

      // Auto-login après inscription
      try {
        return await login(username: username, password: password);
      } catch (_) {
        return UserModel.fromJson({
          'id': data['id'],
          'username': username,
          'email': email,
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
        });
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
      return AuthException(
        e.response?.data['message'] ?? 'Identifiants invalides.',
      );
    }
    return ServerException(
      e.message ?? 'Erreur serveur inconnue.',
      statusCode: e.response?.statusCode,
    );
  }
}
