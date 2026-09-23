import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Contrat que la couche presentation utilise — elle ne connaît jamais
/// Dio, Hive ni l'implémentation concrète, seulement cette interface.
/// `Either<Failure, T>` : Left = erreur, Right = succès (pattern fonctionnel,
/// évite les try/catch dispersés dans l'UI).
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  /// Retourne l'utilisateur en session (cache local) sans appel réseau,
  /// utile pour l'auto-login au démarrage de l'app.
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
