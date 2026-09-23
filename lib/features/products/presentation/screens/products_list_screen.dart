import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/product_provider.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
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
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(p.thumbnail),
                        onBackgroundImageError: (_, _) {},
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
    final networkInfo = ref.watch(networkInfoProvider);
    return FutureBuilder<bool>(
      future: networkInfo.isConnected,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Container(
            width: double.infinity,
            color: Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Text(
              '⚠ Hors-ligne — données en cache',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
