import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/cart_item.dart';
import '../../auth/provider/auth_providers.dart';

/// Provider for cart items count
final cartItemsCountProvider = StateProvider<int>((ref) => 0);

/// Provider for individual product quantities in cart
final productCartQuantityProvider = StateProvider<Map<int, int>>((ref) => {});

/// Provider for mapping product IDs to cart item IDs
final productCartItemIdProvider = StateProvider<Map<int, int>>((ref) => {});

/// Smart provider to add item to cart (checks for existing items)
final smartAddToCartProvider = FutureProvider.family<void, int>((
  ref,
  productId,
) async {
  final authToken = ref.read(authTokenProvider);
  if (authToken == null) {
    throw Exception('User not authenticated');
  }

  try {
    // Check if product already exists in cart
    final existingCartItemId = ref.read(
      productCartItemIdProviderFamily(productId),
    );
    final currentQuantity = ref.read(productQuantityProvider(productId));

    if (existingCartItemId != null && currentQuantity > 0) {
      // Product exists in cart - update quantity using PUT endpoint
      print(
        'Product $productId already in cart with cart item ID $existingCartItemId, updating quantity...',
      );

      final newQuantity = currentQuantity + 1;
      final response = await ApiService.updateCartItem(
        itemId: existingCartItemId,
        authToken: authToken,
        quantity: newQuantity,
      );

      print('Update cart item response: $response');
    } else {
      // Product not in cart - add new item using POST endpoint
      print('Product $productId not in cart, adding new item...');

      final response = await ApiService.addToCart(
        productId: productId,
        authToken: authToken,
        quantity: 1,
      );

      print('Add to cart response: $response');

      // Check if the response contains updated cart item info
      if (response.containsKey('cart_item')) {
        final cartItem = response['cart_item'];
        print(
          'New cart item: ID=${cartItem['id']}, Product=${cartItem['product_id']}, Quantity=${cartItem['quantity']}',
        );
      }
    }

    // Refresh cart data from API to get the latest state
    ref.invalidate(cartCountProvider);
    await ref.read(cartCountProvider.future);
  } catch (e) {
    throw Exception('Failed to add item to cart: $e');
  }
});

/// Legacy provider to add item to cart (always creates new items)
final addToCartProvider = FutureProvider.family<void, int>((
  ref,
  productId,
) async {
  final authToken = ref.read(authTokenProvider);
  if (authToken == null) {
    throw Exception('User not authenticated');
  }

  try {
    print('Adding product $productId to cart via API...');
    final response = await ApiService.addToCart(
      productId: productId,
      authToken: authToken,
      quantity: 1,
    );

    print('Add to cart response: $response');

    // Check if the response contains updated cart item info
    if (response.containsKey('cart_item')) {
      final cartItem = response['cart_item'];
      print(
        'Updated cart item: ID=${cartItem['id']}, Product=${cartItem['product_id']}, Quantity=${cartItem['quantity']}',
      );
    }

    // Refresh cart data from API to get the latest state
    ref.invalidate(cartCountProvider);
    await ref.read(cartCountProvider.future);
  } catch (e) {
    throw Exception('Failed to add item to cart: $e');
  }
});

