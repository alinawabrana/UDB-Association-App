import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/src/features/auth/provider/user_role_fallback_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';

class OrderSuccessScreen extends ConsumerWidget {
  final Map<String, dynamic> orderData;

  const OrderSuccessScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final orderNumber = (orderData['order_number'] ?? 'N/A').toString();
    final totalAmount = (orderData['total_amount'] ?? '0.00').toString();
    final status = (orderData['status'] ?? 'pending').toString();
    final paymentStatus = (orderData['payment_status'] ?? 'paid').toString();
    final items = orderData['items'] as List<dynamic>? ?? [];
    final shippingAddress =
        orderData['shipping_address'] as Map<String, dynamic>? ?? {};

    String translateStatus(String value) {
      final key = 'order_status_${value.toLowerCase()}';
      final translated = l10n.translate(key);
      return translated == key ? value.toUpperCase() : translated;
    }

    String translatePaymentStatus(String value) {
      final key = 'order_payment_status_${value.toLowerCase()}';
      final translated = l10n.translate(key);
      return translated == key ? value.toUpperCase() : translated;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => _handleBackNavigation(context, ref),
        ),
        title: Text(
          l10n.translate('order_confirmation_title'),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('order_success_message'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate(
                      'order_number_display',
                      params: {'number': orderNumber},
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7C32),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order Summary
            Text(
              l10n.translate('order_summary_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: l10n.translate('order_number_label'),
                    value: orderNumber,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: l10n.translate('order_status_label'),
                    value: translateStatus(status),
                    valueColor: const Color(0xFF6B7C32),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: l10n.translate('order_payment_status_label'),
                    value: translatePaymentStatus(paymentStatus),
                    valueColor: paymentStatus == 'paid'
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: l10n.translate('order_total_amount_label'),
                    value: 'Rs. $totalAmount',
                    valueColor: const Color(0xFF111827),
                    valueStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Shipping Address
            Text(
              l10n.translate('order_shipping_address_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${shippingAddress['first_name'] ?? ''} ${shippingAddress['last_name'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shippingAddress['address_line1'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (shippingAddress['city'] != null ||
                      shippingAddress['state'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${shippingAddress['city'] ?? ''}${(shippingAddress['city'] != null && shippingAddress['state'] != null) ? ', ' : ''}${shippingAddress['state'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order Items
            if (items.isNotEmpty) ...[
              Text(
                l10n.translate('order_items_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Column(
                  children: items.map((item) {
                    final product =
                        item['product'] as Map<String, dynamic>? ?? {};
                    final quantity = item['quantity'] ?? 1;
                    final price = item['price'] ?? '0.00';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shopping_bag,
                              color: Color(0xFF9CA3AF),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ??
                                      l10n.translate('order_product_fallback'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.translate(
                                    'order_item_quantity',
                                    params: {'quantity': quantity.toString()},
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
                            l10n.translate(
                              'order_item_price',
                              params: {'price': price.toString()},
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7C32),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (items.isEmpty) ...[
              Text(
                l10n.translate('order_items_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('order_items_empty'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleBackNavigation(context, ref),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6B7C32)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.translate('order_back_to_cart'),
                      style: const TextStyle(color: Color(0xFF6B7C32)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleContinueShopping(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7C32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.translate('order_continue_shopping')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }

  void _handleBackNavigation(BuildContext context, WidgetRef ref) {
    final userRole = ref.read(effectiveUserRoleProvider)?.toLowerCase();
    final hasApprovedSubscription = ref.read(
      userHasApprovedSubscriptionProvider,
    );

    final isSpecialUser =
        userRole == 'user' &&
        hasApprovedSubscription.maybeWhen(
          data: (value) => value,
          orElse: () => false,
        );

    if (userRole == 'manager') {
      context.goNamed(AppRouteNames.appCart);
    } else if (userRole == 'member') {
      context.goNamed(AppRouteNames.memberCart);
    } else if (isSpecialUser) {
      context.goNamed(AppRouteNames.userCart);
    } else {
      context.goNamed(AppRouteNames.homeCart);
    }
  }

  void _handleContinueShopping(BuildContext context, WidgetRef ref) {
    final userRole = ref.read(effectiveUserRoleProvider)?.toLowerCase();
    final hasApprovedSubscription = ref.read(
      userHasApprovedSubscriptionProvider,
    );

    final isSpecialUser =
        userRole == 'user' &&
        hasApprovedSubscription.maybeWhen(
          data: (value) => value,
          orElse: () => false,
        );

    if (userRole == 'manager') {
      context.goNamed(AppRouteNames.managerShopProducts);
    } else if (userRole == 'member') {
      context.goNamed(AppRouteNames.memberShopProducts);
    } else if (isSpecialUser) {
      context.goNamed(AppRouteNames.userProduct);
    } else {
      context.goNamed(AppRouteNames.home);
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF111827),
              ),
        ),
      ],
    );
  }
}
