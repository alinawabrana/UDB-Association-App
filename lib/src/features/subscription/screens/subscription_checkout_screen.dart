import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/subscription/models/subscription_plan.dart';
import 'package:udb_association/src/features/subscription/providers/subscription_provider.dart';
import 'package:udb_association/src/features/subscription/providers/billing_form_provider.dart';
import 'package:udb_association/src/features/subscription/widgets/billing_information_form.dart';
import 'package:udb_association/src/features/subscription/widgets/member_form.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';
import 'package:udb_association/src/router/app_router.dart';

// Payment Method Enum
enum PaymentMethod { stripe, googlePay, creditCard, debitCard }

// Payment Method Data
class PaymentMethodData {
  final String value;
  final String id;
  final String title;
  final IconData icon;

  const PaymentMethodData({
    required this.value,
    required this.id,
    required this.title,
    required this.icon,
  });
}

// Payment Method Mappings
const Map<PaymentMethod, PaymentMethodData> paymentMethodData = {
  PaymentMethod.stripe: PaymentMethodData(
    value: 'stripe',
    id: 'stripe_001',
    title: 'Stripe',
    icon: Icons.payment,
  ),
  PaymentMethod.googlePay: PaymentMethodData(
    value: 'google_pay',
    id: 'google_pay_001',
    title: 'Google Pay',
    icon: Icons.account_balance_wallet,
  ),
  PaymentMethod.creditCard: PaymentMethodData(
    value: 'credit_card',
    id: 'credit_card_001',
    title: 'Credit Card',
    icon: Icons.credit_card,
  ),
  PaymentMethod.debitCard: PaymentMethodData(
    value: 'debit_card',
    id: 'debit_card_001',
    title: 'Debit Card',
    icon: Icons.credit_card_outlined,
  ),
};

// Selected Payment Method Provider
final selectedPaymentMethodProvider = StateProvider<PaymentMethod?>(
  (ref) => null,
);

class SubscriptionCheckoutScreen extends ConsumerWidget {
  final int? subscriptionId;
  final String
  billingOption; // 'weekly', 'monthly', 'annual', etc. (duration from API)
  final String? plansFor; // 'member' or 'vendor'

