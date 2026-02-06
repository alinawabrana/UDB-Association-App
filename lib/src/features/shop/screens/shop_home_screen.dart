import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:udb_association/src/common/widgets/app_drawer.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/shop/providers/shop_home_providers.dart';
import 'package:udb_association/src/features/shop/providers/shop_detail_providers.dart'
    as detail_providers;
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';
import 'package:udb_association/src/features/shop/models/product.dart';
import 'package:udb_association/src/features/shop/widgets/product_card.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/network/error_utils.dart';
import 'package:udb_association/utils/network/connectivity.dart';

class ShopHomeScreen extends ConsumerStatefulWidget {
  final int shopId;

  const ShopHomeScreen({super.key, required this.shopId});

  @override
  ConsumerState<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends ConsumerState<ShopHomeScreen>
    with WidgetsBindingObserver {
  bool _retrying = false;

  Future<void> _retryAll() async {
    if (_retrying) return;
    setState(() {
      _retrying = true;
    });
    try {
      final online = await hasInternetConnection();
      if (!online) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No internet connection')),
          );
        }
        return;
      }

      // Kick off refreshes; await specific futures to ensure reload
      // ignore: unused_result
      ref.refresh(detail_providers.shopByIdProvider(widget.shopId));
      final catsF = ref.refresh(shopCategoriesProvider(widget.shopId).future);
      final prodsF = ref.refresh(shopProductsProvider(widget.shopId).future);
      final cartF = ref.refresh(cartCountProvider.future);
      await Future.wait<dynamic>([catsF, prodsF, cartF]);
    } finally {
      if (mounted) {
        setState(() {
          _retrying = false;
        });
      }
    }
  }

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
      // ignore: unused_result
      ref.refresh(detail_providers.shopByIdProvider(widget.shopId));
      // ignore: unused_result
      ref.refresh(shopCategoriesProvider(widget.shopId));
      // ignore: unused_result
      ref.refresh(shopProductsProvider(widget.shopId));
      // ignore: unused_result
      ref.refresh(cartCountProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(
      detail_providers.shopByIdProvider(widget.shopId),
    );
    final categoriesAsync = ref.watch(shopCategoriesProvider(widget.shopId));
    final productsAsync = ref.watch(shopProductsProvider(widget.shopId));
    final searchQuery = ref.watch(shopSearchQueryProvider(widget.shopId));

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: const Color(0xFF6B7C32),
          foregroundColor: Colors.white,
          elevation: 0,
          title: shopAsync.when(
            data: (shop) => Text(shop?.name ?? 'Shop Products'),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Shop Products'),
          ),
          titleSpacing: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final cartCountAsync = ref.watch(cartCountProvider);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        print('Shop AppBar: Navigating to cart screen...');
                        context.goNamed(
                          AppRouteNames.shopCart,
                          pathParameters: {'shopId': widget.shopId.toString()},
                        );
                      },
                      icon: Icon(
                        Icons.shopping_cart,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    cartCountAsync.when(
                      data: (count) {
                        if (count > 0) {
                          return Positioned(
                            right: 8,
                            top: 8,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (error, stack) => const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(
              value: searchQuery,
              onChanged: (v) {
                ref
                        .read(shopSearchQueryProvider(widget.shopId).notifier)
                        .state =
                    v;
              },
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => _CategoryChips(
                categories: categories,
                shopId: widget.shopId,
                onCategorySelected: (categoryId) {
                  // Category selection handled by provider
                },
              ),
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (error, stack) {
                print('❌ SHOP_HOME_SCREEN ERROR: Failed to load categories');
                print('Error: $error');
                print('Stack trace: $stack');

                // Show error in snackbar if not a network error
                if (!isNetworkError(error) && context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SnackbarUtils.showError(
                      context,
                      message: error.cleanMessage,
                    );
                  });
                }

                return SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isNetworkError(error)
                              ? 'No Internet Connection'
                              : 'Categories unavailable',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _retrying ? null : _retryAll,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const _SpecialOffer(),
            const SizedBox(height: 16),
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  // Randomize products and display them randomly
                  final randomizedProducts = List<Product>.from(products)
                    ..shuffle();

                  return _RandomizedProductsGrid(
                    products: randomizedProducts,
                    shopId: widget.shopId,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  print('❌ SHOP_HOME_SCREEN ERROR: Failed to load products');
                  print('Error: $error');
                  print('Stack trace: $stack');

                  // Show error in snackbar if not a network error
                  if (!isNetworkError(error) && context.mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      SnackbarUtils.showError(
                        context,
                        message: error.cleanMessage,
                      );
                    });
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isNetworkError(error)
                              ? 'No Internet Connection'
                              : 'Products unavailable',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isNetworkError(error)
                              ? 'Please check your connection and try again.'
                              : 'Unable to load products at the moment.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _retrying ? null : _retryAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B7C32),
                            foregroundColor: Colors.white,
                          ),
                          child: _retrying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _CartFab(shopId: widget.shopId),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      final selectionIndex = widget.value.length;
      _controller
        ..text = widget.value
        ..selection = TextSelection.collapsed(offset: selectionIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        focusNode: _focusNode,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFADAEBC),
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: Color(0xFF9CA3AF),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({
    required this.categories,
    required this.shopId,
    required this.onCategorySelected,
  });

  final List<Category> categories;
  final int shopId;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryId = ref.watch(
      shopSelectedCategoryIdProvider(shopId),
    );

    final List<Category> allCats = [
      const Category(id: 'all', name: 'All Categories'),
      ...categories.where((c) => c.id != 'all'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = allCats[index];
          final isSelected = cat.id == selectedCategoryId;

          return GestureDetector(
            onTap: () {
              ref.read(shopSelectedCategoryIdProvider(shopId).notifier).state =
                  cat.id;
              onCategorySelected(cat.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B7C32)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SpecialOffer extends StatelessWidget {
  const _SpecialOffer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Special Offer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Get 20% off on all shop items',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Shop now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RandomizedProductsGrid extends ConsumerWidget {
  const _RandomizedProductsGrid({required this.products, required this.shopId});

  final List<Product> products;
  final int shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          productQuantity: ref.watch(
            productQuantityProvider(int.parse(product.id)),
          ),
          onCardTap: () => context.goNamed(
            AppRouteNames.shopProductDetail,
            pathParameters: {
              'shopId': shopId.toString(),
              'productId': product.id.toString(),
            },
          ),
          onAddToCart: () async {
            try {
              await ref
                  .read(cartOperationsProvider.notifier)
                  .addToCart(int.parse(product.id));
              if (context.mounted) {
                SnackbarUtils.showSuccess(
                  context,
                  message: '${product.name} added to cart!',
                );
              }
            } catch (e) {
              if (context.mounted) {
                SnackbarUtils.showError(
                  context,
                  message: 'Failed to add to cart: ${e.cleanMessage}',
                );
              }
            }
          },
        );
      },
    );
  }
}

class _CartFab extends ConsumerWidget {
  final int shopId;

  const _CartFab({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCountAsync = ref.watch(cartCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          onPressed: () {
            print('Shop FAB: Navigating to cart screen...');
            context.go('/shop/$shopId/cart');
          },
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.shopping_cart, size: 20),
        ),
        cartCountAsync.when(
          data: (count) {
            if (count > 0) {
              return Positioned(
                right: -4,
                top: -4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
