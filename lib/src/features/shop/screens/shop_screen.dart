import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/src/features/shop/models/shop.dart';
import 'package:udb_association/src/features/shop/providers/shop_providers.dart';
import 'package:udb_association/src/features/shop/widgets/shop_card.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import '../../../../utils/network/error_utils.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('ShopScreen: Building shop screen');
    final shopsAsync = ref.watch(shopsProvider);
    print('ShopScreen: Shops async state: ${shopsAsync.runtimeType}');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7C32),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Shops',
          style: TextStyle(
            // color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              // color: Color(0xFF111827)
            ),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: shopsAsync.when(
          data: (shops) => CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Browse Shops',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shops.length} shops available',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Shops List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final shop = shops[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < shops.length - 1 ? 12 : 16,
                      ),
                      child: ShopCard(
                        shop: shop,
                        onTap: () => _onShopTapped(context, shop),
                      ),
                    );
                  }, childCount: shops.length),
                ),
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7C32)),
            ),
          ),
          error: (error, stack) {
            print('❌ SHOP_SCREEN ERROR: Failed to load shops');
            print('Error: $error');
            print('Stack trace: $stack');

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
                      Icons.store_outlined,
                      size: 64,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No shops available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(shopsProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7C32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Retry'),
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
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your connection and try again.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(shopsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7C32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onShopTapped(BuildContext context, Shop shop) {
    context.goNamed(
      AppRouteNames.shopDetail,
      pathParameters: {'shopId': shop.id.toString()},
    );
  }
}
