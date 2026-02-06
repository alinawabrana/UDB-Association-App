import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import '../services/api_service.dart';
import '../models/product_detail_response.dart';
import '../widgets/related_product_card.dart';
import '../widgets/reviews_section.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../../utils/network/error_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:udb_association/src/features/shop/providers/cart_providers.dart';

// Provider for product detail data
final productDetailProvider = FutureProvider.family<ProductDetailResponse, int>(
  (ref, productId) async {
    return await ApiService.fetchProductDetail(productId);
  },
);

class ProductDetailScreen extends ConsumerWidget {
  final int? productId;

  const ProductDetailScreen({super.key, this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (productId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6B7C32),
          foregroundColor: Colors.white,
          title: Text(l10n.translate('product_detail_title')),
        ),
        body: Center(child: Text(l10n.translate('product_detail_not_found'))),
      );
    }

    final productDetailAsync = ref.watch(productDetailProvider(productId!));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7C32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.translate('product_detail_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: const [],
      ),
      body: productDetailAsync.when(
        data: (productDetail) =>
            ProductDetailContent(productDetail: productDetail),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7C32)),
          ),
        ),
        error: (error, stackTrace) {
          print(
            '❌ PRODUCT_DETAIL_SCREEN ERROR: Failed to load product details',
          );
          print('Error: $error');
          print('Stack trace: $stackTrace');

          // Show error in snackbar if not a network error
          if (!isNetworkError(error) && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SnackbarUtils.showError(context, message: error.cleanMessage);
            });
            // Return empty state since error is shown in snackbar
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('product_detail_not_available'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: l10n.translate('retry'),
                    onPressed: () {
                      ref.invalidate(productDetailProvider(productId!));
                    },
                    backgroundColor: const Color(0xFF6B7C32),
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            );
          }

          // Show network error on screen
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('no_internet_connection'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('check_connection_try_again'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.translate('retry'),
                  onPressed: () {
                    ref.invalidate(productDetailProvider(productId!));
                  },
                  backgroundColor: const Color(0xFF6B7C32),
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailContent extends ConsumerWidget {
  final ProductDetailResponse productDetail;

  const ProductDetailContent({super.key, required this.productDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final product = productDetail.product;
    final ratingDisplay =
        double.tryParse(product.averageRating.toString())?.toStringAsFixed(1) ??
        product.averageRating.toString();
    final totalRatingsDisplay = '${product.totalRatings}';
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Video Carousel
          ProductMediaCarousel(
            images: productDetail.product.images,
            videos: productDetail.product.videos,
          ),

          // Product Details Card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7C32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      productDetail.product.category.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7C32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Section
                  Builder(
                    builder: (context) {
                      final hasDiscount =
                          product.hasDiscount &&
                          product.originalPrice > 0 &&
                          product.originalPrice > product.displayPrice;
                      final discountPercent = hasDiscount
                          ? (((product.originalPrice - product.displayPrice) /
                                        product.originalPrice) *
                                    100)
                                .round()
                                .toString()
                          : null;
                      return Row(
                        children: [
                          Text(
                            '\$${product.displayPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7C32),
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 12),
                            Text(
                              '\$${product.originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.translate(
                                  'product_detail_discount_badge',
                                  params: {'percent': discountPercent ?? '0'},
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (productDetail.avgRating).round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 20,
                          color: const Color(0xFFF59E0B),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate(
                          'product_detail_reviews_summary',
                          params: {
                            'rating': ratingDisplay,
                            'count': totalRatingsDisplay,
                          },
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stock Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: product.inStock
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.inStock ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: product.inStock
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.inStock
                              ? l10n.translate(
                                  'product_detail_in_stock',
                                  params: {'count': '${product.quantity}'},
                                )
                              : l10n.translate('product_detail_out_of_stock'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: product.inStock
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Description Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('product_detail_description_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    productDetail.product.description ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Specifications
                  Text(
                    l10n.translate('product_detail_specifications_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (productDetail.product.sku != null)
                    _buildSpecItem(
                      l10n.translate('product_detail_spec_sku'),
                      productDetail.product.sku!,
                    ),
                  if (productDetail.product.weight != null)
                    _buildSpecItem(
                      l10n.translate('product_detail_spec_weight'),
                      l10n.translate(
                        'product_detail_spec_weight_value',
                        params: {
                          'weight': productDetail.product.weight!.toString(),
                        },
                      ),
                    ),
                  if (productDetail.product.dimensions != null)
                    _buildSpecItem(
                      l10n.translate('product_detail_spec_dimensions'),
                      productDetail.product.dimensions!,
                    ),
                ],
              ),
            ),
          ),

          // Shop Information Card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('product_detail_shop_info_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: productDetail.product.shop.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  productDetail.product.shop.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.store,
                                      color: Color(0xFF6B7280),
                                      size: 24,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.store,
                                color: Color(0xFF6B7280),
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productDetail.product.shop.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              productDetail.product.shop.tagline ??
                                  l10n.translate('product_detail_no_tagline'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          // TODO: Navigate to shop details
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Reviews Section
          ReviewsSection(productId: productDetail.product.id),

          // Related Products Section
          if (productDetail.relatedProducts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                l10n.translate('product_detail_related_products_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productDetail.relatedProducts.length,
                itemBuilder: (context, index) {
                  final relatedProduct = productDetail.relatedProducts[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: RelatedProductCard(product: relatedProduct),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Add to Cart Button
          Container(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: l10n.translate('product_detail_add_to_cart'),
              icon: Icons.shopping_cart,
              onPressed: product.inStock
                  ? () async {
                      try {
                        await ref
                            .read(cartOperationsProvider.notifier)
                            .addToCart(product.id);
                        if (context.mounted) {
                          SnackbarUtils.showSuccess(
                            context,
                            message: l10n.translate(
                              'product_detail_add_to_cart_success',
                              params: {'product': product.name},
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarUtils.showError(
                            context,
                            message: l10n.translate(
                              'product_detail_add_to_cart_error',
                              params: {'error': e.cleanMessage},
                            ),
                          );
                        }
                      }
                    }
                  : () {},
              // Empty function for disabled state
              backgroundColor: product.inStock
                  ? const Color(0xFF6B7C32)
                  : const Color(0xFF9CA3AF),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductMediaCarousel extends StatefulWidget {
  final List<ProductImage> images;
  final List<ProductVideo> videos;

  const ProductMediaCarousel({
    super.key,
    required this.images,
    required this.videos,
  });

  @override
  State<ProductMediaCarousel> createState() => _ProductMediaCarouselState();
}

class _ProductMediaCarouselState extends State<ProductMediaCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<dynamic> _mediaItems;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Combine images and videos, images first
    _mediaItems = [
      ...widget.images.map((image) => {'type': 'image', 'data': image}),
      ...widget.videos.map((video) => {'type': 'video', 'data': video}),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaItems.isEmpty) {
      return Container(
        height: 300,
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _mediaItems.length,
            itemBuilder: (context, index) {
              final mediaItem = _mediaItems[index];

              if (mediaItem['type'] == 'image') {
                final image = mediaItem['data'] as ProductImage;
                return Image.network(
                  image.fullImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6B7C32),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Handle video with full playback controls
                final video = mediaItem['data'] as ProductVideo;
                return _ChewieVideoPlayer(videoUrl: video.fullVideoUrl);
              }
            },
          ),
        ),

        // Page Indicator
        if (_mediaItems.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_mediaItems.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF6B7C32)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _ChewieVideoPlayer({required this.videoUrl});

  @override
  State<_ChewieVideoPlayer> createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<_ChewieVideoPlayer> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;
  bool _initializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final l10n = context.l10n;
    try {
      if (_initializing) return;
      setState(() {
        _initializing = true;
        _errorMessage = null;
      });
      if (widget.videoUrl.isEmpty) {
        throw Exception(l10n.translate('product_detail_video_error_empty'));
      }
      // Quick HEAD request to validate reachability and content-type
      try {
        final head = await http
            .head(Uri.parse(widget.videoUrl))
            .timeout(const Duration(seconds: 8));
        // Accept 200-206 and common video content-types
        if (head.statusCode < 200 || head.statusCode > 206) {
          throw Exception('HTTP ${head.statusCode} for video');
        }
      } catch (e) {
        setState(() {
          _errorMessage = l10n.translate(
            'product_detail_video_error_unreachable',
          );
        });
        return;
      }
      // Some backends may require the legacy constructor on certain platforms
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } catch (_) {
        _videoController = VideoPlayerController.network(
          widget.videoUrl,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }
      await _videoController.initialize();
      _videoController.addListener(() {
        final value = _videoController.value;
        if (value.hasError) {
          setState(() {
            _errorMessage =
                value.errorDescription ??
                l10n.translate('product_detail_video_error_playback');
          });
        }
      });
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowMuting: true,
        allowFullScreen: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF6B7C32),
          handleColor: const Color(0xFF6B7C32),
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
      );
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (_) {
      // If initialization fails, show a fallback UI
      if (mounted) {
        setState(() {
          _initialized = false;
          _errorMessage =
              _errorMessage ??
              l10n.translate('product_detail_video_error_initialization');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_errorMessage != null) {
      return Container(
        color: const Color(0xFF000000),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white70),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initializing ? null : _init,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7C32),
                  foregroundColor: Colors.white,
                ),
                child: _initializing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.translate('retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized || _chewieController == null) {
      return Container(
        color: const Color(0xFF000000),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7C32)),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('product_detail_video_loading'),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio == 0
          ? 16 / 9
          : _videoController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
