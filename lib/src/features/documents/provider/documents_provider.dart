import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../services/documents_service.dart';

final documentsServiceProvider = Provider<DocumentsService>((ref) {
  return DocumentsService();
});

final documentsProvider = FutureProvider<DocumentsResponse>((ref) async {
  final documentsService = ref.read(documentsServiceProvider);
  return await documentsService.fetchDocuments();
});

final documentsListProvider = Provider<List<DocumentModel>>((ref) {
  final documentsAsync = ref.watch(documentsProvider);
  return documentsAsync.when(
    data: (response) => response.data,
    loading: () => <DocumentModel>[],
    error: (_, __) => <DocumentModel>[],
  );
});

final documentCategoriesProvider = Provider<List<DocumentCategory>>((ref) {
  final documents = ref.watch(documentsListProvider);

  // Group documents by category and count them
  final Map<String, int> categoryCounts = {};
  for (final document in documents) {
    categoryCounts[document.category] =
        (categoryCounts[document.category] ?? 0) + 1;
  }

  // Create category list with predefined colors for first 4 categories
  final List<DocumentCategory> categories = [];

  // Define predefined categories with their colors
  final predefinedCategories = [
    {
      'name': 'Bylaws',
      'bgColor': const Color(0xFF6B7280).withValues(alpha: 0.2),
      'iconColor': const Color(0xFF6B7280),
    },
    {
      'name': 'Regulations',
      'bgColor': const Color(0xFFDBEAFE),
      'iconColor': const Color(0xFF2563EB),
    },
    {
      'name': 'Materials',
      'bgColor': const Color(0xFFDCFCE7),
      'iconColor': const Color(0xFF16A34A),
    },
    {
      'name': 'Forms',
      'bgColor': const Color(0xFFF3E8FF),
      'iconColor': const Color(0xFF9333EA),
    },
  ];

  // Add predefined categories with their counts
  for (int i = 0; i < predefinedCategories.length; i++) {
    final predefined = predefinedCategories[i];
    final count = categoryCounts[predefined['name'] as String] ?? 0;

    categories.add(
      DocumentCategory(
        name: predefined['name'] as String,
        count: count,
        bgColor: predefined['bgColor'] as Color,
        iconColor: predefined['iconColor'] as Color,
      ),
    );
  }

  // Add any additional categories that exist in the API but not in predefined list
  final additionalCategories = categoryCounts.keys
      .where(
        (category) => !predefinedCategories.any(
          (predefined) => predefined['name'] == category,
        ),
      )
      .toList();

  // Use the same color scheme for additional categories
  final additionalColors = [
    const Color(0xFFFEE2E2).withValues(alpha: 0.2),
    const Color(0xFFFEF3C7).withValues(alpha: 0.2),
    const Color(0xFFECFDF5).withValues(alpha: 0.2),
    const Color(0xFFF0F9FF).withValues(alpha: 0.2),
  ];

  final additionalIconColors = [
    const Color(0xFFDC2626),
    const Color(0xFFD97706),
    const Color(0xFF059669),
    const Color(0xFF0284C7),
  ];

  for (int i = 0; i < additionalCategories.length; i++) {
    final category = additionalCategories[i];
    final count = categoryCounts[category] ?? 0;
    final colorIndex = i % additionalColors.length;

    categories.add(
      DocumentCategory(
        name: category,
        count: count,
        bgColor: additionalColors[colorIndex],
        iconColor: additionalIconColors[colorIndex],
      ),
    );
  }

  return categories;
});

class DocumentCategory {
  final String name;
  final int count;
  final Color bgColor;
  final Color iconColor;

  DocumentCategory({
    required this.name,
    required this.count,
    required this.bgColor,
    required this.iconColor,
  });

  String get countText => '$count document${count != 1 ? 's' : ''}';
}