/// Provider to fetch cart count
final cartCountProvider = FutureProvider<int>((ref) async {
  // Watch auth token to invalidate when user changes
  final authToken = ref.watch(authTokenProvider);
  if (authToken == null) {
    // Clear cart state when user logs out
    ref.read(cartItemsCountProvider.notifier).state = 0;
    ref.read(productCartQuantityProvider.notifier).state = {};
    ref.read(productCartItemIdProvider.notifier).state = {};
    return 0;
  }

  try {
    // Fetch full cart data to get individual product quantities
    final cartData = await ApiService.fetchCart(authToken: authToken);

    // Extract individual product quantities and cart item IDs from cart data
    final Map<int, int> productQuantities = {};
    final Map<int, int> productCartItemIds = {};
    print('Cart data structure: $cartData');

    // Try different possible data structures
    List<dynamic> cartItems = [];
    if (cartData is List) {
      // Handle case where cartData is directly a List
      cartItems = cartData;
      print('Using direct List structure with ${cartItems.length} items');
    } else if (cartData is Map &&
        cartData.containsKey('data') &&
        cartData['data'] is List) {
      cartItems = cartData['data'] as List;
      print(
        'Using cartData[\'data\'] structure with ${cartItems.length} items',
      );
    } else if (cartData is Map &&
        cartData.containsKey('items') &&
        cartData['items'] is List) {
      cartItems = cartData['items'] as List;
      print(
        'Using cartData[\'items\'] structure with ${cartItems.length} items',
      );
    } else if (cartData is Map &&
        cartData.containsKey('cart_items') &&
        cartData['cart_items'] is List) {
      cartItems = cartData['cart_items'] as List;
      print(
        'Using cartData[\'cart_items\'] structure with ${cartItems.length} items',
      );
    } else {
      print('No recognized cart items structure found in: $cartData');
    }

    for (final item in cartItems) {
      if (item is Map<String, dynamic>) {
        print('Processing cart item: $item');

        // Try different possible field names for cart item ID, product ID and quantity
        int? cartItemId;
        int? productId;
        int? quantity;

        // Try different field names for cart item ID
        cartItemId = item['id'] as int?;

        // Try different field names for product ID
        productId = item['product_id'] as int? ?? item['productId'] as int?;

        // Try different field names for quantity
        quantity =
            item['quantity'] as int? ??
            item['qty'] as int? ??
            item['amount'] as int?;

        if (productId != null && quantity != null) {
          print(
            'Found product $productId with quantity $quantity and cart item ID $cartItemId',
          );

          // Store cart item ID for this product (use the latest one if multiple exist)
          if (cartItemId != null) {
            productCartItemIds[productId] = cartItemId;
          }

          // Store the quantity directly from the cart item
          // No need to aggregate since backend now properly updates quantities
          productQuantities[productId] = quantity;
        } else {
          print('Could not parse product ID or quantity from: $item');
        }
      }
    }

    // Use API quantities as the source of truth
    // No need to merge with local quantities since we're now using smart add-to-cart logic
    final mergedQuantities = <int, int>{...productQuantities};

    // Update product quantities and cart item IDs state
    ref.read(productCartQuantityProvider.notifier).state = mergedQuantities;
    ref.read(productCartItemIdProvider.notifier).state = productCartItemIds;
    print('Final merged product quantities: $mergedQuantities');
    print('Final product cart item IDs: $productCartItemIds');

    final count = mergedQuantities.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );
    print('Total cart count: $count');
    // Update the state provider with the fetched count
    ref.read(cartItemsCountProvider.notifier).state = count;
    return count;
  } catch (e) {
    print('Error fetching cart count: $e');
    return 0;
  }
});

/// Provider to refresh cart count
final refreshCartCountProvider = FutureProvider<void>((ref) async {
  ref.invalidate(cartCountProvider);
  await ref.read(cartCountProvider.future);
});

/// Provider to get quantity for a specific product
final productQuantityProvider = Provider.family<int, int>((ref, productId) {
  final quantities = ref.watch(productCartQuantityProvider);
  return quantities[productId] ?? 0;
});

/// Provider to get cart item ID for a specific product
final productCartItemIdProviderFamily = Provider.family<int?, int>((
  ref,
  productId,
) {
  final cartItemIds = ref.watch(productCartItemIdProvider);
  return cartItemIds[productId];
});

/// Provider to fetch cart items list
final cartItemsProvider = FutureProvider<List<CartItem>>((ref) async {
  // Watch auth token to invalidate when user changes
  final authToken = ref.watch(authTokenProvider);
  if (authToken == null) {
    return [];
  }

  try {
    final items = await ApiService.fetchCartItems(authToken: authToken);
    return items;
  } catch (e) {
    print('Error fetching cart items: $e');
    throw Exception('Failed to fetch cart items: $e');
  }
});

/// Provider to increment cart item quantity
final incrementCartItemProvider = FutureProvider.family<void, int>((
  ref,
  cartItemId,
) async {
  final authToken = ref.read(authTokenProvider);
  if (authToken == null) {
    throw Exception('User not authenticated');
  }

  try {
    // Get current cart items to find the current quantity
    final cartItems = await ref.read(cartItemsProvider.future);
    final cartItem = cartItems.firstWhere((item) => item.id == cartItemId);
    final newQuantity = cartItem.quantity + 1;

    print(
      'Incrementing cart item $cartItemId from ${cartItem.quantity} to $newQuantity',
    );

    // Update the cart item quantity
    await ApiService.updateCartItem(
      itemId: cartItemId,
      authToken: authToken,
      quantity: newQuantity,
    );

    // Refresh cart data
    ref.invalidate(cartItemsProvider);
    ref.invalidate(cartCountProvider);
    await ref.read(cartCountProvider.future);
  } catch (e) {
    print('Error incrementing cart item: $e');
    throw Exception('Failed to increment cart item: $e');
  }
});

