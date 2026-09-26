import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/features/products/presentation/screens/products_list_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('affiche la liste des produits une fois chargée', (tester) async {
    await pumpApp(
      tester,
      const ProductsListScreen(),
      productRepository: FakeProductRepository(),
      networkInfo: FakeNetworkInfo(connected: true),
    );

    // 1er pump : état loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('iPhone 9'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('affiche le bandeau hors-ligne quand il n\'y a pas de réseau', (tester) async {
    await pumpApp(
      tester,
      const ProductsListScreen(),
      productRepository: FakeProductRepository(),
      networkInfo: FakeNetworkInfo(connected: false),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Hors-ligne'), findsOneWidget);
  });

  testWidgets('affiche ErrorView si le repository échoue', (tester) async {
    final repo = FakeProductRepository()..shouldFail = true;
    await pumpApp(
      tester,
      const ProductsListScreen(),
      productRepository: repo,
      networkInfo: FakeNetworkInfo(connected: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Réessayer'), findsOneWidget);
  });
}
