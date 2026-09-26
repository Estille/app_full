import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/features/auth/presentation/screens/login_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('affiche les champs username/password pré-remplis', (tester) async {
    await pumpApp(
      tester,
      const LoginScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    expect(find.text('emilys'), findsOneWidget);
    expect(find.text('emilyspass'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
  });

  testWidgets('affiche une erreur de validation si les champs sont vidés', (tester) async {
    await pumpApp(
      tester,
      const LoginScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    // Vide les deux champs
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.enterText(find.byType(TextFormField).last, '');

    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pump();

    expect(find.text('Champ requis'), findsWidgets);
  });

  testWidgets('le bouton œil bascule la visibilité du mot de passe', (tester) async {
    await pumpApp(
      tester,
      const LoginScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
