import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productDetail)),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (product) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: l10n.productImage,
                image: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 220,
                      color: Colors.grey.shade200,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 220,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Semantics(
                    label: '${l10n.category}: ${product.category}',
                    child: Chip(label: Text(product.category)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                  Semantics(
                    label: '${l10n.rating}: ${product.rating.toStringAsFixed(1)}',
                    child: Text(' ${product.rating.toStringAsFixed(1)}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                label: '${l10n.price}: ${product.price.toStringAsFixed(2)} dollars',
                child: Text(
                  '${product.price.toStringAsFixed(2)} \$',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text(product.description),
            ],
          ),
        ),
      ),
    );
  }
}
