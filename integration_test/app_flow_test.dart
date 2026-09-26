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
    'Parcours complet : connexion réussie -> écran Produits affiché',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            productRepositoryProvider.overrideWithValue(FakeProductRepository()),
            networkInfoProvider.overrideWithValue(FakeNetworkInfo()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // On démarre bien sur l'écran de connexion (redirect car non authentifié)
      expect(find.text('Connexion'), findsOneWidget);

      // Les champs sont pré-remplis avec les identifiants de démo
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();

      // Le router redirige automatiquement vers /products après connexion
      expect(find.text('Produits'), findsOneWidget);
      expect(find.text('iPhone 9'), findsOneWidget);
    },
  );

  testWidgets(
    'Un utilisateur non connecté ne peut pas rester sur /products (redirect)',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            productRepositoryProvider.overrideWithValue(FakeProductRepository()),
            networkInfoProvider.overrideWithValue(FakeNetworkInfo()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Sans connexion, le redirect de GoRouter renvoie toujours vers /login
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Produits'), findsNothing);
    },
  );
}
