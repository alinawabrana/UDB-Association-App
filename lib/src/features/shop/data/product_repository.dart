import 'dart:convert';

import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Category>> fetchCategories();
  Future<List<Product>> fetchProducts({String? categoryId, String? query});
  Future<Product> toggleFavorite(String productId, bool isFavorited);
}

/// Simple mock repository backed by inline JSON to demonstrate parsing.
class MockProductRepository implements ProductRepository {
  @override
  Future<List<Category>> fetchCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final List<dynamic> data = jsonDecode(_categoriesJson) as List<dynamic>;
    return data
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<List<Product>> fetchProducts({
    String? categoryId,
    String? query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final List<Product> all = Product.listFromJsonString(_productsJson);
    return all.where((p) {
      final bool categoryOk =
          categoryId == null ||
          categoryId.isEmpty ||
          p.categoryId == categoryId;
      final bool queryOk =
          (query == null || query.isEmpty) ||
          p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.feature.toLowerCase().contains(query.toLowerCase());
      return categoryOk && queryOk;
    }).toList();
  }

  @override
  Future<Product> toggleFavorite(String productId, bool isFavorited) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    // Normally this would call an API and return updated product
    final List<Product> all = Product.listFromJsonString(_productsJson);
    final Product prod = all.firstWhere((p) => p.id == productId);
    return prod.copyWith(isFavorited: isFavorited);
  }
}

const String _categoriesJson =
    '[\n  {"id":"all","name":"All Items"},\n  {"id":"apparel","name":"Apparel"},\n  {"id":"accessories","name":"Accessories"},\n  {"id":"stationery","name":"Stationery"}\n]';

// Sample data derived from the provided UI. Prices in cents.
const String _productsJson =
    '[\n  {\n    "id": "tee-udb-classic",\n    "name": "UDB Classic Tee",\n    "feature": "Cotton Blend",\n    "price": {"amountCents": 2500, "currencyCode": "USD"},\n    "currencyCode": "USD",\n    "imageUrl": "https://picsum.photos/seed/udbtee/400",\n    "thumbnailUrl": "https://picsum.photos/seed/udbtee/200",\n    "categoryId": "apparel",\n    "tags": ["shirt", "cotton"]\n  },\n  {\n    "id": "cap-udb",\n    "name": "UDB Baseball Cap",\n    "feature": "Adjustable",\n    "price": {"amountCents": 1800, "currencyCode": "USD"},\n    "currencyCode": "USD",\n    "imageUrl": "https://picsum.photos/seed/udbcap/400",\n    "thumbnailUrl": "https://picsum.photos/seed/udbcap/200",\n    "categoryId": "accessories"\n  },\n  {\n    "id": "bottle-udb",\n    "name": "UDB Water Bottle",\n    "feature": "500ml Stainless",\n    "price": {"amountCents": 2200, "currencyCode": "USD"},\n    "currencyCode": "USD",\n    "imageUrl": "https://picsum.photos/seed/udbbottle/400",\n    "thumbnailUrl": "https://picsum.photos/seed/udbbottle/200",\n    "categoryId": "accessories"\n  },\n  {\n    "id": "notebook-udb",\n    "name": "UDB Notebook",\n    "feature": "A5 Hardcover",\n    "price": {"amountCents": 1500, "currencyCode": "USD"},\n    "currencyCode": "USD",\n    "imageUrl": "https://picsum.photos/seed/udbnote/400",\n    "thumbnailUrl": "https://picsum.photos/seed/udbnote/200",\n    "categoryId": "stationery"\n  },\n  {\n    "id": "hoodie-udb",\n    "name": "UDB Hoodie",\n    "feature": "Premium Cotton",\n    "price": {"amountCents": 4500, "currencyCode": "USD"},\n    "currencyCode": "USD",\n    "imageUrl": "https://picsum.photos/seed/udbhoodie/400",\n    "thumbnailUrl": "https://picsum.photos/seed/udbhoodie/200",\n    "categoryId": "apparel"\n  },\n  {\n    "id": "backpack-udb",\n    "name": "UDB Backpack",\n    "feature": "Laptop Compartment",\n    "price": {"amountCents": 6500, "currencyCode": "USD"},\n    "currencyCode": "USD",\n    "imageUrl": "https://picsum.photos/seed/udbpack/400",\n    "thumbnailUrl": "https://picsum.photos/seed/udbpack/200",\n    "categoryId": "accessories"\n  }\n]';
