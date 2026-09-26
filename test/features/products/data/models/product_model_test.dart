import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/features/products/data/models/product_model.dart';

void main() {
  final tJson = {
    'id': 1,
    'title': 'iPhone 9',
    'description': 'Un bon téléphone',
    'price': 549.0,
    'category': 'smartphones',
    'thumbnail': 'https://example.com/img.png',
    'rating': 4.5,
  };

  test('fromJson construit un ProductModel correct à partir d\'un JSON complet', () {
    final model = ProductModel.fromJson(tJson);

    expect(model.id, 1);
    expect(model.title, 'iPhone 9');
    expect(model.price, 549.0);
    expect(model.category, 'smartphones');
  });

  test('fromJson applique des valeurs par défaut sur des champs manquants', () {
    final model = ProductModel.fromJson({'id': 2});

    expect(model.id, 2);
    expect(model.title, '');
    expect(model.price, 0.0);
    expect(model.rating, 0.0);
  });

  test('toJson puis fromJson redonne un objet équivalent (round-trip)', () {
    final original = ProductModel.fromJson(tJson);
    final roundTripped = ProductModel.fromJson(original.toJson());

    expect(roundTripped.id, original.id);
    expect(roundTripped.title, original.title);
    expect(roundTripped.price, original.price);
  });
}
