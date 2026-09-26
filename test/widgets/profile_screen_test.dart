import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/features/auth/presentation/screens/profile_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('affiche "Invité" quand personne n\'est connecté', (tester) async {
    await pumpApp(
      tester,
      const ProfileScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invité'), findsOneWidget);
  });

  testWidgets('affiche le bouton de déconnexion avec un label sémantique', (tester) async {
    await pumpApp(
      tester,
      const ProfileScreen(),
      authRepository: FakeAuthRepository(),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Se déconnecter'), findsOneWidget);
    expect(find.bySemanticsLabel('Se déconnecter'), findsWidgets);
  });
}
