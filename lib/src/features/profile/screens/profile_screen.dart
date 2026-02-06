import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
// import 'package:udb_association/src/common/widgets/heading_tile.dart'; // COMMENTED OUT - HeadingTile is no longer used
import 'package:udb_association/src/features/auth/models/user_model.dart';
// import 'package:udb_association/src/features/profile/widgets/Profile_overview_card.dart'; // COMMENTED OUT - ProfileOverviewCard is no longer used
import 'package:udb_association/src/features/profile/widgets/profile_header.dart';
import 'package:udb_association/src/features/shop/providers/order_provider.dart';
import 'package:udb_association/src/features/shop/widgets/order_card.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/network/error_utils.dart';
import 'package:udb_association/utils/network/connectivity.dart';

import '../../auth/provider/auth_providers.dart';
import '../provider/profile_image_provider.dart';
// import '../widgets/profile_history_tile.dart'; // COMMENTED OUT - PaymentHistoryTile is no longer used
import '../widgets/profile_information_section.dart';
import '../widgets/membership_status_section.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';
import 'package:udb_association/src/features/auth/provider/user_role_fallback_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_request_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/src/features/subscription/providers/subscription_booking_provider.dart';
import 'package:udb_association/src/features/chat/providers/chat_providers.dart';
import 'package:udb_association/src/features/notifications/providers/notification_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with WidgetsBindingObserver, RouteAware {
  bool _isLoggingOut = false;
  bool _isRefreshingOrders = false;

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
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh orders when app comes back to foreground
      ref.invalidate(ordersProvider);
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another screen
    super.didPopNext();
    // Refresh orders when returning to profile screen
    ref.invalidate(ordersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final selectedImage = ref.watch(selectedProfileImageProvider);
    final l10n = context.l10n;
    return Scaffold(
      body: _isLoggingOut
          ? const Center(child: CircularProgressIndicator())
          : profile.when(
              data: (user) => _buildProfile(user, context, selectedImage),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isNetworkError(err)
                          ? l10n.translate('no_internet_connection')
                          : l10n.translate('profile_error_load'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isNetworkError(err)
                          ? l10n.translate('check_connection_try_again')
                          : '$err',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        final online = await hasInternetConnection();
                        if (!online) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.translate('no_internet_connection'),
                                ),
                              ),
                            );
                          }
                          return;
                        }
                        // Refresh profile and wait for completion
                        final future = ref.refresh(profileProvider.future);
                        await future;
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7C32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.translate('retry')),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoggingOut
                ? null
                : () async {
                    setState(() {
                      _isLoggingOut = true;
                    });

                    // Clear token first
                    ref.read(authTokenProvider.notifier).state = null;
                    await const TokenStorage().clearToken();

                    // Invalidate ALL user-related providers to reset state
                    ref.invalidate(loginProvider);
                    ref.invalidate(profileProvider);
                    // Invalidate notification-related providers
                    ref.invalidate(unreadNotificationsCountProvider);
                    ref.invalidate(notificationsProvider);
                    ref.invalidate(enhancedNotificationsProvider);
                    ref.invalidate(cartCountProvider);
                    ref.invalidate(cartItemsProvider);
                    ref.invalidate(ordersProvider);
                    ref.invalidate(userRoleFallbackProvider);
                    ref.invalidate(selectedProfileImageProvider);

                    // Invalidate subscription-related providers
                    ref.invalidate(userSubscriptionRequestsProvider);
                    ref.invalidate(currentUserSubscriptionRequestProvider);
                    ref.invalidate(userHasApprovedSubscriptionProvider);
                    ref.invalidate(userSubscriptionStatusProvider);

                    // Invalidate chat-related providers
                    ref.invalidate(chatsProvider);
                    ref.invalidate(chatStateProvider);
                    ref.read(currentChatIdProvider.notifier).state = null;
                    ref.read(messageInputProvider.notifier).state = '';
                    ref.read(isTypingProvider.notifier).state = false;
                    // Disconnect WebSocket
                    try {
                      await ref.read(webSocketServiceProvider).disconnect();
                    } catch (_) {}

                    // Clear cart state providers
                    ref.read(cartItemsCountProvider.notifier).state = 0;
                    ref.read(productCartQuantityProvider.notifier).state = {};
                    ref.read(productCartItemIdProvider.notifier).state = {};
                    ref.read(selectedCartItemsProvider.notifier).state = {};

                    if (mounted) {
                      context.goNamed(AppRouteNames.welcome);
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6B7C32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoggingOut)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                Text(l10n.translate('logout')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(User user, BuildContext context, File? selectedImage) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh orders when user pulls down
        ref.invalidate(ordersProvider);
        // Wait for the refresh to complete
        await ref.read(ordersProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          spacing: 16,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Profile Header (no camera icon in view mode)
                ProfileHeader(user: user, selectedImage: selectedImage),

                // Profile OverView Card (Don't show for "user" and "vendor" roles)
                // COMMENTED OUT FOR ALL USERS
                // if ((user.role ?? 'user').toLowerCase() != 'user' &&
                //     (user.role ?? 'user').toLowerCase() != 'vendor')
                //   ProfileOverviewCard(),
              ],
            ),
            // Adjust spacing based on whether ProfileOverviewCard is shown
            // ProfileOverviewCard is now commented out for all users, so no spacing needed
            // SizedBox(
            //   height:
            //       ((user.role ?? 'user').toLowerCase() == 'user' ||
            //           (user.role ?? 'user').toLowerCase() == 'vendor')
            //       ? 0
            //       : 60,
            // ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Column(
                    spacing: 32,
                    children: [
                      PersonalInformationSection(user: user),
                      // Show orders for all users
                      _buildOrdersSection(user),
                      // Show payment history for vendors
                      // COMMENTED OUT FOR ALL USERS
                      // if (user.role == 'vendor') _buildPaymentHistorySection(),
                      // Show membership status with specific conditions
                      _buildMembershipStatusSection(user),
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

  Widget _buildOrdersSection(User user) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
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
          // Section Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Iconsax.shopping_bag5,
                  color: const Color(0xFF6B7B47),
                  size: 16,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.translate('profile_orders_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isRefreshingOrders
                      ? null
                      : () async {
                          setState(() {
                            _isRefreshingOrders = true;
                          });
                          try {
                            ref.invalidate(ordersProvider);
                            await ref.read(ordersProvider.future);
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isRefreshingOrders = false;
                              });
                            }
                          }
                        },
                  icon: _isRefreshingOrders
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6B7B47),
                          ),
                        )
                      : const Icon(Iconsax.refresh_circle),
                  tooltip: _isRefreshingOrders
                      ? l10n.translate('profile_orders_refreshing')
                      : l10n.translate('profile_orders_refresh_tooltip'),
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7B47),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    context.goNamed(AppRouteNames.orders);
                  },
                  child: Text(
                    l10n.translate('common_view_all'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider (full width)
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (context, ref, child) {
                final ordersAsync = ref.watch(ordersProvider);

                return ordersAsync.when(
                  data: (ordersResponse) {
                    final orders = ordersResponse.data;
                    if (orders.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Iconsax.shopping_bag,
                              size: 48,
                              color: Color(0xFF6B7B47),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.translate('profile_orders_empty_title'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.translate('profile_orders_empty_subtitle'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show only the 2 most recent orders
                    final recentOrders = orders.take(2).toList();
                    final userName = user.name;

                    return Column(
                      spacing: 12,
                      children: recentOrders
                          .map(
                            (order) =>
                                OrderCard(order: order, userName: userName),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.translate('profile_orders_error_title'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(ordersProvider);
                          },
                          child: Text(l10n.translate('retry')),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipStatusSection(User user) {
    final userRole = (user.role ?? 'user').toLowerCase();

    // Don't show for managers
    if (userRole == 'manager') {
      return const SizedBox.shrink();
    }

    // For users, always show subscription status card
    if (userRole == 'user') {
      return Consumer(
        builder: (context, ref, child) {
          final subscriptionStatusAsync = ref.watch(
            userSubscriptionStatusProvider,
          );

          return subscriptionStatusAsync.when(
            data: (status) {
              // Always show the card for users, but with different content based on status
              return MembershipStatusSection(
                userRole: 'user',
                subscriptionStatus: status,
              );
            },
            loading: () => const MembershipStatusSection(
              userRole: 'user',
              subscriptionStatus: UserSubscriptionStatus.loading,
            ),
            error: (_, __) => const MembershipStatusSection(
              userRole: 'user',
              subscriptionStatus: UserSubscriptionStatus.noSubscription,
            ),
          );
        },
      );
    }

    // For members and vendors, always show membership status card using subscription-bookings API
    if (userRole == 'member' || userRole == 'vendor') {
      print('=== ${userRole.toUpperCase()} ROLE DETECTED ===');
      return Consumer(
        builder: (context, ref, child) {
          final subscriptionBookingAsync = ref.watch(
            currentUserSubscriptionProvider,
          );

          return subscriptionBookingAsync.when(
            data: (subscription) {
              print('=== ${userRole.toUpperCase()} SUBSCRIPTION DATA ===');
              print('Subscription: $subscription');
              // Always show the card for members and vendors
              return MembershipStatusSection(
                userRole: userRole,
                subscriptionBooking: subscription,
              );
            },
            loading: () {
              print('Loading ${userRole} subscription...');
              return MembershipStatusSection(
                userRole: userRole,
                subscriptionBooking: null,
              );
            },
            error: (error, stack) {
              print('Error loading ${userRole} subscription: $error');
              return MembershipStatusSection(
                userRole: userRole,
                subscriptionBooking: null,
              );
            },
          );
        },
      );
    }

    // Show for all other roles (admin, vendor, etc.)
    return const MembershipStatusSection();
  }

  // COMMENTED OUT - Payment History section is no longer used for any users
  // Widget _buildPaymentHistorySection() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFFFFFFF),
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Section Title
  //         const Padding(
  //           padding: EdgeInsets.all(16),
  //           child: HeadingTile(
  //             icon: Iconsax.card5,
  //             headingTitle: 'Payment History',
  //             isViewAll: true,
  //           ),
  //         ),

  //         // Divider (full width)
  //         const Divider(height: 1, color: Color(0xFFE5E7EB)),

  //         // Content - alternating tiles and dividers
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           child: PaymentHistoryTile(
  //             title: 'Annual MemberShip',
  //             subTitle: 'Dec 15, 2024',
  //             price: 120,
  //             isPaid: true,
  //           ),
  //         ),
  //         const Divider(height: 1, color: Color(0xFFE5E7EB)),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           child: PaymentHistoryTile(
  //             title: 'Annual MemberShip',
  //             subTitle: 'Dec 15, 2024',
  //             price: 120,
  //             isPaid: true,
  //           ),
  //         ),
  //         const Divider(height: 1, color: Color(0xFFE5E7EB)),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           child: PaymentHistoryTile(
  //             title: 'Annual MemberShip',
  //             subTitle: 'Dec 15, 2024',
  //             price: 120,
  //             isPaid: false,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
