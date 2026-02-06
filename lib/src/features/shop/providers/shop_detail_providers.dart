import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/shop_api_service.dart';
import '../models/api_product.dart';
import '../models/api_category.dart';
import 'shop_providers.dart';
import '../models/shop.dart';

/// Provider for shop products by shop ID
final shopProductsProvider = FutureProvider.family<List<ApiProduct>, int>((
  ref,
  shopId,
) async {
  return ShopApiService.fetchShopProducts(shopId);
});

/// Provider for shop categories by shop ID
final shopCategoriesProvider = FutureProvider.family<List<ApiCategory>, int>((
  ref,
  shopId,
) async {
  return ShopApiService.fetchShopCategories(shopId);
});

/// Provider to get shop info by ID from the shops list
final shopByIdProvider = Provider.family<AsyncValue<Shop?>, int>((ref, shopId) {
  final shopsAsync = ref.watch(shopsProvider);

  return shopsAsync.when(
    data: (shops) {
      final shop = shops.where((s) => s.id == shopId).firstOrNull;
      return AsyncValue.data(shop);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
