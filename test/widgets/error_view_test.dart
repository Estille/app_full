import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/core/error/failures.dart';
import 'package:app_full/l10n/app_localizations.dart';
import 'package:app_full/shared/widgets/error_view.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('affiche le message de la Failure fournie', (tester) async {
    await tester.pumpWidget(_wrap(
      ErrorView(error: const NetworkFailure('Pas de réseau, test.'), onRetry: () {}),
    ));

    expect(find.text('Pas de réseau, test.'), findsOneWidget);
  });

  testWidgets('appelle onRetry quand on appuie sur le bouton Réessayer', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(
      ErrorView(
        error: const NetworkFailure('Erreur'),
        onRetry: () => tapped = true,
      ),
    ));

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
