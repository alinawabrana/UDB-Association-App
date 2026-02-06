import '../data/product_repository.dart';
import '../models/product.dart';
import '../models/api_category.dart';
import '../models/api_product.dart';
import '../services/api_service.dart';

class ApiProductRepository implements ProductRepository {
  @override
  Future<List<Category>> fetchCategories() async {
    try {
      print('=== CATEGORIES REPOSITORY REQUEST ===');
      final apiCategories = await ApiService.fetchCategories();

      print('=== CONVERTING API CATEGORIES TO DOMAIN ===');
      print('API Categories count: ${apiCategories.length}');
      for (int i = 0; i < apiCategories.length; i++) {
        print('API Category $i: ${apiCategories[i].toJson()}');
      }

      final domainCategories = apiCategories
          .map(_convertApiCategoryToDomain)
          .toList();

      print('=== CONVERTED DOMAIN CATEGORIES ===');
      print('Domain Categories count: ${domainCategories.length}');
      for (int i = 0; i < domainCategories.length; i++) {
        print('Domain Category $i: ${domainCategories[i].toJson()}');
      }
      print('=== END CATEGORIES REPOSITORY ===');

      return domainCategories;
    } catch (e) {
      print('=== CATEGORIES REPOSITORY ERROR ===');
      print('Error: $e');
      print('=== END CATEGORIES REPOSITORY ERROR ===');
      // Surface errors so UI can show retry/offline states
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProducts({
    String? categoryId,
    String? query,
  }) async {
    try {
      print('=== PRODUCTS API REQUEST ===');
      print('Category ID: $categoryId');
      print('Search Query: $query');

      final int? categoryIdInt = categoryId != null && categoryId != 'all'
          ? int.tryParse(categoryId)
          : null;

      final apiProducts = await ApiService.fetchAllProducts(
        categoryId: categoryIdInt,
        search: query,
      );

      print('=== API PRODUCTS RESPONSE ===');
      print('API Products count: ${apiProducts.length}');
      for (int i = 0; i < apiProducts.length; i++) {
        print('API Product $i: ${apiProducts[i].toJson()}');
      }
      print('=== END API PRODUCTS RESPONSE ===');

      final domainProducts = apiProducts
          .map(_convertApiProductToDomain)
          .toList();

      print('=== CONVERTED DOMAIN PRODUCTS ===');
      print('Domain Products count: ${domainProducts.length}');
      for (int i = 0; i < domainProducts.length; i++) {
        print('Domain Product $i: ${domainProducts[i].toJson()}');
      }
      print('=== END DOMAIN PRODUCTS ===');

      return domainProducts;
    } catch (e) {
      print('=== PRODUCTS API ERROR ===');
      print('Error: $e');
      print('=== END PRODUCTS API ERROR ===');
      // Surface errors so UI can show retry/offline states
      rethrow;
    }
  }

  @override
  Future<Product> toggleFavorite(String productId, bool isFavorited) async {
    // For now, just return the product with updated favorite status
    // In a real implementation, this would call an API endpoint
    final products = await fetchProducts();
    final product = products.firstWhere((p) => p.id == productId);
    return product.copyWith(isFavorited: isFavorited);
  }

  Category _convertApiCategoryToDomain(ApiCategory apiCategory) {
    return Category(
      id: apiCategory.id.toString(),
      name: apiCategory.name,
      icon: apiCategory.image,
    );
  }

  Product _convertApiProductToDomain(ApiProduct apiProduct) {
    return Product(
      id: apiProduct.id.toString(),
      name: apiProduct.name,
      description: apiProduct.description,
      price: Money(
        amountCents: (apiProduct.displayPrice * 100).round(),
        currencyCode: 'USD', // Assuming USD from the API response
      ),
      currencyCode: 'USD',
      imageUrl: apiProduct.imageUrl,
      thumbnailUrl: apiProduct.imageUrl,
      feature:
          apiProduct.category?.name ??
          'General', // Using category name as feature
      categoryId: apiProduct.categoryId.toString(),
      isFavorited: false, // Default to false, will be managed by wishlist
      tags: [
        apiProduct.category?.name.toLowerCase() ?? 'general',
        apiProduct.shop?.name.toLowerCase() ?? 'shop',
        if (apiProduct.hasDiscount) 'discount',
        if (!apiProduct.isInStock) 'out-of-stock',
      ],
    );
  }
}
