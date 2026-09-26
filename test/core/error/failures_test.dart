import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/core/error/failures.dart';

void main() {
  test('deux NetworkFailure avec le même message sont égales (Equatable)', () {
    const a = NetworkFailure('Pas de réseau');
    const b = NetworkFailure('Pas de réseau');

    expect(a, equals(b));
  });

  test('ServerFailure compare aussi le statusCode', () {
    const a = ServerFailure('Erreur', statusCode: 500);
    const b = ServerFailure('Erreur', statusCode: 404);

    expect(a, isNot(equals(b)));
  });

  test('les Failures ont un message par défaut sensé si aucun n\'est fourni', () {
    const failure = AuthFailure();

    expect(failure.message, isNotEmpty);
  });
}
