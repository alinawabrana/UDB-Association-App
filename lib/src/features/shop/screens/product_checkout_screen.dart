import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';
import 'package:udb_association/src/features/shop/providers/shipping_address_providers.dart';
import 'package:udb_association/src/features/shop/models/cart_item.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/network/connectivity.dart';
import 'package:udb_association/utils/network/error_utils.dart';
import 'package:udb_association/src/features/auth/provider/user_role_fallback_provider.dart';

// Local payment method enum and mapping (aligned with subscription checkout)
enum ProductPaymentMethod { stripe, googlePay, creditCard, debitCard }

class _PaymentMethodData {
  final String value;
  final String id;
  final String title;
  final IconData icon;

  const _PaymentMethodData({
    required this.value,
    required this.id,
    required this.title,
    required this.icon,
  });
}

const Map<ProductPaymentMethod, _PaymentMethodData> _paymentMethodData = {
  ProductPaymentMethod.stripe: _PaymentMethodData(
    value: 'stripe',
    id: 'stripe_001',
    title: 'Stripe',
    icon: Icons.payment,
  ),
  ProductPaymentMethod.googlePay: _PaymentMethodData(
    value: 'google_pay',
    id: 'google_pay_001',
    title: 'Google Pay',
    icon: Icons.account_balance_wallet,
  ),
  ProductPaymentMethod.creditCard: _PaymentMethodData(
    value: 'credit_card',
    id: 'credit_card_001',
    title: 'Credit Card',
    icon: Icons.credit_card,
  ),
  ProductPaymentMethod.debitCard: _PaymentMethodData(
    value: 'debit_card',
    id: 'debit_card_001',
    title: 'Debit Card',
    icon: Icons.credit_card_outlined,
  ),
};

final _selectedPaymentMethodProvider = StateProvider<ProductPaymentMethod?>(
  (ref) => null,
);

// Shipping address selection provider
final _selectedShippingAddressProvider = StateProvider<int?>((ref) => null);

// Loading state for address creation
final _isCreatingAddressProvider = StateProvider<bool>((ref) => false);

class ProductCheckoutScreen extends ConsumerStatefulWidget {
  const ProductCheckoutScreen({super.key});

  @override
  ConsumerState<ProductCheckoutScreen> createState() =>
      _ProductCheckoutScreenState();
}

