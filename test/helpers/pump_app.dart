import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/core/di/injection.dart';
import 'package:app_full/l10n/app_localizations.dart';

import 'fakes.dart';

/// Pompe [child] dans un arbre minimal mais réaliste : ProviderScope avec
/// les repositories remplacés par des fakes, + délégués de localisation
/// (nécessaires car tous les écrans utilisent `context.l10n`).
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  FakeAuthRepository? authRepository,
  FakeProductRepository? productRepository,
  FakeNetworkInfo? networkInfo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (authRepository != null) authRepositoryProvider.overrideWithValue(authRepository),
        if (productRepository != null)
          productRepositoryProvider.overrideWithValue(productRepository),
        networkInfoProvider.overrideWithValue(networkInfo ?? FakeNetworkInfo()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}
