import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import '../models/comment_model.dart';
import '../models/combined_item_model.dart';
import '../providers/news_provider.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({
    super.key,
    required this.item,
    required this.targetId,
    required this.targetType,
  });

  final CombinedItemModel item;
  final int targetId;
  final ContentTargetType targetType;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = CommentRequest(
      targetType: widget.targetType,
      targetId: widget.targetId,
    );
    final commentsAsync = ref.watch(commentsProvider(request));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7A47),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            commentsAsync.when(
              data: (page) => Text(
                l10n.translate(
                  'news_comments_count',
                  params: {'count': '${page.total}'},
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Comments list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: commentsAsync.when(
                  data: (page) {
                    final comments = page.comments;
                    if (comments.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.translate('news_no_comments'),
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _CommentTile(comment: comment);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B7A47),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            err.toString(),
                            style: const TextStyle(color: Color(0xFFEF4444)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Comment composer - fixed at bottom with keyboard padding
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildComposer(context, l10n, request),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(
    BuildContext context,
    AppLocalizations l10n,
    CommentRequest request,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.translate('news_add_comment_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () => _submitComment(context, request),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B7A47),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.9),
                  ),
                )
              : Text(l10n.translate('news_post_comment')),
        ),
      ],
    );
  }

  Future<void> _submitComment(
    BuildContext context,
    CommentRequest request,
  ) async {
    final commentText = _controller.text.trim();
    
    print('💬 [COMMENTS SCREEN] Submitting comment...');
    print('   Target Type: ${request.targetType.name}');
    print('   Target ID: ${request.targetId}');
    print('   Comment Text: $commentText');
    print('   Comment Length: ${commentText.length}');
    
    if (commentText.isEmpty) {
      print('⚠️ [COMMENTS SCREEN] Comment is empty, showing warning');
      SnackbarUtils.showWarning(
        context,
        message: context.l10n.translate('news_comment_empty_error'),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = ref.read(authTokenProvider);
      if (token == null) {
        print('❌ [COMMENTS SCREEN] Not authenticated');
        throw Exception('Not authenticated');
      }
      
      print('💬 [COMMENTS SCREEN] Calling comment service...');
      final service = ref.read(commentServiceProvider);
      final createdComment = await service.createComment(
        token: token,
        targetType: request.targetType,
        targetId: request.targetId,
        comment: commentText,
      );
      
      print('💬 [COMMENTS SCREEN] Comment created successfully!');
      print('   Comment ID: ${createdComment.id}');
      print('   Author: ${createdComment.authorName}');

      // Clear the text field
      _controller.clear();

      // Refresh comments
      ref.invalidate(commentsProvider(request));
      print('💬 [COMMENTS SCREEN] Comments list invalidated, refreshing...');

      // Scroll to bottom to show new comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      SnackbarUtils.showSuccess(
        context,
        message: context.l10n.translate('news_comment_posted'),
      );
    } catch (e) {
      print('❌ [COMMENTS SCREEN] Error submitting comment:');
      print('   Error: $e');
      SnackbarUtils.showError(
        context,
        message: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        print('💬 [COMMENTS SCREEN] Comment submission completed');
      }
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF6B7A47),
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (comment.formattedDate.isNotEmpty)
                      Text(
                        comment.formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }
}

