import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// HookConsumerWidget : `useTextEditingController` / `useState` évitent de
/// gérer un `StatefulWidget` + `dispose()` manuel, et surtout ne
/// reconstruisent que la portion d'UI qui dépend de l'état modifié —
/// c'est la réponse concrète à l'exigence "pas de rebuilds inutiles".
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    // Identifiants de test DummyJSON pré-remplis pour la démo
    final usernameCtrl = useTextEditingController(text: 'emilys');
    final passwordCtrl = useTextEditingController(text: 'emilyspass');
    final obscure = useState(true);

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.go('/products');
      }
    });

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      await ref
          .read(authControllerProvider.notifier)
          .login(usernameCtrl.text.trim(), passwordCtrl.text.trim());
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_person_outlined, size: 64),
              const SizedBox(height: 24),
              Semantics(
                textField: true,
                label: l10n.username,
                child: TextFormField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                textField: true,
                label: l10n.password,
                child: TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscure.value,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                    suffixIcon: Semantics(
                      button: true,
                      label: obscure.value ? l10n.showPassword : l10n.hidePassword,
                      child: IconButton(
                        icon: Icon(obscure.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => obscure.value = !obscure.value,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
                ),
              ),
              const SizedBox(height: 24),
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    authState.error.toString(),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              Semantics(
                button: true,
                label: l10n.loginButton,
                enabled: !isLoading,
                child: FilledButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.loginButton),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(l10n.noAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
