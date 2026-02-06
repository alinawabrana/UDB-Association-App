import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/snackbar_utils.dart';
import '../models/cart_item.dart';
import '../providers/cart_providers.dart';
import '../../../../utils/constants/urls.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItem cartItem;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = cartItem.product;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.primaryImage != null
                  ? Image.network(
                      ApiUrls.getProductImageUrl(product.primaryImage),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Iconsax.box,
                          color: Color(0xFF6B7280),
                        );
                      },
                    )
                  : const Icon(Iconsax.box, color: Color(0xFF6B7280)),
            ),
          ),

          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Category (we'll show shop info since we don't have category name)
                Text(
                  'Shop ID: ${product.shopId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

                const SizedBox(height: 4),

                // Price
                Row(
                  children: [
                    Text(
                      'Rs. ${product.discountedPrice ?? product.price}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7C32),
                      ),
                    ),
                    if (product.discountedPrice != null &&
                        product.discountedPrice != product.price) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Rs. ${product.price}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            children: [
              // Decrement Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => _handleDecrement(context, ref),
                  icon: const Icon(Icons.remove, size: 16, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              // Quantity
              Container(
                width: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  cartItem.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Increment Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7C32),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handle decrement button press with confirmation dialog for removal
  Future<void> _handleDecrement(BuildContext context, WidgetRef ref) async {
    // If quantity is 1, show confirmation dialog
    if (cartItem.quantity == 1) {
      final shouldRemove = await _showRemoveConfirmationDialog(context);
      if (shouldRemove == true) {
        await _removeItem(context, ref);
      }
    } else {
      // Simply decrement the quantity
      await _decrementQuantity(context, ref);
    }
  }

  /// Show confirmation dialog for removing item from cart
  Future<bool?> _showRemoveConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Remove Item',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to remove "${cartItem.product.name}" from your cart?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  /// Decrement item quantity by 1
  Future<void> _decrementQuantity(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(cartOperationsProvider.notifier)
          .decrementCartItem(cartItem.id);
      if (context.mounted) {
        SnackbarUtils.showInfo(
          context,
          message: '${cartItem.product.name} quantity decreased!',
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          message: 'Failed to update quantity: ${e.cleanMessage}',
        );
      }
    }
  }

  /// Remove item completely from cart
  Future<void> _removeItem(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(cartOperationsProvider.notifier)
          .deleteCartItem(cartItem.id);
      if (context.mounted) {
        SnackbarUtils.showWarning(
          context,
          message: '${cartItem.product.name} removed from cart!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          message: 'Failed to remove item: ${e.cleanMessage}',
        );
      }
    }
  }
}
