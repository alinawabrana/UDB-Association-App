import 'comment_model.dart';

class LikeRequest {
  const LikeRequest({required this.targetType, required this.targetId});

  final ContentTargetType targetType;
  final int targetId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LikeRequest &&
        other.targetType == targetType &&
        other.targetId == targetId;
  }

  @override
  int get hashCode => Object.hash(targetType, targetId);
}

class LikeStatus {
  const LikeStatus({
    required this.count,
    required this.isLiked,
    this.supportsLike = true,
  });

  final int count;
  final bool isLiked;
  final bool supportsLike;

  LikeStatus copyWith({int? count, bool? isLiked, bool? supportsLike}) {
    return LikeStatus(
      count: count ?? this.count,
      isLiked: isLiked ?? this.isLiked,
      supportsLike: supportsLike ?? this.supportsLike,
    );
  }

  static const LikeStatus unsupported = LikeStatus(
    count: 0,
    isLiked: false,
    supportsLike: false,
  );
}

