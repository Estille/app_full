import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheCategories(List<String> categories);
  Future<List<String>> getCachedCategories();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const productsBox = 'products_box';
  static const categoriesBox = 'categories_box';
  static const productsKey = 'products';
  static const categoriesKey = 'categories';

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final box = await Hive.openBox(productsBox);
      await box.put(productsKey, products.map((p) => p.toJson()).toList());
    } catch (_) {
      throw CacheException("Impossible d'enregistrer les produits en cache.");
    }
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final box = await Hive.openBox(productsBox);
      final raw = box.get(productsKey) as List?;
      if (raw == null) throw CacheException("Aucune donnée en cache.");
      return raw
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on CacheException {
      rethrow;
    } catch (_) {
      throw CacheException("Impossible de lire le cache local.");
    }
  }

  @override
  Future<void> cacheCategories(List<String> categories) async {
    final box = await Hive.openBox(categoriesBox);
    await box.put(categoriesKey, categories);
  }

  @override
  Future<List<String>> getCachedCategories() async {
    final box = await Hive.openBox(categoriesBox);
    final raw = box.get(categoriesKey) as List?;
    if (raw == null) throw CacheException("Aucune catégorie en cache.");
    return raw.cast<String>();
  }
}
