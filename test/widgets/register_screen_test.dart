import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/features/auth/presentation/screens/register_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('affiche les 3 champs du formulaire d\'inscription', (tester) async {
    await pumpApp(
      tester,
      const RegisterScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.widgetWithText(FilledButton, "S'inscrire"), findsOneWidget);
  });

  testWidgets('affiche "Email invalide" si l\'email ne contient pas de @', (tester) async {
    await pumpApp(
      tester,
      const RegisterScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'jean');
    await tester.enterText(find.byType(TextFormField).at(1), 'pas-un-email');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');

    await tester.tap(find.widgetWithText(FilledButton, "S'inscrire"));
    await tester.pump();

    expect(find.text('Email invalide'), findsOneWidget);
  });

  testWidgets('affiche "Minimum 6 caractères" si le mot de passe est trop court', (tester) async {
    await pumpApp(
      tester,
      const RegisterScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'jean');
    await tester.enterText(find.byType(TextFormField).at(1), 'jean@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '123');

    await tester.tap(find.widgetWithText(FilledButton, "S'inscrire"));
    await tester.pump();

    expect(find.text('Minimum 6 caractères'), findsOneWidget);
  });
}
