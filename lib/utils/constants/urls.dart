class ApiUrls {
  // Base URL for media files (images, videos, etc.)
  static const String mediaBaseUrl =
      'https://udbconnect.com/storage/app/public/';

  // Helper method to construct full media URL from path
  static String getMediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    // If path already contains the full URL, return as is
    if (path.startsWith('http')) {
      return path;
    }

    // If path already starts with /storage, use it directly with base URL
    if (path.startsWith('/storage/')) {
      // Remove leading slash and use the path as is
      final cleanPath = path.substring(1); // Remove leading '/'
      return 'https://udbconnect.com/$cleanPath';
    }

    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return '$mediaBaseUrl$cleanPath';
  }

  // Helper method for profile images specifically
  // Uses base URL: https://udbconnect.com/storage/app/public/
  static String getProfileImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    // If path already contains the full URL, return as is
    if (path.startsWith('http')) {
      return path;
    }

    // If path already starts with /storage, use it directly with base URL
    if (path.startsWith('/storage/')) {
      // Remove leading slash and use the path as is
      final cleanPath = path.substring(1); // Remove leading '/'
      return 'https://udbconnect.com/$cleanPath';
    }

    // For profile images, check if it's a relative path like "profile_images/..."
    // Profile images are stored at /storage/app/public/profile_images/
    if (path.startsWith('profile_images/')) {
      return '$mediaBaseUrl$path';
    }

    // If path starts with /profile_images, handle it
    if (path.startsWith('/profile_images')) {
      final cleanPath = path.substring(1); // Remove leading '/'
      return '$mediaBaseUrl$cleanPath';
    }

    // For other relative paths, use the standard media URL (which uses mediaBaseUrl)
    return getMediaUrl(path);
  }

  // Helper method for shop images
  static String getShopImageUrl(String? path) {
    return getMediaUrl(path);
  }

  // Helper method for product images
  static String getProductImageUrl(String? path) {
    return getMediaUrl(path);
  }

  // Helper method for category images
  static String getCategoryImageUrl(String? path) {
    return getMediaUrl(path);
  }
}
