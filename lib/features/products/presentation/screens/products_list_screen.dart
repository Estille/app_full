import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/product_provider.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.products),
        actions: [
          Semantics(
            button: true,
            label: l10n.openProfile,
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/profile'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const _OfflineBanner(),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (products) => RefreshIndicator(
                onRefresh: () => ref.refresh(productsProvider.future),
                child: ListView.builder(
                  // itemExtent : évite à la liste de mesurer chaque item avant
                  // de scroller -> pas de jank sur de longues listes.
                  itemExtent: 72,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      leading: Semantics(
                        label: l10n.productImage,
                        image: true,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: p.thumbnail,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            // Lazy : ne décode/affiche que quand le tile
                            // devient visible ; place un espace réservé
                            // pendant le chargement pour éviter les sauts
                            // de layout (donc pas de jank au scroll).
                            placeholder: (context, url) => const ColoredBox(
                              color: Color(0xFFE0E0E0),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                      title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(p.category),
                      trailing: Text('${p.price.toStringAsFixed(2)} \$'),
                      onTap: () => context.push('/products/${p.id}'),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau visible en permanence si pas de réseau — répond directement
/// à l'exigence "mode hors-ligne visible pour l'utilisateur".
class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final networkInfo = ref.watch(networkInfoProvider);
    return FutureBuilder<bool>(
      future: networkInfo.isConnected,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Semantics(
            liveRegion: true,
            child: Container(
              width: double.infinity,
              color: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                l10n.offlineBanner,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
