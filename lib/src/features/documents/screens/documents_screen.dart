import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import '../models/document_model.dart';
import '../provider/documents_provider.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  static const String _allCategoryKey = '__all__';

  String _searchQuery = '';
  String _selectedCategory = _allCategoryKey;

  List<String> _getCategories(List<DocumentCategory> documentCategories) {
    final categories = <String>[_allCategoryKey];
    for (final category in documentCategories) {
      categories.add(category.name);
    }
    return categories;
  }

  List<DocumentModel> _getFilteredRecentDocuments(
    List<DocumentModel> allDocuments,
  ) {
    // Get recent documents (last 4 documents)
    List<DocumentModel> recentDocs = allDocuments.take(4).toList();

    // Filter by category
    if (_selectedCategory != _allCategoryKey) {
      recentDocs = recentDocs
          .where((doc) => doc.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      recentDocs = recentDocs
          .where(
            (doc) =>
                doc.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return recentDocs;
  }

  List<DocumentModel> _getFilteredAllDocuments(
    List<DocumentModel> allDocuments,
  ) {
    List<DocumentModel> filtered = allDocuments;

    // Filter by category
    if (_selectedCategory != _allCategoryKey) {
      filtered = filtered
          .where((doc) => doc.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (doc) =>
                doc.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(documentsProvider);
    final documentCategories = ref.watch(documentCategoriesProvider);
    final l10n = context.l10n;

    return documentsAsync.when(
      data: (documentsResponse) {
        final allDocuments = documentsResponse.data;
        final filteredRecentDocs = _getFilteredRecentDocuments(allDocuments);
        final filteredAllDocs = _getFilteredAllDocuments(allDocuments);
        return _buildContent(
          filteredRecentDocs,
          filteredAllDocs,
          documentCategories,
          l10n,
        );
      },
      loading: () => _buildLoadingContent(l10n),
      error: (error, stackTrace) => _buildErrorContent(l10n, error.toString()),
    );
  }

  Widget _buildContent(
    List<DocumentModel> filteredRecentDocs,
    List<DocumentModel> filteredAllDocs,
    List<DocumentCategory> documentCategories,
    AppLocalizations l10n,
  ) {
    final categories = _getCategories(documentCategories);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF6B7B4F),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.translate('documents'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Category Chips Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
            child: Column(
              children: [
                // Search Bar
                SizedBox(
                  height: 48,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: l10n.translate('documents_search_hint'),
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
                ),
                const SizedBox(height: 16),
                // Category Chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
                      final categoryLabel = category == _allCategoryKey
                          ? l10n.translate('common_all')
                          : category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              categoryLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content Container
          Expanded(
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Documents Section
                    Text(
                      l10n.translate('documents_recent_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filteredRecentDocs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Iconsax.document_text5,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.translate('documents_no_results'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(
                        filteredRecentDocs.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: index < filteredRecentDocs.length - 1
                                ? 12
                                : 0,
                          ),
                          child: _RecentDocumentCard(
                            document: filteredRecentDocs[index],
                            onDownload: _downloadDocument,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Document Categories Section
                    Text(
                      l10n.translate('documents_categories_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 173 / 124,
                          ),
                      itemCount: documentCategories.length,
                      itemBuilder: (context, index) {
                        final category = documentCategories[index];
                        return _DocumentCategoryCard(category: category);
                      },
                    ),
                    const SizedBox(height: 32),
                    // All Documents Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.translate('documents_all_title'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all documents
                          },
                          child: Text(
                            l10n.translate('documents_view_all'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (filteredAllDocs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Iconsax.document_text5,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.translate('documents_no_results'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(
                        filteredAllDocs.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: index < filteredAllDocs.length - 1 ? 8 : 0,
                          ),
                          child: _AllDocumentCard(
                            document: filteredAllDocs[index],
                            onDownload: _downloadDocument,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFileExtension(String fileUrl) {
    final extension = fileUrl.split('.').last.toLowerCase();
    return extension;
  }

  String _sanitizeFileName(String fileName) {
    // Remove invalid characters for file names
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  Future<void> _downloadDocument(DocumentModel document) async {
    final l10n = context.l10n;
    try {
      final documentsService = ref.read(documentsServiceProvider);

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.translate(
                  'documents_downloading',
                  params: {'title': document.title},
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF3B82F6),
          duration: const Duration(seconds: 2),
        ),
      );

      // Call the download API
      final downloadUrl =
          "https://udbconnect.com/api/documents/${document.id}/download";

      // Generate filename from document title and file extension
      final fileExtension = _getFileExtension(document.fileUrl);
      final fileName = '${_sanitizeFileName(document.title)}.$fileExtension';

      final downloadResult = await documentsService.downloadDocument(
        downloadUrl,
        fileName,
      );

      // Show success message with file location info
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.translate(
                          'documents_download_success',
                          params: {'title': document.title},
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  () {
                    final storageLocation = downloadResult['storageLocation']
                        ?.toString();
                    if (Platform.isAndroid) {
                      if (storageLocation == 'Public Downloads (MediaStore)') {
                        return l10n.translate(
                          'documents_download_android_media_store',
                        );
                      }
                      if (storageLocation == 'System Downloads') {
                        return l10n.translate(
                          'documents_download_android_system',
                        );
                      }
                      if (storageLocation == 'App Downloads') {
                        return l10n.translate('documents_download_android_app');
                      }
                      return l10n.translate(
                        'documents_download_android_default',
                      );
                    }
                    return l10n.translate('documents_download_ios');
                  }(),
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate(
                    'documents_download_file_info',
                    params: {
                      'file': downloadResult['fileName'].toString(),
                      'size': downloadResult['fileSize'].toString(),
                    },
                  ),
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.translate(
                    'documents_download_location',
                    params: {
                      'location': downloadResult['storageLocation'].toString(),
                    },
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0x80FFFFFF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.translate(
                    'documents_download_path',
                    params: {'path': downloadResult['filePath'].toString()},
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0x80FFFFFF),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.translate(
                      'documents_download_failed',
                      params: {'title': document.title, 'error': e.toString()},
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildLoadingContent(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF6B7B4F),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.translate('documents'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorContent(AppLocalizations l10n, String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF6B7B4F),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.translate('documents'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              l10n.translate('documents_failed_to_load'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(documentsProvider);
              },
              child: Text(l10n.translate('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentDocumentCard extends StatelessWidget {
  final DocumentModel document;
  final Function(DocumentModel) onDownload;

  const _RecentDocumentCard({required this.document, required this.onDownload});

  Color _getCategoryBgColor(String category) {
    switch (category) {
      case 'Bylaws':
        return const Color(0xFF6B7280);
      case 'Regulations':
        return const Color(0xFF3B82F6);
      case 'Materials':
        return const Color(0xFF16A34A);
      case 'Forms':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getFileType(String fileUrl) {
    final extension = fileUrl.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      default:
        return 'pdf';
    }
  }

  String _formatDate(BuildContext context, String dateString) {
    final l10n = context.l10n;
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return l10n.translate('documents_updated_today');
      } else if (difference.inDays == 1) {
        return l10n.translate('documents_updated_yesterday');
      } else if (difference.inDays < 7) {
        return l10n.translate(
          'documents_updated_days_ago',
          params: {'days': difference.inDays.toString()},
        );
      } else {
        final weeks = (difference.inDays / 7).floor().toString();
        return l10n.translate(
          'documents_updated_weeks_ago',
          params: {'weeks': weeks},
        );
      }
    } catch (e) {
      return l10n.translate('documents_updated_recently');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fileType = _getFileType(document.fileUrl);
    final isPdf = fileType == 'pdf';
    final fileSizeLabel = l10n.translate('documents_unknown_size');

    return Container(
      height: 106,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPdf
                  ? const Color(0xFFDBEAFE)
                  : const Color(0xFF6B7280).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPdf ? Iconsax.document_text5 : Iconsax.document5,
              size: 16,
              color: isPdf ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 12),
          // Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(context, document.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryBgColor(document.category),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          document.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fileSizeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Download Icon
          GestureDetector(
            onTap: () => onDownload(document),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Iconsax.document_download5,
                size: 16,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCategoryCard extends StatelessWidget {
  final DocumentCategory category;

  const _DocumentCategoryCard({required this.category});

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'bylaws':
        return Icons.gavel;
      case 'regulations':
        return Iconsax.clipboard_text5;
      case 'materials':
        return Iconsax.document_text5;
      case 'forms':
        return Iconsax.document5;
      default:
        return Iconsax.document_text5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category.name),
              size: 20,
              color: category.iconColor,
            ),
          ),
          const Spacer(),
          // Category Name
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Document Count
          Text(
            category.countText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AllDocumentCard extends StatelessWidget {
  final DocumentModel document;
  final Function(DocumentModel) onDownload;

  const _AllDocumentCard({required this.document, required this.onDownload});

  String _getFileType(String fileUrl) {
    final extension = fileUrl.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      default:
        return 'pdf';
    }
  }

  String _getFileSize(AppLocalizations l10n) {
    // Since we don't have file size from API, we'll return a placeholder
    return l10n.translate('documents_unknown_size');
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'pdf':
        return const Color(0xFFFEE2E2);
      case 'word':
        return const Color(0xFFDBEAFE);
      case 'excel':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'pdf':
        return const Color(0xFFDC2626);
      case 'word':
        return const Color(0xFF2563EB);
      case 'excel':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'pdf':
        return Iconsax.document_text5;
      case 'word':
        return Iconsax.document5;
      case 'excel':
        return Iconsax.document_download5;
      default:
        return Iconsax.document5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fileType = _getFileType(document.fileUrl);
    final fileSize = _getFileSize(l10n);

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getIconBgColor(fileType),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIcon(fileType),
              size: 14,
              color: _getIconColor(fileType),
            ),
          ),
          const SizedBox(width: 12),
          // Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$fileSize • ${fileType.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Download Icon
          GestureDetector(
            onTap: () => onDownload(document),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Iconsax.document_download5,
                size: 14,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
