/// High-performance CDN Image URL Optimizer for PuneExplorer.
///
/// Automatically appends optimal sizing, compression, and format parameters
/// to dynamic image CDNs (such as Unsplash) to drastically reduce memory usage,
/// decode overhead, and network payload without sacrificing visual fidelity.
class AppImageOptimizer {
  const AppImageOptimizer._();

  /// Default quality for compressed thumbnails and cards
  static const int defaultQuality = 75;

  /// Optimizes an image URL for the requested [width] and [quality].
  ///
  /// For Unsplash URLs, this replaces or appends `w`, `q`, `auto=format`, and `fit=crop`.
  /// For all other URLs (local assets, data URLs, other CDNs), the original URL is preserved.
  static String optimize(
    String? url, {
    int? width,
    int quality = defaultQuality,
    String fit = 'crop',
  }) {
    if (url == null || url.trim().isEmpty) {
      return '';
    }

    final trimmed = url.trim();

    // Check if this is an Unsplash image
    if (trimmed.contains('images.unsplash.com')) {
      try {
        final uri = Uri.parse(trimmed);
        final queryParams = Map<String, String>.from(uri.queryParameters);

        // Optimize dimensions & format
        if (width != null && width > 0) {
          queryParams['w'] = width.toString();
        } else if (!queryParams.containsKey('w') || (int.tryParse(queryParams['w'] ?? '') != null && int.parse(queryParams['w']!) > 800)) {
          // Default cap for Unsplash images if unspecified or oversized
          queryParams['w'] = '640';
        }

        queryParams['q'] = quality.toString();
        queryParams['auto'] = 'format';
        queryParams['fit'] = fit;

        return uri.replace(queryParameters: queryParams).toString();
      } catch (_) {
        return trimmed;
      }
    }

    return trimmed;
  }

  /// Thumbnail size (~320px width) for list avatars, compact rows, and map pins
  static String forThumbnail(String? url) => optimize(url, width: 320, quality: 75);

  /// Card size (~640px width) for grid cards, itinerary items, and walk cards
  static String forCard(String? url) => optimize(url, width: 640, quality: 75);

  /// Hero size (~1080px width) for detail headers, full-width banners, and carousels
  static String forHero(String? url) => optimize(url, width: 1080, quality: 80);
}
