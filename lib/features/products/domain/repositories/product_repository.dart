import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  /// [forceRefresh] permet de forcer un appel réseau (pull-to-refresh).
  /// Sinon : réseau si dispo, cache Hive si hors-ligne.
  Future<Either<Failure, List<ProductEntity>>> getProducts({bool forceRefresh = false});

  Future<Either<Failure, List<String>>> getCategories();

  Future<Either<Failure, ProductEntity>> getProductById(int id);
}
