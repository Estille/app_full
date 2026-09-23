import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    bool forceRefresh = false,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final products = await remoteDataSource.getProducts();
        await localDataSource.cacheProducts(products);
        return Right(products);
      } on ServerException catch (e) {
        // Le réseau est là mais le serveur répond mal : on retente le cache
        // comme filet de sécurité avant d'abandonner.
        return _fallbackToCache(ServerFailure(e.message, statusCode: e.statusCode));
      } on NetworkException {
        return _fallbackToCache(const NetworkFailure());
      }
    } else {
      return _fallbackToCache(const NetworkFailure(
        "Pas de connexion — affichage des données en cache.",
      ));
    }
  }

  Future<Either<Failure, List<ProductEntity>>> _fallbackToCache(
    Failure originalFailure,
  ) async {
    try {
      final cached = await localDataSource.getCachedProducts();
      return Right(cached);
    } on CacheException {
      // Ni réseau ni cache : on remonte l'erreur d'origine, plus parlante
      return Left(originalFailure);
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();
        await localDataSource.cacheCategories(categories);
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    }
    try {
      final cached = await localDataSource.getCachedCategories();
      return Right(cached);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    if (!await networkInfo.isConnected) {
      // Recherche dans le cache liste (pas de cache dédié par id ici)
      try {
        final cached = await localDataSource.getCachedProducts();
        final matches = cached.where((p) => p.id == id);
        if (matches.isNotEmpty) return Right(matches.first);
        return const Left(NetworkFailure(
          "Produit indisponible hors-ligne (jamais chargé).",
        ));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
