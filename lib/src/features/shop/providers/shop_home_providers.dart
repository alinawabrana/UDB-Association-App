import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/shop_api_service.dart';
import '../models/api_product.dart';
import '../models/api_category.dart';
import '../models/product.dart';

/// Shop-specific search query provider
final shopSearchQueryProvider = StateProvider.family<String, int>(
  (ref, shopId) => '',
);

/// Shop-specific selected category provider
final shopSelectedCategoryIdProvider = StateProvider.family<String, int>(
  (ref, shopId) => 'all',
);

/// Convert ApiCategory to Category for compatibility with home screen
Category _apiCategoryToCategory(ApiCategory apiCategory) {
  return Category(
    id: apiCategory.id.toString(),
    name: apiCategory.name,
    icon: apiCategory.fullImageUrl,
  );
}

/// Convert ApiProduct to Product for compatibility with home screen
Product _apiProductToProduct(ApiProduct apiProduct) {
  return Product(
    id: apiProduct.id.toString(),
    name: apiProduct.name,
    description: apiProduct.description,
    price: Money(
      amountCents: (apiProduct.displayPrice * 100).round(),
      currencyCode: 'USD',
    ),
    currencyCode: 'USD',
    imageUrl: apiProduct.imageUrl,
    thumbnailUrl: apiProduct.imageUrl,
    feature: apiProduct.description ?? 'No Description',
    categoryId: apiProduct.categoryId.toString(),
    isFavorited: false,
    tags: [],
  );
}

/// Shop categories provider (compatible with home screen)
final shopCategoriesProvider = FutureProvider.autoDispose
    .family<List<Category>, int>((ref, shopId) async {
      final apiCategories = await ShopApiService.fetchShopCategories(shopId);
      return apiCategories.map(_apiCategoryToCategory).toList();
    });

/// Shop products provider (compatible with home screen)
final shopProductsProvider = FutureProvider.autoDispose
    .family<List<Product>, int>((ref, shopId) async {
      final selectedCategoryId = ref.watch(
        shopSelectedCategoryIdProvider(shopId),
      );
      final searchQuery = ref.watch(shopSearchQueryProvider(shopId));

      final apiProducts = await ShopApiService.fetchShopProducts(shopId);
      final products = apiProducts.map(_apiProductToProduct).toList();

      // Filter by category if not 'all'
      List<Product> filteredProducts = products;
      if (selectedCategoryId != 'all') {
        filteredProducts = products
            .where((p) => p.categoryId == selectedCategoryId)
            .toList();
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        filteredProducts = filteredProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  (p.description?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }

      return filteredProducts;
    });
