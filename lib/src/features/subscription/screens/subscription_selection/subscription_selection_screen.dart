import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/subscription/models/subscription_plan.dart';
import 'package:udb_association/src/features/subscription/providers/subscription_provider.dart';
import 'package:udb_association/src/router/app_router.dart';

// Billing options removed - duration comes directly from API

// Provider to persist the current subscription type filter
final currentSubscriptionTypeProvider = StateProvider<String?>((ref) => null);

class SubscriptionSelectionScreen extends ConsumerWidget {
  final String? subscriptionType; // 'member' or 'vendor'

  const SubscriptionSelectionScreen({super.key, this.subscriptionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final l10n = context.l10n;

    // Update the persistent subscription type when screen loads
    if (subscriptionType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentSubscriptionTypeProvider.notifier).state =
            subscriptionType;
      });
    }

    // Use the persistent type, fallback to parameter
    final activeSubscriptionType =
        ref.watch(currentSubscriptionTypeProvider) ?? subscriptionType;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: activeSubscriptionType != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                onPressed: () {
                  // Clear the subscription type filter when going back
                  ref.read(currentSubscriptionTypeProvider.notifier).state =
                      null;
                  context.pop();
                },
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7C32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/icons/handshake_icon.png',
                    width: 18,
                    height: 18,
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
        title: Text(
          l10n.translate('subscription_selection_title'),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: subscriptionsAsync.when(
          data: (subscriptions) {
            // Filter subscriptions by type using the active subscription type
            final filteredSubscriptions = activeSubscriptionType != null
                ? subscriptions
                      .where(
                        (s) =>
                            s.plansFor.toLowerCase() ==
                            activeSubscriptionType.toLowerCase(),
                      )
                      .toList()
                : subscriptions;

            return _buildContent(context, ref, filteredSubscriptions);
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
                    'subscription_selection_error',
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
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SubscriptionPlan> subscriptions,
  ) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // all sides padding = 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('subscription_selection_heading'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          // Dynamically build plan cards from API data
          ...subscriptions.asMap().entries.map((entry) {
            final plan = entry.value;
            return Column(
              children: [
                _PlanCard(
                  plan: plan,
                  ref: ref,
                  headerBadge: plan.type.toLowerCase() == 'premium'
                      ? _Badge(
                          label: l10n.translate(
                            'subscription_selection_badge_popular',
                          ),
                        )
                      : null,
                ),
                if (entry.key < subscriptions.length - 1)
                  const SizedBox(height: 16),
              ],
            );
          }).toList(),

          // Note: Billing options removed - duration comes directly from API
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7C32), // batch color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.ref, this.headerBadge});

  final SubscriptionPlan plan;
  final WidgetRef ref;
  final Widget? headerBadge;

  // Determine color scheme based on plan type
  Color get _priceColor {
    final typeL = plan.type.toLowerCase();
    if (typeL == 'basic') return const Color(0xFF2563EB);
    if (typeL == 'premium') return const Color(0xFF6B7C32);
    if (typeL == 'enterprise') return const Color(0xFF111827);
    return const Color(0xFF2563EB); // default
  }

  Color get _buttonBg => _priceColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPremium = plan.type.toLowerCase() == 'premium';
    final displayPrice = plan.priceValue.toStringAsFixed(0);
    final planNameDisplay =
        plan.type.substring(0, 1).toUpperCase() + plan.type.substring(1);
    final isEnterprise = plan.type.toLowerCase() == 'enterprise';
    final isMemberPlan = plan.plansFor.toLowerCase() == 'member';
    final buttonLabel = isEnterprise
        ? l10n.translate('subscription_selection_button_contact_sales')
        : (isMemberPlan
              ? l10n.translate('subscription_selection_button_choose_generic')
              : l10n.translate(
                  'subscription_selection_button_choose',
                  params: {'plan': planNameDisplay},
                ));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPremium
                  ? const Color(0xFF6B7C32)
                  : const Color(0xFFE5E7EB),
              width: isPremium ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(17), // 17 px padding inside
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: plan name and price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planNameDisplay,
                          style: const TextStyle(
                            fontSize: 18, // plan type
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plan.quote,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$$displayPrice',
                          style: TextStyle(
                            color: _priceColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/${plan.duration}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Benefits
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final String item in plan.benefits) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 12,
                            color: Color(0xFF22C55E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),

                // Choose plan button
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to checkout with subscription ID and duration
                      context.goNamed(
                        AppRouteNames.subscriptionCheckout,
                        pathParameters: {
                          'subscriptionId': plan.id.toString(),
                          'billingOption':
                              plan.duration, // Use duration from API
                        },
                        queryParameters: {'plansFor': plan.plansFor},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonBg,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (headerBadge != null)
          Positioned(top: -10, left: 20, child: headerBadge!),
      ],
    );
  }
}

// _BillingOptionTile class removed - no longer needed
