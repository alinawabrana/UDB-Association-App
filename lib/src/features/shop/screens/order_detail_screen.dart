import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/shop/models/order_model.dart';
import 'package:udb_association/src/features/shop/services/order_service.dart';
import 'package:udb_association/src/features/shop/services/review_service.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late Future<OrderModel> _orderFuture;

  // Review form state
  final Map<int, int> _productRatings = {}; // productId -> rating
  final Map<int, TextEditingController> _reviewTextControllers = {};
  final Map<int, TextEditingController> _titleControllers = {};
  final Map<int, bool> _submittingReviews =
      {}; // Track submission state per product

  @override
  void initState() {
    super.initState();
    _orderFuture = OrderService.getOrderById(widget.orderId);
  }

  @override
  void dispose() {
    // Dispose all text controllers
    _reviewTextControllers.values.forEach((controller) => controller.dispose());
    _titleControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('order_details_title')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<OrderModel>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('❌ ORDER_DETAIL_SCREEN ERROR: Failed to load order details');
            print('Error: ${snapshot.error}');
            if (snapshot.stackTrace != null) {
              print('Stack trace: ${snapshot.stackTrace}');
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.translate('order_details_load_failed'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _orderFuture = OrderService.getOrderById(
                          widget.orderId,
                        );
                      });
                    },
                    child: Text(context.l10n.translate('retry')),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                _buildOrderHeader(order),
                const SizedBox(height: 24),

                // Order Items
                _buildOrderItems(order),
                const SizedBox(height: 24),

                // Order Summary
                _buildOrderSummary(order),
                const SizedBox(height: 24),

                // Shipping Address
                _buildShippingAddress(order.shippingAddress),

                // Review Section (Only for delivered orders)
                if (order.status.toLowerCase() == 'delivered') ...[
                  const SizedBox(height: 24),
                  _buildReviewSection(order),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate(
                  'order_number_display',
                  params: {'number': order.orderNumber},
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _translateStatus(l10n, order.status),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate(
              'order_detail_ordered_on',
              params: {'date': _formatDate(order.createdAt)},
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Iconsax.card,
                size: 16,
                color: _getPaymentStatusColor(order.paymentStatus),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.translate(
                  'order_payment_status_display',
                  params: {
                    'status': _translatePaymentStatus(
                      l10n,
                      order.paymentStatus,
                    ),
                  },
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getPaymentStatusColor(order.paymentStatus),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('order_items_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    final l10n = context.l10n;
    final sku = item.product.sku;
    final skuDisplay = sku.isEmpty ? '-' : sku;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.product.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Iconsax.box,
                          color: Color(0xFF6B7280),
                        );
                      },
                    ),
                  )
                : const Icon(Iconsax.box, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate(
                    'order_detail_sku',
                    params: {'sku': skuDisplay},
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate(
                    'order_item_quantity',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.discountedPrice != null) ...[
                // Show discounted price prominently
                Text(
                  '\$${item.discountedPrice}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
                // Show original price with strikethrough
                Text(
                  '\$${item.price}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ] else
                // Show original price if no discount
                Text(
                  '\$${item.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('order_summary_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            l10n.translate('order_summary_subtotal'),
            '\$${order.subtotal}',
          ),
          _buildSummaryRow(
            l10n.translate('order_summary_shipping_fee'),
            '\$${order.shippingFee}',
          ),
          _buildSummaryRow(
            l10n.translate('order_summary_tax'),
            '\$${order.tax}',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            l10n.translate('order_summary_total'),
            '\$${order.totalAmount}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal
                  ? const Color(0xFF111827)
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(ShippingAddress address) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('order_shipping_address_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${address.firstName} ${address.lastName}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.addressLine1,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          if (address.addressLine2 != null) ...[
            Text(
              address.addressLine2!,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
          Text(
            '${address.city}, ${address.state} ${address.zipCode}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          Text(
            address.country,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate(
              'order_phone_label',
              params: {'phone': address.phone},
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  String _translateStatus(AppLocalizations l10n, String status) {
    final key = 'order_status_${status.toLowerCase()}';
    final translated = l10n.translate(key);
    return translated == key ? status.toUpperCase() : translated;
  }

  String _translatePaymentStatus(AppLocalizations l10n, String status) {
    final key = 'order_payment_status_${status.toLowerCase()}';
    final translated = l10n.translate(key);
    return translated == key ? status.toUpperCase() : translated;
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'processing':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildReviewSection(OrderModel order) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.star, size: 20, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                l10n.translate('order_review_section_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.translate('order_review_section_subtitle'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          // Review form for each product
          ...order.items.map((item) => _buildProductReviewForm(item)),
        ],
      ),
    );
  }

  Widget _buildProductReviewForm(OrderItem item) {
    final l10n = context.l10n;
    final productId = item.product.id;

    // Initialize controllers if not already initialized
    if (!_reviewTextControllers.containsKey(productId)) {
      _reviewTextControllers[productId] = TextEditingController();
      _titleControllers[productId] = TextEditingController();
      _submittingReviews[productId] = false;
    }

    final isSubmitting = _submittingReviews[productId] ?? false;
    final rating = _productRatings[productId] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: item.product.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          item.product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Iconsax.box,
                              size: 20,
                              color: Color(0xFF6B7280),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Iconsax.box,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating (Required)
          Text(
            l10n.translate('order_review_rating_label'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _productRatings[productId] = starValue;
                        });
                      },
                child: Icon(
                  rating >= starValue ? Iconsax.star1 : Iconsax.star,
                  size: 32,
                  color: rating >= starValue
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD1D5DB),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Title (Optional)
          TextField(
            controller: _titleControllers[productId],
            enabled: !isSubmitting,
            decoration: InputDecoration(
              labelText: l10n.translate('order_review_title_label'),
              hintText: l10n.translate('order_review_title_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 12),

          // Review Text (Optional)
          TextField(
            controller: _reviewTextControllers[productId],
            enabled: !isSubmitting,
            decoration: InputDecoration(
              labelText: l10n.translate('order_review_body_label'),
              hintText: l10n.translate('order_review_body_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: 12),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting || rating == 0
                  ? null
                  : () => _submitReview(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: const Color(0xFFD1D5DB),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.translate('order_review_submit_button'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview(OrderItem item) async {
    final productId = item.product.id;
    final rating = _productRatings[productId];

    if (rating == null || rating == 0) {
      SnackbarUtils.showError(
        context,
        message: context.l10n.translate('order_review_select_rating_error'),
      );
      return;
    }

    setState(() {
      _submittingReviews[productId] = true;
    });

    try {
      final reviewText = _reviewTextControllers[productId]?.text.trim();
      final title = _titleControllers[productId]?.text.trim();

      await ReviewService.submitReview(
        productId: productId,
        rating: rating,
        reviewText: reviewText?.isEmpty == true ? null : reviewText,
        title: title?.isEmpty == true ? null : title,
      );

      if (mounted) {
        // Clear form after successful submission
        setState(() {
          _productRatings.remove(productId);
          _reviewTextControllers[productId]?.clear();
          _titleControllers[productId]?.clear();
          _submittingReviews[productId] = false;
        });

        SnackbarUtils.showSuccess(
          context,
          message: context.l10n.translate(
            'order_review_submit_success',
            params: {'product': item.product.name},
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submittingReviews[productId] = false;
        });

        SnackbarUtils.showError(
          context,
          message: context.l10n.translate(
            'order_review_submit_error',
            params: {'error': e.cleanMessage},
          ),
        );
      }
    }
  }
}
