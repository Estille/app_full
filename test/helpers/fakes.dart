import 'package:fpdart/fpdart.dart';
import 'package:app_full/core/error/failures.dart';
import 'package:app_full/core/network/network_info.dart';
import 'package:app_full/features/auth/domain/entities/user_entity.dart';
import 'package:app_full/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_full/features/products/domain/entities/product_entity.dart';
import 'package:app_full/features/products/domain/repositories/product_repository.dart';

/// Évite tout appel au plugin natif `connectivity_plus` (indisponible dans
/// les tests widgets, qui n'ont pas de MethodChannel réel).
class FakeNetworkInfo implements NetworkInfo {
  bool connected;
  FakeNetworkInfo({this.connected = true});

  @override
  Future<bool> get isConnected async => connected;
}


/// Repository d'auth "en mémoire" pour les tests de widgets/intégration —
/// aucune dépendance à Dio/Hive, contrôlable depuis le test.
class FakeAuthRepository implements AuthRepository {
  bool loggedIn = false;
  bool shouldFailLogin = false;

  static const tUser = UserEntity(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    if (shouldFailLogin) return const Left(AuthFailure('Identifiants invalides.'));
    loggedIn = true;
    return const Right(tUser);
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    loggedIn = true;
    return const Right(tUser);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    loggedIn = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async =>
      Right(loggedIn ? tUser : null);
}

class FakeProductRepository implements ProductRepository {
  bool shouldFail = false;

  static const tProducts = [
    ProductEntity(
      id: 1,
      title: 'iPhone 9',
      description: 'Un bon téléphone',
      price: 549.0,
      category: 'smartphones',
      thumbnail: 'https://example.com/img.png',
      rating: 4.5,
    ),
  ];

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({bool forceRefresh = false}) async {
    if (shouldFail) return const Left(NetworkFailure('Pas de connexion internet.'));
    return const Right(tProducts);
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async =>
      const Right(['smartphones']);

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    if (shouldFail) return const Left(NetworkFailure('Pas de connexion internet.'));
    return Right(tProducts.firstWhere((p) => p.id == id, orElse: () => tProducts.first));
  }
}
