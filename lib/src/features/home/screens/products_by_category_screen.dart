import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:udb_association/src/common/widgets/app_drawer.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/src/features/shop/models/product.dart';
import 'package:udb_association/src/features/shop/providers/shop_providers.dart';
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';
import 'package:udb_association/src/features/shop/widgets/product_card.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/auth/provider/user_role_fallback_provider.dart';
import 'package:udb_association/src/features/notifications/providers/notification_providers.dart';
import 'package:udb_association/src/features/subscription/providers/subscription_booking_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/utils/network/error_utils.dart';
import 'package:udb_association/utils/network/connectivity.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class ProductsByCategoryScreen extends ConsumerStatefulWidget {
  final bool isManagerDrawerRoute;

  const ProductsByCategoryScreen({
    super.key,
    this.isManagerDrawerRoute = false,
  });

  @override
  ConsumerState<ProductsByCategoryScreen> createState() =>
      _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState
    extends ConsumerState<ProductsByCategoryScreen>
    with WidgetsBindingObserver {
  bool _retrying = false;

  void _handleBackNavigation() {
    final userRole = ref.read(effectiveUserRoleProvider);

    if (userRole?.toLowerCase() == 'manager') {
      // For managers, navigate back to survey analysis
      context.go('/survey_analysis');
    } else {
      // For other users, navigate back to home (products by category)
      context.go('/home');
    }
  }

  Future<void> _retryAll() async {
    final l10n = context.l10n;
    if (_retrying) return;
    setState(() {
      _retrying = true;
    });
    try {
      final online = await hasInternetConnection();
      if (!online) {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            message: l10n.translate('no_internet_connection'),
          );
        }
        return;
      }

      // Force refetch for all data sources used on this screen
      await Future.wait<dynamic>([
        ref.refresh(categoriesProvider.future),
        ref.refresh(productsProvider.future),
        ref.refresh(cartItemsProvider.future),
        ref.refresh(cartCountProvider.future),
        ref.refresh(subscriptionBookingsProvider.future),
      ]);
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
      // On resume, refresh both categories and products and cart
      // Trigger refresh futures but don't await in lifecycle callback
      // ignore: unused_result
      ref.refresh(categoriesProvider);
      // ignore: unused_result
      ref.refresh(productsProvider);
      // ignore: unused_result
      ref.refresh(cartCountProvider);
      // ignore: unused_result
      ref.refresh(subscriptionBookingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final userProfileAsync = ref.watch(profileProvider);

    return userProfileAsync.when(
      data: (user) {
        final userRole = user.role ?? 'user';
        final shouldShowDrawer = userRole.toLowerCase() != 'vendor';

        return Scaffold(
          drawer: shouldShowDrawer ? const AppDrawer() : null,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: AppBar(
              backgroundColor: const Color(0xFF6B7C32),
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text(l10n.translate('products_by_category')),
              titleSpacing: shouldShowDrawer ? 0 : 16,
              leading: shouldShowDrawer
                  ? Builder(
                      builder: (context) {
                        if (widget.isManagerDrawerRoute) {
                          // Show back arrow for managers accessing via drawer
                          return IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: _handleBackNavigation,
                          );
                        }
                        // No leading icon for regular access (no menu icon)
                        return const SizedBox.shrink();
                      },
                    )
                  : null,
              actions: [
                if (!widget.isManagerDrawerRoute &&
                    userRole.toLowerCase() != 'manager')
                  Consumer(
                    builder: (context, ref, _) {
                      final subscriptionAsync = ref.watch(
                        userHasApprovedSubscriptionProvider,
                      );
                      final isSpecialUser = subscriptionAsync.maybeWhen(
                        data: (value) => value,
                        orElse: () => false,
                      );
                      if (isSpecialUser) {
                        return const SizedBox.shrink();
                      }
                      final unreadAsync = ref.watch(
                        unreadNotificationsCountProvider,
                      );
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {
                              context.goNamed(AppRouteNames.notifications);
                            },
                            icon: const Icon(
                              Iconsax.notification5,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          unreadAsync.when(
                            data: (count) => count > 0
                                ? Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          count.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      );
                    },
                  ),
                Consumer(
                  builder: (context, ref, child) {
                    final cartCountAsync = ref.watch(cartCountProvider);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () {
                            print('AppBar: Navigating to cart screen...');
                            final userRole = ref.read(
                              effectiveUserRoleProvider,
                            );
                            final subscriptionAsync = ref.read(
                              userHasApprovedSubscriptionProvider,
                            );
                            final isSpecialUser =
                                userRole?.toLowerCase() == 'user' &&
                                subscriptionAsync.maybeWhen(
                                  data: (value) => value,
                                  orElse: () => false,
                                );
                            if (userRole?.toLowerCase() == 'manager') {
                              context.goNamed(AppRouteNames.appCart);
                            } else if (userRole?.toLowerCase() == 'member') {
                              context.goNamed(AppRouteNames.memberCart);
                            } else if (isSpecialUser) {
                              context.goNamed(AppRouteNames.userCart);
                            } else {
                              context.goNamed(AppRouteNames.homeCart);
                            }
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
                    ref.read(searchQueryProvider.notifier).state = v;
                  },
                ),
                const SizedBox(height: 16),
                categoriesAsync.when(
                  data: (categories) => _CategoryChips(
                    categories: categories,
                    onCategorySelected: (categoryId) {
                      // Navigate to category section
                      // For now, we'll just scroll to it
                    },
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (error, stack) => SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isNetworkError(error)
                                ? l10n.translate('no_internet_connection')
                                : l10n.translate('failed_to_load_categories'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _retrying ? null : _retryAll,
                          child: Text(l10n.translate('retry')),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _SpecialOffer(),
                const SizedBox(height: 16),
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      // Log the products response for debugging
                      print('=== PRODUCTS API RESPONSE ===');
                      print('Products count: ${products.length}');
                      for (int i = 0; i < products.length; i++) {
                        print('Product $i: ${products[i].toJson()}');
                      }
                      print('=== END PRODUCTS RESPONSE ===');

                      // Check if products list is empty
                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.translate('no_products_found'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.translate('check_back_later'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filter by search query if provided
                      final String query = ref.read(searchQueryProvider).trim();
                      List<Product> filtered = products;
                      if (query.isNotEmpty) {
                        final q = query.toLowerCase();
                        filtered = products.where((p) {
                          final name = p.name.toLowerCase();
                          final desc = (p.description ?? '').toLowerCase();
                          return name.contains(q) || desc.contains(q);
                        }).toList();
                      }

                      // Randomize products after filtering
                      final randomizedProducts = List<Product>.from(filtered)
                        ..shuffle();

                      return _RandomizedProductsList(
                        products: randomizedProducts,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) {
                      print('Error for fetching Products: $error');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isNetworkError(error)
                                  ? l10n.translate('no_internet_connection')
                                  : l10n.translate('failed_to_load_products'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isNetworkError(error)
                                  ? l10n.translate('check_connection_try_again')
                                  : '$error',
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
                                  : Text(l10n.translate('retry')),
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
          floatingActionButton: _CartFab(),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('failed_to_load_user'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: Text(l10n.translate('retry')),
              ),
            ],
          ),
        ),
      ),
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
    final l10n = context.l10n;
    return SizedBox(
      height: 48,
      child: TextField(
        focusNode: _focusNode,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: l10n.translate('search_products_hint'),
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
    required this.onCategorySelected,
  });

  final List<Category> categories;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    final List<Category> allCats = [
      Category(id: 'all', name: l10n.translate('all_categories')),
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
              ref.read(selectedCategoryIdProvider.notifier).state = cat.id;
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
    final l10n = context.l10n;
    return Container(
      height: 132,
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
                Text(
                  l10n.translate('special_offer'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.translate('special_offer_description'),
                  style: const TextStyle(
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
                    child: Text(l10n.translate('shop_now')),
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

class _RandomizedProductsList extends ConsumerWidget {
  const _RandomizedProductsList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
          onCardTap: () {
            // Get current route location to determine correct navigation route
            final currentLocation = GoRouterState.of(context).fullPath ?? '';

            // Determine route based on current location context, not just user role
            if (currentLocation.startsWith('/app_shop_products')) {
              // For managers accessing from app_shop_products
              context.goNamed(
                AppRouteNames.appProductDetail,
                pathParameters: {'productId': product.id.toString()},
              );
            } else if (currentLocation.startsWith('/member_shop_products')) {
              // For members accessing from member_shop_products
              context.goNamed(
                AppRouteNames.memberProductDetail,
                pathParameters: {'productId': product.id.toString()},
              );
            } else if (currentLocation.startsWith('/user_product')) {
              // For shop footer tab route
              context.goNamed(
                AppRouteNames.userProductDetail,
                pathParameters: {'productId': product.id.toString()},
              );
            } else {
              // Default to productDetail for /home route
              context.goNamed(
                AppRouteNames.productDetail,
                pathParameters: {'productId': product.id.toString()},
              );
            }
          },
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
                  message: l10n.translate(
                    'failed_to_add_to_cart',
                    params: {'message': e.cleanMessage},
                  ),
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCountAsync = ref.watch(cartCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          onPressed: () {
            print('FAB: Navigating to cart screen...');
            final userRole = ref.read(effectiveUserRoleProvider);
            final subscriptionAsync = ref.read(
              userHasApprovedSubscriptionProvider,
            );
            final isSpecialUser =
                userRole?.toLowerCase() == 'user' &&
                subscriptionAsync.maybeWhen(
                  data: (value) => value,
                  orElse: () => false,
                );
            if (userRole?.toLowerCase() == 'manager') {
              // context.goNamed(AppRouteNames.appCart);
              context.goNamed(AppRouteNames.userCart);
            } else if (userRole?.toLowerCase() == 'member') {
              // context.goNamed(AppRouteNames.memberCart);
              context.goNamed(AppRouteNames.userCart);
            } else if (isSpecialUser) {
              context.goNamed(AppRouteNames.userCart);
            } else {
              // context.goNamed(AppRouteNames.homeCart);
              context.goNamed(AppRouteNames.userCart);
            }
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
