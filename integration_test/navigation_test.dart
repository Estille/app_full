import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app_full/core/di/injection.dart';
import 'package:app_full/main.dart';

import '../test/helpers/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.initFlutter();
  });

  testWidgets(
    'Depuis la liste des produits, ouvrir un produit puis revenir en arrière',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()..loggedIn = true),
            productRepositoryProvider.overrideWithValue(FakeProductRepository()),
            networkInfoProvider.overrideWithValue(FakeNetworkInfo()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Déjà connecté (fake) -> arrive directement sur /products
      expect(find.text('Produits'), findsOneWidget);

      await tester.tap(find.text('iPhone 9'));
      await tester.pumpAndSettle();

      expect(find.text('Détail produit'), findsOneWidget);
      expect(find.text('Un bon téléphone'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Produits'), findsOneWidget);
    },
  );
}
