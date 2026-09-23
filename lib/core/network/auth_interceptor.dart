import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Intercepteur Dio à deux responsabilités :
/// 1. Injecter automatiquement `Authorization: Bearer <token>` sur chaque requête.
/// 2. Si le serveur répond 401 (token expiré), tenter un refresh silencieux
///    puis rejouer la requête originale. Si le refresh échoue aussi,
///    on efface la session — l'UI redirige alors vers /login.
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio _refreshDio; // instance Dio "nue", sans intercepteur, pour éviter la boucle infinie
  final String baseUrl;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.tokenStorage,
    required this.baseUrl,
  }) : _refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains('/auth/refresh');

    if (isUnauthorized && !isRefreshCall && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _tryRefreshToken();
        _isRefreshing = false;

        if (refreshed) {
          // On rejoue la requête d'origine avec le nouveau token
          final newToken = await tokenStorage.accessToken;
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';

          final cloneReq = await _refreshDio.fetch(retryOptions);
          return handler.resolve(cloneReq);
        } else {
          await tokenStorage.clear();
        }
      } catch (_) {
        _isRefreshing = false;
        await tokenStorage.clear();
      }
    }

    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final newAccess = response.data['accessToken'] as String;
      final newRefresh = response.data['refreshToken'] as String;
      await tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
