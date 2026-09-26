import 'package:flutter/material.dart';
import '../../core/error/failures.dart';
import '../../l10n/app_localizations.dart';

/// Affiche un message d'erreur lisible + bouton "Réessayer".
/// Prend soit une [Failure], soit une String/Object générique (venant
/// d'un FutureProvider qui a "throw" la Failure).
class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.error, required this.onRetry});

  String _message(AppLocalizations l10n) {
    if (error is Failure) return (error as Failure).message;
    if (error.toString().isEmpty) return l10n.errorGeneric;
    return error.toString();
  }

  IconData get _icon {
    if (error is NetworkFailure) return Icons.wifi_off_rounded;
    if (error is AuthFailure) return Icons.lock_outline;
    return Icons.error_outline;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _message(l10n),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: l10n.retry,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
