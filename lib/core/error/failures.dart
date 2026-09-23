import 'package:equatable/equatable.dart';

/// Représente une erreur "métier", déjà traduite en message affichable.
/// Le repository ne retourne JAMAIS une exception brute à la couche
/// présentation : il la convertit toujours en [Failure].
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur réseau (pas de connexion, timeout, DNS...)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "Pas de connexion internet."]);
}

/// Erreur renvoyée par le serveur (4xx/5xx)
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Identifiants invalides / session expirée
class AuthFailure extends Failure {
  const AuthFailure([super.message = "Session invalide, reconnecte-toi."]);
}

/// Erreur de lecture/écriture du cache local (Hive)
class CacheFailure extends Failure {
  const CacheFailure([super.message = "Erreur de cache local."]);
}

/// Erreur non prévue
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = "Une erreur inattendue est survenue."]);
}
