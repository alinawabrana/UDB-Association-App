import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/localization/app_localizations.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import 'review_card.dart';

// Provider for product reviews
final productReviewsProvider =
    FutureProvider.family<ProductReviewsResponse, int>((ref, productId) async {
      return await ReviewService.getProductReviews(productId);
    });

class ReviewsSection extends ConsumerWidget {
  final int productId;

  const ReviewsSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return Container(
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
            // Section header
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF59E0B), size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.translate('product_detail_customer_reviews'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                reviewsAsync.when(
                  data: (reviewsResponse) => Text(
                    l10n.translate('product_detail_reviews_count').replaceAll('{count}', reviewsResponse.pagination.total.toString()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6B7C32),
                      ),
                    ),
                  ),
                  error: (_, __) => Text(
                    l10n.translate('product_detail_reviews_count_zero'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reviews content
            reviewsAsync.when(
              data: (reviewsResponse) {
                if (reviewsResponse.reviews.isEmpty) {
                  return _buildEmptyReviews(l10n);
                }

                return Column(
                  children: [
                    // Average rating summary
                    _buildRatingSummary(reviewsResponse, l10n),
                    const SizedBox(height: 20),
                    // Reviews list
                    ...reviewsResponse.reviews.map(
                      (review) => ReviewCard(review: review),
                    ),
                    // Load more button if there are more pages
                    if (reviewsResponse.pagination.currentPage <
                        reviewsResponse.pagination.lastPage)
                      _buildLoadMoreButton(
                        ref,
                        reviewsResponse.pagination.currentPage + 1,
                        l10n,
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6B7C32),
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) {
                print('❌ REVIEWS_SECTION ERROR: Failed to load reviews');
                print('Error: $error');
                print('Stack trace: $stackTrace');

                return _buildErrorState(ref, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReviews(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.reviews_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('product_detail_no_reviews_yet'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('product_detail_be_first_review'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ProductReviewsResponse reviewsResponse, AppLocalizations l10n) {
    if (reviewsResponse.reviews.isEmpty) return const SizedBox.shrink();

    // Calculate average rating
    final totalRating = reviewsResponse.reviews.fold<double>(
      0,
      (sum, review) => sum + review.rating,
    );
    final averageRating = totalRating / reviewsResponse.reviews.length;

    // Count ratings by star
    final ratingCounts = List.filled(5, 0);
    for (final review in reviewsResponse.reviews) {
      if (review.rating >= 1 && review.rating <= 5) {
        ratingCounts[review.rating - 1]++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Average rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 20,
                    color: const Color(0xFFF59E0B),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.translate('product_detail_reviews_count').replaceAll('{count}', reviewsResponse.pagination.total.toString()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Rating breakdown
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final starRating = 5 - index;
                final count = ratingCounts[starRating - 1];
                final percentage = reviewsResponse.reviews.isEmpty
                    ? 0.0
                    : (count / reviewsResponse.reviews.length) * 100;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$starRating',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF59E0B),
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(WidgetRef ref, int nextPage, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Center(
        child: TextButton(
          onPressed: () {
            // TODO: Implement pagination
            // For now, just refresh the current page
            ref.invalidate(productReviewsProvider(productId));
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6B7C32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            l10n.translate('product_detail_load_more_reviews'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF6B7280)),
          const SizedBox(height: 16),
          Text(
            l10n.translate('product_detail_failed_to_load_reviews'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('product_detail_reviews_try_again'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(productReviewsProvider(productId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B7C32),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.translate('retry')),
          ),
        ],
      ),
    );
  }
}
