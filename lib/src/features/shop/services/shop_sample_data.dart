import '../models/api_product.dart';
import '../models/api_category.dart';

class ShopSampleData {
  /// Sample products for testing when API is not available
  static List<ApiProduct> getSampleProducts(int shopId) {
    return [
      ApiProduct(
        id: 1,
        shopId: shopId,
        categoryId: 1,
        name: 'Sample Product 1',
        slug: 'sample-product-1',
        description:
            'This is a sample product description for testing purposes.',
        price: '29.99',
        discountedPrice: '24.99',
        quantity: 10,
        inStock: true,
        status: true,
        sku: 'SP001',
        weight: '0.5',
        dimensions: '10x10x5',
        averageRating: '4.5',
        totalRatings: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        primaryImage: 'products/sample1.jpg',
      ),
      ApiProduct(
        id: 2,
        shopId: shopId,
        categoryId: 1,
        name: 'Sample Product 2',
        slug: 'sample-product-2',
        description: 'Another sample product for demonstration.',
        price: '49.99',
        discountedPrice: '49.99',
        quantity: 5,
        inStock: true,
        status: true,
        sku: 'SP002',
        weight: '1.0',
        dimensions: '15x15x10',
        averageRating: '4.2',
        totalRatings: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        primaryImage: 'products/sample2.jpg',
      ),
    ];
  }

  /// Sample categories for testing when API is not available
  static List<ApiCategory> getSampleCategories(int shopId) {
    return [
      ApiCategory(
        id: 1,
        shopId: shopId,
        name: 'Electronics',
        slug: 'electronics',
        description: 'Electronic devices and accessories',
        image: 'categories/electronics.jpg',
        status: true,
        sortOrder: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      ApiCategory(
        id: 2,
        shopId: shopId,
        name: 'Clothing',
        slug: 'clothing',
        description: 'Fashion and apparel items',
        image: 'categories/clothing.jpg',
        status: true,
        sortOrder: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
