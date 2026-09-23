import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/core/error/exceptions.dart';
import 'package:app_full/core/error/failures.dart';
import 'package:app_full/core/network/network_info.dart';
import 'package:app_full/features/products/data/datasources/product_local_datasource.dart';
import 'package:app_full/features/products/data/datasources/product_remote_datasource.dart';
import 'package:app_full/features/products/data/models/product_model.dart';
import 'package:app_full/features/products/data/repositories/product_repository_impl.dart';

class FakeProductRemoteDataSource implements ProductRemoteDataSource {
  bool shouldThrowNetworkException = false;
  final tProducts = const [
    ProductModel(
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
  Future<List<ProductModel>> getProducts() async {
    if (shouldThrowNetworkException) throw NetworkException();
    return tProducts;
  }

  @override
  Future<List<String>> getCategories() async => ['smartphones'];

  @override
  Future<ProductModel> getProductById(int id) async => tProducts.first;
}

class FakeProductLocalDataSource implements ProductLocalDataSource {
  List<ProductModel>? cachedProducts;
  List<String>? cachedCategories;

  @override
  Future<void> cacheProducts(List<ProductModel> products) async =>
      cachedProducts = products;

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    if (cachedProducts == null) throw CacheException('Aucune donnée en cache.');
    return cachedProducts!;
  }

  @override
  Future<void> cacheCategories(List<String> categories) async =>
      cachedCategories = categories;

  @override
  Future<List<String>> getCachedCategories() async {
    if (cachedCategories == null) throw CacheException('Aucune catégorie.');
    return cachedCategories!;
  }
}

class FakeNetworkInfo implements NetworkInfo {
  bool connected = true;
  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  late FakeProductRemoteDataSource remote;
  late FakeProductLocalDataSource local;
  late FakeNetworkInfo networkInfo;
  late ProductRepositoryImpl repository;

  setUp(() {
    remote = FakeProductRemoteDataSource();
    local = FakeProductLocalDataSource();
    networkInfo = FakeNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );
  });

  test('getProducts : va chercher côté réseau et met en cache si connecté', () async {
    networkInfo.connected = true;

    final result = await repository.getProducts();

    expect(result.isRight(), true);
    result.match(
      (l) => fail('ne devrait pas échouer'),
      (products) => expect(products.first.title, 'iPhone 9'),
    );
    expect(local.cachedProducts, isNotNull);
  });

  test('getProducts : retombe sur le cache si hors-ligne (mode offline)', () async {
    networkInfo.connected = false;
    local.cachedProducts = remote.tProducts; // simule un cache déjà rempli

    final result = await repository.getProducts();

    expect(result.isRight(), true);
    result.match(
      (l) => fail('ne devrait pas échouer, le cache existe'),
      (products) => expect(products.length, 1),
    );
  });

  test('getProducts : retourne NetworkFailure si hors-ligne ET cache vide', () async {
    networkInfo.connected = false;
    local.cachedProducts = null;

    final result = await repository.getProducts();

    expect(result.isLeft(), true);
    result.match(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (r) => fail('ne devrait pas réussir'),
    );
  });
}
