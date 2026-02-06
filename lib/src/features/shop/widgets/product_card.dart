import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/router/app_router.dart';

import '../providers/shop_providers.dart';
import '../models/product.dart';
import '../../../common/widgets/circular_container.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onCardTap,
    this.productQuantity = 0,
  });

  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onCardTap;
  final int productQuantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isProductInWishlistProvider(product.id));
    final toggleFavorite = ref.read(toggleFavoriteProvider);

    return GestureDetector(
      onTap:
          onCardTap ??
          () => context.goNamed(
            AppRouteNames.productDetail,
            pathParameters: {'productId': product.id.toString()},
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 173,
                      height: 173,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF3F4F6),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFF9CA3AF),
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: CircularContainer(
                      width: 40,
                      height: 40,
                      backgroundColor: Colors.white,
                      icon: isFavorited
                          ? Icons.favorite
                          : Icons.favorite_border,
                      iconColor: isFavorited
                          ? Colors.red
                          : const Color(0xFF6B7280),
                      onTap: () async {
                        await toggleFavorite(
                          productId: product.id,
                          isFavorited: !isFavorited,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.feature,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7C32),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 35,
                        height: 28,
                        child: ElevatedButton(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: productQuantity > 0
                                ? const Color(0xFF6B7C32)
                                : const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: productQuantity > 0
                              ? Text(
                                  productQuantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(Money money) {
    return '${money.currencyCode} ${money.amount.toStringAsFixed(2)}';
  }
}
