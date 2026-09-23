/// Exceptions levées par les datasources (remote/local).
/// Elles sont attrapées puis converties en [Failure] dans le repository —
/// la couche datasource ne connaît pas les Failures.

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "Pas de connexion internet."]);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = "Identifiants invalides."]);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = "Erreur de cache local."]);
}
