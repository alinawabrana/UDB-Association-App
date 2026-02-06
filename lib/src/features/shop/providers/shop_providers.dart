import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repository.dart';
import '../repositories/api_product_repository.dart';
import '../models/product.dart';
import '../models/shop.dart';
import '../services/shop_api_service.dart';

// Repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ApiProductRepository();
});

// UI state: selected category and search query
final selectedCategoryIdProvider = StateProvider<String>((ref) => 'all');
final searchQueryProvider = StateProvider<String>((ref) => '');

// Wishlist state management
final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((
  ref,
) {
  return WishlistNotifier();
});

// Categories - autoDispose so it refetches when screens re-subscribe
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((
  ref,
) async {
  print('=== CATEGORIES PROVIDER TRIGGERED ===');
  final repo = ref.read(productRepositoryProvider);
  final categories = await repo.fetchCategories();
  print('=== CATEGORIES PROVIDER RESULT ===');
  print('Categories count: ${categories.length}');
  for (int i = 0; i < categories.length; i++) {
    print('Provider Category $i: ${categories[i].toJson()}');
  }
  print('=== END CATEGORIES PROVIDER ===');
  return categories;
});

// Shops from API
final shopsProvider = FutureProvider<List<Shop>>((ref) async {
  return ShopApiService.fetchShops();
});

// Products filtered by selected category and query (without wishlist state)
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final String categoryId = ref.watch(selectedCategoryIdProvider);
  final String query = ref.watch(searchQueryProvider);
  final String? categoryFilter = categoryId == 'all' ? null : categoryId;
  return repo.fetchProducts(categoryId: categoryFilter, query: query);
});

// Check if a specific product is in wishlist
final isProductInWishlistProvider = Provider.family<bool, String>((
  ref,
  productId,
) {
  final wishlist = ref.watch(wishlistProvider);
  return wishlist.contains(productId);
});

// Wishlist products
final wishlistProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final wishlist = ref.watch(wishlistProvider);

  if (wishlist.isEmpty) return [];

  // Fetch all products and filter by wishlist
  final allProducts = await repo.fetchProducts();
  return allProducts.where((product) => wishlist.contains(product.id)).toList();
});

// Action: toggle favorite
final toggleFavoriteProvider =
    Provider<
      Future<void> Function({
        required String productId,
        required bool isFavorited,
      })
    >((ref) {
      final wishlistNotifier = ref.read(wishlistProvider.notifier);
      return ({required String productId, required bool isFavorited}) async {
        if (isFavorited) {
          wishlistNotifier.addToWishlist(productId);
        } else {
          wishlistNotifier.removeFromWishlist(productId);
        }
      };
    });

// Wishlist state notifier
class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super(<String>{});

  void addToWishlist(String productId) {
    state = {...state, productId};
  }

  void removeFromWishlist(String productId) {
    state = Set.from(state)..remove(productId);
  }

  void clearWishlist() {
    state = <String>{};
  }

  bool isInWishlist(String productId) {
    return state.contains(productId);
  }
}
