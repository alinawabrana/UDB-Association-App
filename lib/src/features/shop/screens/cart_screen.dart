import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:udb_association/utils/network/error_utils.dart';
import '../providers/cart_providers.dart';
import '../models/cart_item.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_request_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/src/features/auth/provider/user_role_fallback_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<int> _deletingItems = {};
  final Set<int> _updatingItems = {};

  @override
  Widget build(BuildContext context) {
    final cartItemsAsync = ref.watch(cartItemsProvider);
    final selectedItems = ref.watch(selectedCartItemsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('cart_title'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Cart count badge
          Consumer(
            builder: (context, ref, child) {
              final cartCountAsync = ref.watch(cartCountProvider);
              return cartCountAsync.when(
                data: (count) => count > 0
                    ? Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B7C32),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: cartItemsAsync.when(
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('cart_empty_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('cart_empty_subtitle'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    final isSelected = selectedItems.contains(cartItem.id);
                    final isDeleting = _deletingItems.contains(cartItem.id);
                    final isUpdating = _updatingItems.contains(cartItem.id);
                    final product = cartItem.product;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6B7C32)
                              : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (isDeleting || isUpdating)
                                    ? null
                                    : (value) {
                                        final newSelected = Set<int>.from(
                                          selectedItems,
                                        );
                                        if (value == true) {
                                          newSelected.add(cartItem.id);
                                        } else {
                                          newSelected.remove(cartItem.id);
                                        }
                                        ref
                                                .read(
                                                  selectedCartItemsProvider
                                                      .notifier,
                                                )
                                                .state =
                                            newSelected;
                                      },
                                activeColor: const Color(0xFF6B7C32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Product Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFFF3F4F6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: product.primaryImage != null
                                    ? Image.network(
                                        ApiUrls.getProductImageUrl(
                                          product.primaryImage,
                                        ),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.image_outlined,
                                                color: Color(0xFF9CA3AF),
                                                size: 32,
                                              );
                                            },
                                      )
                                    : const Icon(
                                        Icons.image_outlined,
                                        color: Color(0xFF9CA3AF),
                                        size: 32,
                                      ),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 6),

                                  // Price
                                  Row(
                                    children: [
                                      Text(
                                        'Rs. ${product.discountedPrice ?? product.price}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF6B7C32),
                                        ),
                                      ),
                                      if (product.discountedPrice != null &&
                                          product.discountedPrice !=
                                              product.price) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          'Rs. ${product.price}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9CA3AF),
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Quantity Controls
                                  Row(
                                    children: [
                                      // Decrement Button
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: isUpdating
                                            ? const Center(
                                                child: SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Color(0xFF6B7280)),
                                                  ),
                                                ),
                                              )
                                            : IconButton(
                                                onPressed: isDeleting
                                                    ? null
                                                    : () => _handleDecrement(
                                                        context,
                                                        ref,
                                                        cartItem,
                                                      ),
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 14,
                                                  color: Color(0xFF6B7280),
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                      ),

                                      // Quantity
                                      Container(
                                        width: 40,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          cartItem.quantity.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      ),

                                      // Increment Button
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6B7C32),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: isUpdating
                                            ? const Center(
                                                child: SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                              )
                                            : IconButton(
                                                onPressed: isDeleting
                                                    ? null
                                                    : () => _handleIncrement(
                                                        context,
                                                        ref,
                                                        cartItem,
                                                      ),
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                      ),

                                      const Spacer(),

                                      // Delete button
                                      if (isDeleting)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF6B7C32),
                                                ),
                                          ),
                                        )
                                      else
                                        InkWell(
                                          onTap: () =>
                                              _deleteCartItem(cartItem.id),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 18,
                                            ),
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
                  },
                ),
              ),

              // Bottom section with total and checkout button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.translate('cart_total_items_label'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final cartCountAsync = ref.watch(cartCountProvider);
                            return cartCountAsync.when(
                              data: (count) => Text(
                                count.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7C32),
                                ),
                              ),
                              loading: () => const Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7C32),
                                ),
                              ),
                              error: (_, __) => const Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7C32),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Checkout button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedItems.isEmpty
                            ? null
                            : () => _handleCheckout(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7C32),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          disabledForegroundColor: const Color(0xFF9CA3AF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          selectedItems.isEmpty
                              ? l10n.translate('cart_select_items')
                              : l10n.translate(
                                  'cart_proceed_button',
                                  params: {
                                    'count': selectedItems.length.toString(),
                                  },
                                ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7C32)),
          ),
        ),
        error: (error, stackTrace) {
          print('❌ CART_SCREEN ERROR: Failed to load cart items');
          print('Error: $error');
          print('Stack trace: $stackTrace');

          // Show error in snackbar if not a network error
          if (!isNetworkError(error) && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SnackbarUtils.showError(context, message: error.cleanMessage);
            });
            // Return empty state since error is shown in snackbar
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('cart_error_unavailable'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(cartItemsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7C32),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.translate('retry')),
                  ),
                ],
              ),
            );
          }

          // Show network error on screen
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('no_internet_connection'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('check_connection_try_again'),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(cartItemsProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7C32),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.translate('retry')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleIncrement(
    BuildContext context,
    WidgetRef ref,
    CartItem cartItem,
  ) async {
    final l10n = context.l10n;
    try {
      // Add to updating set
      setState(() {
        _updatingItems.add(cartItem.id);
      });

      await ref
          .read(cartOperationsProvider.notifier)
          .incrementCartItem(cartItem.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.translate(
                'cart_update_failed',
                params: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Remove from updating set
      if (mounted) {
        setState(() {
          _updatingItems.remove(cartItem.id);
        });
      }
    }
  }

  Future<void> _handleDecrement(
    BuildContext context,
    WidgetRef ref,
    CartItem cartItem,
  ) async {
    final l10n = context.l10n;
    try {
      // Add to updating set
      setState(() {
        _updatingItems.add(cartItem.id);
      });

      await ref
          .read(cartOperationsProvider.notifier)
          .decrementCartItem(cartItem.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.translate(
                'cart_update_failed',
                params: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Remove from updating set
      if (mounted) {
        setState(() {
          _updatingItems.remove(cartItem.id);
        });
      }
    }
  }

  Future<void> _deleteCartItem(int cartItemId) async {
    try {
      final l10n = context.l10n;
      // Add to deleting set
      setState(() {
        _deletingItems.add(cartItemId);
      });

      // Call delete API
      await ref
          .read(cartOperationsProvider.notifier)
          .deleteCartItem(cartItemId);

      // Remove from selected items if it was selected
      final selectedItems = ref.read(selectedCartItemsProvider);
      if (selectedItems.contains(cartItemId)) {
        ref.read(selectedCartItemsProvider.notifier).state = selectedItems
            .where((id) => id != cartItemId)
            .toSet();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('cart_item_removed')),
            backgroundColor: const Color(0xFF22C55E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: context.l10n.translate(
            'cart_delete_failed',
            params: {'error': e.cleanMessage},
          ),
        );
      }
    } finally {
      // Remove from deleting set
      if (mounted) {
        setState(() {
          _deletingItems.remove(cartItemId);
        });
      }
    }
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    try {
      // Get current user role (using effectiveUserRoleProvider for consistent role detection)
      final userRole = ref.read(effectiveUserRoleProvider);

      final normalizedRole = userRole?.toLowerCase();

      if (normalizedRole == 'manager') {
        // For managers, navigate to app checkout route
        context.pushNamed(AppRouteNames.appProductCheckout);
      } else if (normalizedRole == 'member') {
        // For members, navigate to member checkout route
        context.pushNamed(AppRouteNames.memberProductCheckout);
      } else if (normalizedRole == 'user') {
        final hasApprovedSubscription = ref.read(
          userHasApprovedSubscriptionProvider,
        );
        final isSpecialUser = hasApprovedSubscription.maybeWhen(
          data: (value) => value,
          orElse: () => false,
        );

        if (isSpecialUser) {
          final rootContext = AppRouteNames.rootKey.currentContext;
          rootContext?.goNamed(AppRouteNames.productCheckout);
          return;
        }

        await _checkUserSubscriptionAndNavigate(context, ref);
      } else {
        final rootContext = AppRouteNames.rootKey.currentContext;
        rootContext?.goNamed(AppRouteNames.productCheckout);
      }
    } catch (e) {
      // On any error, navigate to product checkout as fallback
      final rootContext = AppRouteNames.rootKey.currentContext;
      rootContext?.goNamed(AppRouteNames.productCheckout);
    }
  }

  Future<void> _checkUserSubscriptionAndNavigate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final l10n = context.l10n;
      // Show loading message
      SnackbarUtils.showInfo(
        context,
        message: l10n.translate('cart_check_subscription'),
      );

      // Refresh subscription request data to get latest status from API
      print('🔄 Refreshing subscription request providers...');
      ref.invalidate(currentUserSubscriptionRequestProvider);
      ref.invalidate(userSubscriptionRequestsProvider);
      ref.invalidate(userHasApprovedSubscriptionProvider);
      ref.invalidate(userSubscriptionStatusProvider);

      // Wait for fresh subscription request data to load
      print('⏳ Fetching fresh subscription request data from API...');
      final subscriptionRequestAsync = await ref.read(
        currentUserSubscriptionRequestProvider.future,
      );
      print('✅ Fresh subscription request data loaded');

      // For user role, check subscription request status
      print('=== CART CHECKOUT SUBSCRIPTION REQUEST CHECK ===');
      print('Subscription request found: ${subscriptionRequestAsync != null}');

      if (subscriptionRequestAsync != null) {
        print('User ID: ${subscriptionRequestAsync.userId}');
        print('Status: ${subscriptionRequestAsync.status}');
        print('Is Approved: ${subscriptionRequestAsync.isApproved}');
        print('Is Expired: ${subscriptionRequestAsync.isExpired}');
        print('Is Active: ${subscriptionRequestAsync.isActive}');

        // Check subscription request status
        if (subscriptionRequestAsync.isActive) {
          // User has approved and active subscription, navigate to product checkout
          print(
            'Final decision - Navigate to: Product Checkout (Active subscription)',
          );
          final rootContext = AppRouteNames.rootKey.currentContext;
          rootContext?.goNamed(AppRouteNames.productCheckout);
          return;
        } else if (subscriptionRequestAsync.isPending) {
          // User has pending subscription request
          print('Final decision - Show approval warning');
          if (context.mounted) {
            _showApprovalWarning(context);
          }
        } else if (subscriptionRequestAsync.isExpired) {
          // User has expired subscription, navigate to subscription selection
          print(
            'Final decision - Navigate to: Subscription Selection (Expired subscription)',
          );
          final rootContext = AppRouteNames.rootKey.currentContext;
          rootContext?.goNamed(
            AppRouteNames.subscriptionSelection,
            queryParameters: {'type': 'user'},
          );
          return;
        } else {
          // User has no valid subscription, navigate to subscription selection
          print(
            'Final decision - Navigate to: Subscription Selection (No valid subscription)',
          );
          final rootContext = AppRouteNames.rootKey.currentContext;
          rootContext?.goNamed(
            AppRouteNames.subscriptionSelection,
            queryParameters: {'type': 'user'},
          );
          return;
        }
      } else {
        // No subscription request found, navigate to subscription selection
        print(
          'Final decision - Navigate to: Subscription Selection (No subscription request)',
        );
        final rootContext = AppRouteNames.rootKey.currentContext;
        rootContext?.goNamed(
          AppRouteNames.subscriptionSelection,
          queryParameters: {'type': 'user'},
        );
        return;
      }

      print('=== END CART CHECKOUT CHECK ===');
    } catch (e) {
      // On error, navigate to subscription selection as fallback
      final rootContext = AppRouteNames.rootKey.currentContext;
      rootContext?.goNamed(
        AppRouteNames.subscriptionSelection,
        queryParameters: {'type': 'user'},
      );
    }
  }

  void _showApprovalWarning(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final l10n = context.l10n;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.translate('cart_subscription_pending_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            l10n.translate('cart_subscription_pending_message'),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6B7C32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.translate('common_ok'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
