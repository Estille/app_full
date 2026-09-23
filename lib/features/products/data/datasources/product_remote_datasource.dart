import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<String>> getCategories();
  Future<ProductModel> getProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;
  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get('/products', queryParameters: {'limit': 30});
      final list = (response.data['products'] as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await dio.get('/products/categories');
      // DummyJSON renvoie soit une liste de strings, soit d'objets {slug,name}
      return (response.data as List).map((e) {
        if (e is String) return e;
        return e['slug'] as String? ?? e['name'] as String;
      }).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await dio.get('/products/$id');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    return ServerException(
      e.message ?? 'Erreur serveur inconnue.',
      statusCode: e.response?.statusCode,
    );
  }
}
