import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: l10n.userAvatar,
              image: true,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: user?.image != null
                    ? CachedNetworkImageProvider(user!.image!)
                    : null,
                child: user?.image == null ? const Icon(Icons.person, size: 40) : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user != null ? '${user.firstName} ${user.lastName}' : l10n.guest,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(user?.email ?? ''),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: l10n.logout,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