  const SubscriptionCheckoutScreen({
    super.key,
    this.subscriptionId,
    this.billingOption = 'monthly',
    this.plansFor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final billingFormState = ref.watch(billingFormProvider);
    final memberFormState = ref.watch(memberFormProvider);
    final profileAsync = ref.watch(profileProvider);
    final isAnnual = billingOption.toLowerCase() == 'annual';
    final isMemberPlan = plansFor?.toLowerCase() == 'member';
    final isUserPlan = plansFor?.toLowerCase() == 'user';
    final l10n = context.l10n;

    // Prefill billing form with user data when profile loads (only once) - only for vendor
    if (!isMemberPlan && !isUserPlan) {
      profileAsync.whenData((user) {
        final currentState = ref.read(billingFormProvider);
        // Only prefill if the form is empty (first time loading)
        if (currentState.customerEmail.isEmpty &&
            currentState.customerName.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(billingFormProvider.notifier)
                .prefillWithUserData(
                  email: user.email,
                  name: user.name.isNotEmpty 
                      ? user.name 
                      : ((user.firstName ?? '') + ' ' + (user.surname ?? '')).trim().isNotEmpty
                          ? ((user.firstName ?? '') + ' ' + (user.surname ?? '')).trim()
                          : (user.email.isNotEmpty ? user.email.split('@').first : 'User'),
                  phone: user.phone,
                  address: user.address,
                  businessName: user.businessName,
                  shopDetails: user.shopDetails,
                );
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () {
            // Pop and maintain the subscription type in the URL
            context.pop();
          },
        ),
        title: Text(
          l10n.translate('subscription_checkout_title'),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          // Extract the subscription by ID
          final subscription = subscriptions.firstWhere(
            (s) => s.id == subscriptionId,
            orElse: () => subscriptions.first,
          );
          return _buildCheckoutContent(
            context,
            ref,
            subscription,
            selectedPaymentMethod,
            billingFormState,
            memberFormState,
            isAnnual,
            isMemberPlan,
            isUserPlan,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.translate(
                  'subscription_checkout_error',
                  params: {'error': err.toString()},
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(subscriptionsProvider),
                child: Text(l10n.translate('retry')),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }

  Widget _buildCheckoutContent(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan subscription,
    PaymentMethod? selectedPayment,
    BillingFormState billingFormState,
    MemberFormState memberFormState,
    bool isAnnual,
    bool isMemberPlan,
    bool isUserPlan,
  ) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show different forms based on plan type
                if (!isMemberPlan && !isUserPlan) ...[
                  // Billing Information Form (for vendors only)
                  const BillingInformationForm(),
                  const SizedBox(height: 24),
                ],

                if (isMemberPlan) ...[
                  // Member Form with Branch Selection (for members only)
                  const MemberForm(),
                  const SizedBox(height: 24),
                ],

                // Subscription Summary Card
                _SubscriptionSummaryCard(
                  subscription: subscription,
                  l10n: l10n,
                ),

                const SizedBox(height: 24),

                // Payment Methods Section - only for vendor plans
                if (!isMemberPlan && !isUserPlan) ...[
                  Text(
                    l10n.translate('checkout_payment_methods'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...PaymentMethod.values.map((method) {
                    final methodData = paymentMethodData[method]!;
                    return Column(
                      children: [
                        _PaymentMethodTile(
                          method: method,
                          title: methodData.title,
                          icon: methodData.icon,
                          selectedMethod: selectedPayment,
                          onTap: () =>
                              ref
                                      .read(
                                        selectedPaymentMethodProvider.notifier,
                                      )
                                      .state =
                                  method,
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),
                ],

                // Order Summary
                _OrderSummary(
                  subscription: subscription,
                  isAnnual: isAnnual,
                  l10n: l10n,
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Button
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
                    _isCheckoutEnabled(
                      isMemberPlan,
                      isUserPlan,
                      selectedPayment,
                      billingFormState,
                      memberFormState,
                    )
                    ? () => _handleCheckout(
                        context,
                        ref,
                        subscription,
                        selectedPayment,
                        billingFormState,
                        memberFormState,
                        isMemberPlan,
                        isUserPlan,
                      )
                    : null,
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
                child: Builder(
                  builder: (context) {
                    final isLoading = (isMemberPlan || isUserPlan)
                        ? memberFormState.isLoading
                        : billingFormState.isLoading;

                    if (isLoading) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.translate('subscription_checkout_processing'),
                          ),
                        ],
                      );
                    }

                    if (isMemberPlan || isUserPlan) {
                      return Text(
                        l10n.translate('subscription_checkout_submit_request'),
                      );
                    } else {
                      final totalAmount = _calculateTotal(
                        subscription,
                        isAnnual,
                      );
                      return Text(
                        l10n.translate(
                          'subscription_checkout_pay_amount',
                          params: {'amount': totalAmount.toStringAsFixed(2)},
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isCheckoutEnabled(
    bool isMemberPlan,
    bool isUserPlan,
    PaymentMethod? selectedPayment,
    BillingFormState billingFormState,
    MemberFormState memberFormState,
  ) {
    if (isMemberPlan) {
      // For member plans, check if branch is selected
      return memberFormState.isFormValid && !memberFormState.isLoading;
    } else if (isUserPlan) {
      // For user plans, no form validation needed since we only need subscription ID
      return !memberFormState.isLoading;
    } else {
      // For vendor plans, check payment method and billing form
      return selectedPayment != null &&
          billingFormState.isFormValid &&
          !billingFormState.isLoading;
    }
  }

  double _calculateTotal(SubscriptionPlan subscription, bool isAnnual) {
    if (!isAnnual) {
      return subscription.priceValue;
    }

    // Apply discount for annual billing
    if (subscription.discountedPriceValue != null) {
      return subscription.discountedPriceValue!;
    }

    // If no discounted price but has discount percentage, calculate it
    if (subscription.discountValue != null &&
        subscription.discountType == 'percentage') {
      final discountPercent = double.tryParse(subscription.discountValue!) ?? 0;
      final discount = subscription.priceValue * (discountPercent / 100);
      return subscription.priceValue - discount;
    }

    return subscription.priceValue;
  }

  Future<void> _handleCheckout(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan subscription,
    PaymentMethod? paymentMethod,
    BillingFormState billingFormState,
    MemberFormState memberFormState,
    bool isMemberPlan,
    bool isUserPlan,
  ) async {
    final l10n = context.l10n;
    try {
      // Get auth token
      final token = ref.read(authTokenProvider);
      if (token == null) {
        throw Exception(
          l10n.translate('subscription_checkout_user_not_authenticated'),
        );
      }

      // Get subscription service
      final subscriptionService = ref.read(subscriptionServiceProvider);

      if (isMemberPlan) {
        // Handle member checkout - use member-specific API with branch ID
        ref.read(memberFormProvider.notifier).setLoading(true);

        await subscriptionService.submitMemberRequest(
          token: token,
          subscriptionId: subscriptionId ?? 1,
          branchId: memberFormState.branchId ?? 1,
        );

        ref.read(memberFormProvider.notifier).setLoading(false);
      } else if (isUserPlan) {
        // Handle user checkout - use the user subscription checkout API
        ref.read(memberFormProvider.notifier).setLoading(true);

        await subscriptionService.processUserSubscriptionCheckout(
          token: token,
          subscriptionId: subscriptionId ?? 1,
        );

        ref.read(memberFormProvider.notifier).setLoading(false);
      } else {
        // Handle vendor checkout
        ref.read(billingFormProvider.notifier).setLoading(true);

        // Get payment method data
        final methodData = paymentMethodData[paymentMethod]!;

        await subscriptionService.processCheckout(
          token: token,
          subscriptionId: subscriptionId ?? 1,
          billingAddress: billingFormState.billingAddress,
          customerEmail: billingFormState.customerEmail,
          customerName: billingFormState.customerName,
          phone: billingFormState.phone,
          businessName: billingFormState.businessName,
          shopTagline: billingFormState.shopTagline,
          shopDetail: billingFormState.shopDetail,
          paymentMethod: methodData.value,
          paymentMethodId: methodData.id,
        );

        ref.read(billingFormProvider.notifier).setLoading(false);
      }

      // Handle post-checkout navigation based on user role
      if (isUserPlan) {
        // For user role, no logout required - navigate to product by category screen
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.translate('subscription_checkout_user_success'),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF22C55E),
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to product by category screen
          context.goNamed(AppRouteNames.home);
        }
      } else {
        // For member and vendor roles, logout and navigate to welcome screen
        ref.read(authTokenProvider.notifier).state = null;
        await const TokenStorage().clearToken();
        ref.invalidate(loginProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isMemberPlan
                    ? l10n.translate('subscription_checkout_member_success')
                    : l10n.translate('subscription_checkout_vendor_success'),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF22C55E),
              duration: const Duration(seconds: 5),
            ),
          );

          // Navigate to welcome screen
          context.goNamed(AppRouteNames.welcome);
        }
      }
    } catch (error) {
      print('CHECKOUT ERROR: $error');
      // Handle error
      if (isMemberPlan || isUserPlan) {
        ref.read(memberFormProvider.notifier).setError(error.toString());
        ref.read(memberFormProvider.notifier).setLoading(false);
      } else {
        ref.read(billingFormProvider.notifier).setError(error.toString());
        ref.read(billingFormProvider.notifier).setLoading(false);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUserPlan
                  ? l10n.translate(
                      'subscription_checkout_activation_failed',
                      params: {'error': error.toString()},
                    )
                  : (isMemberPlan
                        ? l10n.translate(
                            'subscription_checkout_request_failed',
                            params: {'error': error.toString()},
                          )
                        : l10n.translate(
                            'subscription_checkout_payment_failed',
                            params: {'error': error.toString()},
                          )),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Subscription Summary Card Widget
class _SubscriptionSummaryCard extends StatelessWidget {
  final SubscriptionPlan subscription;
  final AppLocalizations l10n;

  const _SubscriptionSummaryCard({
    required this.subscription,
    required this.l10n,
  });

  Color get _accentColor {
    final typeL = subscription.type.toLowerCase();
    if (typeL == 'basic') return const Color(0xFF2563EB);
    if (typeL == 'premium') return const Color(0xFF6B7C32);
    if (typeL == 'enterprise') return const Color(0xFF111827);
    return const Color(0xFF6B7C32);
  }

  @override
  Widget build(BuildContext context) {
    final planNameDisplay =
        subscription.type.substring(0, 1).toUpperCase() +
        subscription.type.substring(1);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate(
                  'subscription_summary_plan_label',
                  params: {'plan': planNameDisplay},
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subscription.duration.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subscription.quote,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          Text(
            l10n.translate('subscription_summary_includes'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          ...subscription.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Payment Method Tile Widget
class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final String title;
  final IconData icon;
  final PaymentMethod? selectedMethod;
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

// Order Summary Widget
class _OrderSummary extends StatelessWidget {
  final SubscriptionPlan subscription;
  final bool isAnnual;
  final AppLocalizations l10n;

  const _OrderSummary({
    required this.subscription,
    required this.isAnnual,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = subscription.priceValue;

    // Calculate discount only for annual billing
    double discount = 0.0;
    double total = subtotal;

    if (isAnnual) {
      if (subscription.discountedPriceValue != null) {
        total = subscription.discountedPriceValue!;
        discount = subtotal - total;
      } else if (subscription.discountValue != null &&
          subscription.discountType == 'percentage') {
        final discountPercent =
            double.tryParse(subscription.discountValue!) ?? 0;
        discount = subtotal * (discountPercent / 100);
        total = subtotal - discount;
      }
    }

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
            l10n.translate('subscription_order_summary'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: l10n.translate('subscription_order_subtotal'),
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          if (discount > 0) ...[
            const SizedBox(height: 12),
            _SummaryRow(
              label: l10n.translate('subscription_order_discount'),
              value: '-\$${discount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF22C55E),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _SummaryRow(
            label: l10n.translate('subscription_order_total'),
            value: '\$${total.toStringAsFixed(2)}',
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
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.valueColor,
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
