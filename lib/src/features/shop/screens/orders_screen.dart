import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/shop/providers/order_provider.dart';
import 'package:udb_association/src/features/shop/services/order_service.dart';
import 'package:udb_association/src/features/shop/widgets/order_card.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/network/connectivity.dart';
import 'package:udb_association/utils/network/error_utils.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _currentPage = 1;
  bool _isLoadingMore = false;
  List<dynamic> _allOrders = [];
  bool _hasMoreData = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('profile_orders_title')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final ordersAsync = ref.watch(ordersProvider);
          final userAsync = ref.watch(profileProvider);

          return ordersAsync.when(
            data: (ordersResponse) {
              final orders = ordersResponse.data;

              // Initialize _allOrders with first page data
              if (_currentPage == 1) {
                _allOrders = List.from(orders);
                _hasMoreData = ordersResponse.nextPageUrl != null;
              }

              if (_allOrders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _currentPage = 1;
                  _allOrders.clear();
                  _hasMoreData = true;
                  ref.invalidate(ordersProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      _allOrders.length +
                      (_isLoadingMore ? 1 : 0) +
                      (_hasMoreData && !_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _allOrders.length) {
                      if (_isLoadingMore) {
                        return _buildLoadingIndicator();
                      } else if (_hasMoreData) {
                        return _buildLoadMoreButton(ref);
                      }
                      return const SizedBox.shrink();
                    }

                    final order = _allOrders[index];
                    final userName = userAsync.when(
                      data: (user) {
                        if (user.name.isNotEmpty) {
                          return user.name;
                        }
                        final firstName = user.firstName ?? '';
                        final surname = user.surname ?? '';
                        if (firstName.isNotEmpty && surname.isNotEmpty) {
                          return '$firstName $surname';
                        } else if (firstName.isNotEmpty) {
                          return firstName;
                        } else if (surname.isNotEmpty) {
                          return surname;
                        } else if (user.email.isNotEmpty) {
                          return user.email.split('@').first;
                        }
                        return user.id != null ? 'User ${user.id}' : 'User';
                      },
                      loading: () => l10n.translate('common_user_placeholder'),
                      error: (_, __) =>
                          l10n.translate('common_user_placeholder'),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OrderCard(order: order, userName: userName),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _buildErrorState(error, ref),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Iconsax.shopping_bag,
                size: 64,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.translate('orders_empty_title'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('orders_empty_subtitle'),
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.shop),
              icon: const Icon(Iconsax.shop),
              label: Text(l10n.translate('orders_start_shopping')),
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
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    print('❌ ORDERS_SCREEN ERROR: Failed to load orders');
    print('Error: $error');
    final l10n = context.l10n;

    // Show error in snackbar if not a network error
    if (!isNetworkError(error)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          SnackbarUtils.showError(context, message: error.cleanMessage);
        }
      });
      // Return empty state since error is shown in snackbar
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('orders_unavailable'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(ordersProvider);
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.translate('retry')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7C32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show network error on screen
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.translate('no_internet_connection'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('check_connection_try_again'),
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(ordersProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.translate('retry')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7C32),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
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
                    ref.invalidate(ordersProvider);
                  },
                  icon: const Icon(Iconsax.global),
                  label: Text(l10n.translate('orders_check_connection')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLoadMoreButton(WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _isLoadingMore ? null : () => _loadMoreOrders(ref),
          icon: _isLoadingMore
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Iconsax.arrow_down_2),
          label: Text(
            _isLoadingMore
                ? l10n.translate('common_loading')
                : l10n.translate('orders_load_more'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B7C32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _loadMoreOrders(WidgetRef ref) async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final nextPageResponse = await OrderService.getOrders(page: _currentPage);

      setState(() {
        _allOrders.addAll(nextPageResponse.data);
        _hasMoreData = nextPageResponse.nextPageUrl != null;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.translate(
                'orders_load_more_failed',
                params: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