class _ProductCheckoutScreenState extends ConsumerState<ProductCheckoutScreen>
    with WidgetsBindingObserver {
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh addresses when app resumes
      ref.invalidate(shippingAddressesProvider);
    }
  }

  Future<void> _retryAll() async {
    if (_retrying) return;

    setState(() {
      _retrying = true;
    });

    try {
      final l10n = context.l10n;
      // Check internet connectivity
      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            message: l10n.translate(
              'checkout_addresses_error_network_subtitle',
            ),
          );
        }
        return;
      }

      // Refresh addresses
      ref.invalidate(shippingAddressesProvider);
      await ref.read(shippingAddressesProvider.future);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: context.l10n.translate('checkout_addresses_error_generic'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _retrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItemsAsync = ref.watch(cartItemsProvider);
    final selectedCartItems = ref.watch(selectedCartItemsProvider);
    final selectedPayment = ref.watch(_selectedPaymentMethodProvider);
    final selectedAddress = ref.watch(_selectedShippingAddressProvider);
    final addressesAsync = ref.watch(shippingAddressesProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.translate('checkout_title'),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: cartItemsAsync.when(
        data: (allItems) {
          // Filter to only show selected items
          final items = allItems
              .where((item) => selectedCartItems.contains(item.id))
              .toList();

          // Debug: Print selected items count
          print('🛒 Total cart items: ${allItems.length}');
          print('✅ Selected items: ${selectedCartItems.length}');
          print('📦 Items for checkout: ${items.length}');

          if (items.isEmpty) {
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
                    l10n.translate('checkout_no_items_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('checkout_no_items_subtitle'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final totals = _calculateTotals(items);

          return addressesAsync.when(
            data: (addresses) => Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shipping Address Section
                        Text(
                          l10n.translate('checkout_shipping_address'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ShippingAddressCard(
                          addresses: addresses,
                          selectedAddress: selectedAddress,
                          onAddressSelected: (addressId) =>
                              ref
                                      .read(
                                        _selectedShippingAddressProvider
                                            .notifier,
                                      )
                                      .state =
                                  addressId,
                          onAddNewAddress: () =>
                              _showAddAddressDialog(context, ref),
                        ),

                        const SizedBox(height: 24),

                        // Cart Items Section
                        Text(
                          l10n.translate('checkout_order_items'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...items.map((item) => _CartItemRow(item: item)),

                        const SizedBox(height: 24),

                        Text(
                          l10n.translate('checkout_payment_methods'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...ProductPaymentMethod.values.map((method) {
                          final data = _paymentMethodData[method]!;
                          return Column(
                            children: [
                              _PaymentMethodTile(
                                method: method,
                                title: data.title,
                                icon: data.icon,
                                selectedMethod: selectedPayment,
                                onTap: () =>
                                    ref
                                            .read(
                                              _selectedPaymentMethodProvider
                                                  .notifier,
                                            )
                                            .state =
                                        method,
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),

                        const SizedBox(height: 24),

                        _OrderSummary(
                          subtotal: totals.subtotal,
                          totalQuantity: totals.totalQuantity,
                          shippingFee: 5.00,
                          taxRate: 0.10,
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (selectedPayment == null || selectedAddress == null)
                            ? null
                            : () => _handleCheckout(context, ref, totals),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7C32),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          disabledForegroundColor: const Color(0xFF9CA3AF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(
                          l10n.translate(
                            'checkout_place_order',
                            params: {
                              'total': _calculateTotal(
                                totals.subtotal,
                                5.00,
                                0.10,
                              ).toStringAsFixed(2),
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNetworkError(error)
                          ? Icons.wifi_off
                          : Icons.error_outline,
                      size: 48,
                      color: isNetworkError(error)
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isNetworkError(error)
                          ? l10n.translate('checkout_addresses_error_network')
                          : l10n.translate('checkout_addresses_error_generic'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isNetworkError(error)
                          ? l10n.translate(
                              'checkout_addresses_error_network_subtitle',
                            )
                          : l10n.translate(
                              'checkout_addresses_error_generic_subtitle',
                            ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _retrying ? null : _retryAll,
                      icon: _retrying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh, size: 16),
                      label: Text(
                        _retrying
                            ? l10n.translate('checkout_retrying')
                            : l10n.translate('retry'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7C32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.translate(
              'checkout_failed_load_cart',
              params: {'error': e.toString()},
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }

  _Totals _calculateTotals(List<CartItem> items) {
    double subtotal = 0;
    int totalQty = 0;
    for (final item in items) {
      final unit =
          double.tryParse(item.product.discountedPrice ?? '') ??
          double.tryParse(item.product.price) ??
          0.0;
      subtotal += unit * item.quantity;
      totalQty += item.quantity;
      print(
        '💰 Item: ${item.product.name}, Price: $unit, Qty: ${item.quantity}, Total: ${unit * item.quantity}',
      );
    }
    print('💵 Final Subtotal: $subtotal, Total Qty: $totalQty');
    return _Totals(subtotal: subtotal, totalQuantity: totalQty);
  }

  double _calculateTotal(double subtotal, double shippingFee, double taxRate) {
    final tax = subtotal * taxRate;
    return subtotal + shippingFee + tax;
  }

  Future<void> _handleCheckout(
    BuildContext context,
    WidgetRef ref,
    _Totals totals,
  ) async {
    final l10n = context.l10n;
    try {
      // Show loading
      SnackbarUtils.showLoading(
        context,
        message: l10n.translate('checkout_processing_order'),
      );

      // Get selected values
      final selectedAddressId = ref.read(_selectedShippingAddressProvider);
      final selectedPayment = ref.read(_selectedPaymentMethodProvider);

      if (selectedAddressId == null) {
        throw Exception(l10n.translate('checkout_select_address_required'));
      }

      // Map payment method to API format
      String? paymentMethod;
      if (selectedPayment != null) {
        switch (selectedPayment) {
          case ProductPaymentMethod.stripe:
            paymentMethod = 'stripe';
            break;
          case ProductPaymentMethod.googlePay:
            paymentMethod = 'google_pay';
            break;
          case ProductPaymentMethod.creditCard:
            paymentMethod = 'credit_card';
            break;
          case ProductPaymentMethod.debitCard:
            paymentMethod = 'debit_card';
            break;
        }
      }

      // Get selected cart item IDs
      final selectedCartItemIds = ref.read(selectedCartItemsProvider);

      print('🔍 Selected cart item IDs for checkout: $selectedCartItemIds');
      print('🔍 Number of selected items: ${selectedCartItemIds.length}');

      // Ensure items are selected
      if (selectedCartItemIds.isEmpty) {
        throw Exception(l10n.translate('checkout_no_items_selected'));
      }

      // Prepare checkout data
      final checkoutData = {
        'shipping_address_id': selectedAddressId,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        // Always pass selected item IDs to API
        'items': selectedCartItemIds.toList(),
      };

      print('🔍 Checkout data being sent: $checkoutData');

      // Call checkout API
      final response = await ref.read(checkoutProvider(checkoutData).future);

      print('✅ Checkout successful! Order: ${response['order_number']}');
      print('📦 Items in order: ${(response['items'] as List?)?.length ?? 0}');

      // Hide loading snackbar
      if (context.mounted) {
        SnackbarUtils.hide(context);
      }

      // Refresh cart to get updated state from backend
      ref.invalidate(cartItemsProvider);
      ref.invalidate(cartCountProvider);

      // Clear selection
      ref.read(selectedCartItemsProvider.notifier).state = {};

      // Navigate to order success screen based on user role
      if (context.mounted) {
        final userRole = ref.read(effectiveUserRoleProvider);
        if (userRole?.toLowerCase() == 'manager') {
          context.pushNamed(AppRouteNames.managerOrderSuccess, extra: response);
        } else if (userRole?.toLowerCase() == 'member') {
          context.pushNamed(AppRouteNames.memberOrderSuccess, extra: response);
        } else {
          context.pushNamed(AppRouteNames.orderSuccess, extra: response);
        }
      }
    } catch (e) {
      // Hide loading snackbar on error
      if (context.mounted) {
        SnackbarUtils.hide(context);
        SnackbarUtils.showError(
          context,
          message: l10n.translate(
            'checkout_order_failed',
            params: {'error': e.cleanMessage},
          ),
        );
      }
    }
  }

  void _showAddAddressDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => _AddAddressDialog());
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit =
        double.tryParse(item.product.discountedPrice ?? '') ??
        double.tryParse(item.product.price) ??
        0.0;
    final lineTotal = unit * item.quantity;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.translate(
                    'checkout_item_unit',
                    params: {'price': unit.toStringAsFixed(2)},
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate(
                    'checkout_item_quantity',
                    params: {'quantity': item.quantity.toString()},
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${lineTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7C32),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final int totalQuantity;
  final double shippingFee;
  final double taxRate;

  const _OrderSummary({
    required this.subtotal,
    required this.totalQuantity,
    required this.shippingFee,
    required this.taxRate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('checkout_order_summary'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: l10n.translate('checkout_summary_items'),
            value: '$totalQuantity',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.translate('checkout_summary_subtotal'),
            value: 'Rs. ${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.translate('checkout_summary_shipping'),
            value: 'Rs. ${shippingFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.translate(
              'checkout_summary_tax',
              params: {'rate': ((taxRate * 100).toInt()).toString()},
            ),
            value: 'Rs. ${(subtotal * taxRate).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _SummaryRow(
            label: l10n.translate('checkout_summary_total'),
            value:
                'Rs. ${(subtotal + shippingFee + (subtotal * taxRate)).toStringAsFixed(2)}',
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            valueStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7C32),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final ProductPaymentMethod method;
  final String title;
  final IconData icon;
  final ProductPaymentMethod? selectedMethod;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.title,
    required this.icon,
    required this.selectedMethod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selectedMethod;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B7C32)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B7C32).withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF6B7C32)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF111827)
                      : const Color(0xFF374151),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF6B7C32), size: 24)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
                ),
              ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ShippingAddressCard extends StatelessWidget {
  final List<Map<String, dynamic>> addresses;
  final int? selectedAddress;
  final Function(int) onAddressSelected;
  final VoidCallback onAddNewAddress;

  const _ShippingAddressCard({
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6B7C32), width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: const Color(0xFF6B7C32),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.translate('checkout_addresses_empty_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('checkout_addresses_empty_subtitle'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddNewAddress,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.translate('checkout_addresses_add_button')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7C32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Find the selected address details
    final selectedAddressData = addresses.firstWhere(
      (address) => address['id'] == selectedAddress,
      orElse: () => addresses.first,
    );

    return GestureDetector(
      onTap: () => _showAddressBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedAddress != null
                ? const Color(0xFF6B7C32)
                : const Color(0xFFE5E7EB),
            width: selectedAddress != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selectedAddress != null
                    ? const Color(0xFF6B7C32).withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: selectedAddress != null
                    ? const Color(0xFF6B7C32)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAddress != null
                        ? '${selectedAddressData['first_name'] ?? ''} ${selectedAddressData['last_name'] ?? ''}'
                        : l10n.translate('checkout_address_select_placeholder'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedAddress != null
                          ? const Color(0xFF111827)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  if (selectedAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      selectedAddressData['address_line1'] ??
                          selectedAddressData['address'] ??
                          '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selectedAddressData['city'] ?? ''}${(selectedAddressData['city'] != null && selectedAddressData['state'] != null) ? ', ' : ''}${selectedAddressData['state'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: selectedAddress != null
                  ? const Color(0xFF6B7C32)
                  : const Color(0xFF9CA3AF),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressBottomSheet(
        addresses: const [], // Will be fetched inside the bottom sheet
        selectedAddress: selectedAddress,
        onAddressSelected: onAddressSelected,
        onAddNewAddress: onAddNewAddress,
      ),
    );
  }
}

class _AddressBottomSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> addresses;
  final int? selectedAddress;
  final Function(int) onAddressSelected;
  final VoidCallback onAddNewAddress;

  const _AddressBottomSheet({
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  });

  @override
  ConsumerState<_AddressBottomSheet> createState() =>
      _AddressBottomSheetState();
}

class _AddressBottomSheetState extends ConsumerState<_AddressBottomSheet>
    with WidgetsBindingObserver {
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh addresses when app resumes
      ref.invalidate(shippingAddressesProvider);
    }
  }

  Future<void> _retryAll() async {
    if (_retrying) return;

    setState(() {
      _retrying = true;
    });

    try {
      final l10n = context.l10n;
      // Check internet connectivity
      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            message: l10n.translate(
              'checkout_addresses_error_network_subtitle',
            ),
          );
        }
        return;
      }

      // Refresh addresses
      ref.invalidate(shippingAddressesProvider);
      await ref.read(shippingAddressesProvider.future);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: context.l10n.translate(
            'checkout_address_error',
            params: {'error': e.cleanMessage},
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _retrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  l10n.translate('checkout_address_select_placeholder'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),

          // Addresses list
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final addressesAsync = ref.watch(shippingAddressesProvider);

                return addressesAsync.when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_off,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.translate('checkout_addresses_none_title'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.translate(
                                  'checkout_addresses_none_subtitle',
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        final addressId = address['id'] as int;
                        final isSelected = widget.selectedAddress == addressId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              widget.onAddressSelected(addressId);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6B7C32).withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6B7C32)
                                      : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF6B7C32)
                                            : const Color(0xFFD1D5DB),
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? const Color(0xFF6B7C32)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${address['first_name'] ?? ''} ${address['last_name'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFF6B7C32)
                                                : const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          address['address_line1'] ??
                                              address['address'] ??
                                              '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? const Color(0xFF6B7C32)
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${address['city'] ?? ''}${(address['city'] != null && address['state'] != null) ? ', ' : ''}${address['state'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? const Color(0xFF6B7C32)
                                                : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isNetworkError(error)
                                ? Icons.wifi_off
                                : Icons.error_outline,
                            size: 48,
                            color: isNetworkError(error)
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isNetworkError(error)
                                ? l10n.translate(
                                    'checkout_addresses_error_network',
                                  )
                                : l10n.translate(
                                    'checkout_addresses_error_generic',
                                  ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isNetworkError(error)
                                ? l10n.translate(
                                    'checkout_addresses_error_network_subtitle',
                                  )
                                : l10n.translate(
                                    'checkout_addresses_error_generic_subtitle',
                                  ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _retrying ? null : _retryAll,
                            icon: _retrying
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.refresh, size: 16),
                            label: Text(
                              _retrying
                                  ? l10n.translate('checkout_retrying')
                                  : l10n.translate('retry'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B7C32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Add new address button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onAddNewAddress();
                },
                icon: const Icon(Icons.add, color: Color(0xFF6B7C32)),
                label: Text(
                  l10n.translate('checkout_add_address_title'),
                  style: const TextStyle(color: Color(0xFF6B7C32)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6B7C32)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressDialog extends ConsumerStatefulWidget {
  @override
  _AddAddressDialogState createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends ConsumerState<_AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = ref.watch(_isCreatingAddressProvider);
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        l10n.translate('checkout_add_address_title'),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_first_name'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate(
                        'checkout_field_first_name_required',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_last_name'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate(
                        'checkout_field_last_name_required',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Line 1
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_address_line1'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('checkout_field_address_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_city'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // State
                TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_state'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Zip Code
                TextFormField(
                  controller: _zipCodeController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_zip'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Country
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_country'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: l10n.translate('checkout_field_phone'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Default address checkbox
                CheckboxListTile(
                  title: Text(l10n.translate('checkout_set_default_address')),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isCreating ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.translate('common_cancel')),
        ),
        ElevatedButton(
          onPressed: isCreating ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B7C32),
            foregroundColor: Colors.white,
          ),
          child: isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(l10n.translate('checkout_add_address')),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      ref.read(_isCreatingAddressProvider.notifier).state = true;

      final addressData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'address_line1': _addressLine1Controller.text.trim(),
        'city': _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        'state': _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
        'zip_code': _zipCodeController.text.trim().isEmpty
            ? null
            : _zipCodeController.text.trim(),
        'country': _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'is_default': _isDefault,
      };

      await ref.read(createShippingAddressProvider(addressData).future);

      if (mounted) {
        Navigator.of(context).pop();
        SnackbarUtils.showSuccess(
          context,
          message: context.l10n.translate('checkout_address_success'),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: context.l10n.translate(
            'checkout_address_error',
            params: {'error': e.cleanMessage},
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(_isCreatingAddressProvider.notifier).state = false;
      }
    }
  }
}

class _Totals {
  final double subtotal;
  final int totalQuantity;
  const _Totals({required this.subtotal, required this.totalQuantity});
}
