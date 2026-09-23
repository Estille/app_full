import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/product_entity.dart';

/// FutureProvider.autoDispose : recharge à chaque entrée sur l'écran,
/// `ref.refresh(...)` pour le pull-to-refresh.
final productsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final result = await repo.getProducts();
  return result.match((failure) => throw failure, (products) => products);
});

final categoriesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final result = await repo.getCategories();
  return result.match((failure) => throw failure, (categories) => categories);
});

final productDetailProvider =
    FutureProvider.autoDispose.family<ProductEntity, int>((ref, id) async {
  final repo = ref.read(productRepositoryProvider);
  final result = await repo.getProductById(id);
  return result.match((failure) => throw failure, (product) => product);
});