/// StateNotifier for cart operations
class CartOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  CartOperationsNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  /// Decrement cart item quantity
  Future<void> decrementCartItem(int cartItemId) async {
    state = const AsyncValue.loading();

    try {
      final authToken = ref.read(authTokenProvider);
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      // Get current cart items to find the current quantity
      final cartItems = await ref.read(cartItemsProvider.future);
      final cartItem = cartItems.firstWhere((item) => item.id == cartItemId);

      if (cartItem.quantity > 1) {
        // Decrement quantity by 1
        final newQuantity = cartItem.quantity - 1;
        print(
          'Decrementing cart item $cartItemId from ${cartItem.quantity} to $newQuantity',
        );

        // Update the cart item quantity
        await ApiService.updateCartItem(
          itemId: cartItemId,
          authToken: authToken,
          quantity: newQuantity,
        );
      } else {
        // Remove item completely if quantity is 1
        print('Removing cart item $cartItemId completely (quantity was 1)');
        await ApiService.deleteCartItem(
          itemId: cartItemId,
          authToken: authToken,
        );
      }

      // Refresh cart data
      ref.invalidate(cartItemsProvider);
      ref.invalidate(cartCountProvider);
      await ref.read(cartCountProvider.future);

      state = const AsyncValue.data(null);
    } catch (e) {
      print('Error decrementing cart item: $e');
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Failed to decrement cart item: $e');
    }
  }

  /// Add product to cart (smart add - updates quantity if exists, creates new if not)
  Future<void> addToCart(int productId) async {
    state = const AsyncValue.loading();

    try {
      final authToken = ref.read(authTokenProvider);
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      // Check if product is already in cart
      final cartItems = await ref.read(cartItemsProvider.future);
      final existingCartItem = cartItems
          .where((item) => item.product.id == productId)
          .firstOrNull;

      if (existingCartItem != null) {
        // Product already in cart, increment quantity
        final newQuantity = existingCartItem.quantity + 1;
        print(
          'Product $productId already in cart with cart item ID ${existingCartItem.id}, updating quantity from ${existingCartItem.quantity} to $newQuantity',
        );

        // Update the cart item quantity
        await ApiService.updateCartItem(
          itemId: existingCartItem.id,
          authToken: authToken,
          quantity: newQuantity,
        );
      } else {
        // Product not in cart, add new item
        print('Product $productId not in cart, adding new item...');
        await ApiService.addToCart(
          productId: productId,
          authToken: authToken,
          quantity: 1,
        );
      }

      // Refresh cart data
      ref.invalidate(cartItemsProvider);
      ref.invalidate(cartCountProvider);
      await ref.read(cartCountProvider.future);

      state = const AsyncValue.data(null);
    } catch (e) {
      print('Error adding product to cart: $e');
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Failed to add product to cart: $e');
    }
  }

  /// Increment cart item quantity
  Future<void> incrementCartItem(int cartItemId) async {
    state = const AsyncValue.loading();

    try {
      final authToken = ref.read(authTokenProvider);
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      // Get current cart items to find the current quantity
      final cartItems = await ref.read(cartItemsProvider.future);
      final cartItem = cartItems.firstWhere((item) => item.id == cartItemId);
      final newQuantity = cartItem.quantity + 1;

      print(
        'Incrementing cart item $cartItemId from ${cartItem.quantity} to $newQuantity',
      );

      // Update the cart item quantity
      await ApiService.updateCartItem(
        itemId: cartItemId,
        authToken: authToken,
        quantity: newQuantity,
      );

      // Refresh cart data
      ref.invalidate(cartItemsProvider);
      ref.invalidate(cartCountProvider);
      await ref.read(cartCountProvider.future);

      state = const AsyncValue.data(null);
    } catch (e) {
      print('Error incrementing cart item: $e');
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Failed to increment cart item: $e');
    }
  }

  /// Delete cart item completely
  Future<void> deleteCartItem(int cartItemId) async {
    state = const AsyncValue.loading();

    try {
      final authToken = ref.read(authTokenProvider);
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      print('Deleting cart item $cartItemId completely');

      // Delete the cart item
      await ApiService.deleteCartItem(itemId: cartItemId, authToken: authToken);

      // Refresh cart data
      ref.invalidate(cartItemsProvider);
      ref.invalidate(cartCountProvider);
      await ref.read(cartCountProvider.future);

      state = const AsyncValue.data(null);
    } catch (e) {
      print('Error deleting cart item: $e');
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Failed to delete cart item: $e');
    }
  }
}

/// Provider for cart operations
final cartOperationsProvider =
    StateNotifierProvider<CartOperationsNotifier, AsyncValue<void>>((ref) {
      return CartOperationsNotifier(ref);
    });

/// Provider for selected cart items (for checkout)
final selectedCartItemsProvider = StateProvider<Set<int>>((ref) => {});

/// Provider to get selected cart items list
final selectedCartItemsListProvider = Provider<List<CartItem>>((ref) {
  final cartItemsAsync = ref.watch(cartItemsProvider);
  final selectedIds = ref.watch(selectedCartItemsProvider);

  return cartItemsAsync.when(
    data: (items) =>
        items.where((item) => selectedIds.contains(item.id)).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
