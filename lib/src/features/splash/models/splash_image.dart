class SplashImage {
  const SplashImage({
    required this.id,
    required this.splashUrl,
    this.createdAt,
  });

  final int id;
  final String splashUrl;
  final DateTime? createdAt;

  factory SplashImage.fromJson(Map<String, dynamic> json) {
    return SplashImage(
      id: int.tryParse('${json['id']}') ?? 0,
      splashUrl:
          (json['image_path'] ?? json['splash_url'])?.toString().trim() ?? '',
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
