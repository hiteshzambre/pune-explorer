import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/core/utils/image_optimizer.dart';

void main() {
  group('AppImageOptimizer Unit Tests', () {
    test('Returns empty string when URL is null or empty', () {
      expect(AppImageOptimizer.optimize(null), '');
      expect(AppImageOptimizer.optimize(''), '');
      expect(AppImageOptimizer.optimize('   '), '');
    });

    test('Preserves non-Unsplash URLs unchanged', () {
      const localAsset = 'assets/images/shaniwar_wada.png';
      expect(AppImageOptimizer.optimize(localAsset), localAsset);

      const customCdn = 'https://cdn.example.com/photo.jpg';
      expect(AppImageOptimizer.optimize(customCdn), customCdn);
    });

    test('Optimizes Unsplash URL with specified width and quality', () {
      const unsplashUrl = 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1600&auto=format&fit=crop';
      final optimized = AppImageOptimizer.optimize(unsplashUrl, width: 480, quality: 70);

      final uri = Uri.parse(optimized);
      expect(uri.queryParameters['w'], '480');
      expect(uri.queryParameters['q'], '70');
      expect(uri.queryParameters['auto'], 'format');
      expect(uri.queryParameters['fit'], 'crop');
    });

    test('Caps oversized Unsplash images when width is not specified', () {
      const unsplashUrl = 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1920&auto=format&fit=crop';
      final optimized = AppImageOptimizer.optimize(unsplashUrl);

      final uri = Uri.parse(optimized);
      expect(uri.queryParameters['w'], '640');
      expect(uri.queryParameters['q'], '75');
    });

    test('Helper methods set accurate responsive target widths', () {
      const unsplashUrl = 'https://images.unsplash.com/photo-1544735716-392fe2489ffa';

      final thumb = AppImageOptimizer.forThumbnail(unsplashUrl);
      expect(Uri.parse(thumb).queryParameters['w'], '320');

      final card = AppImageOptimizer.forCard(unsplashUrl);
      expect(Uri.parse(card).queryParameters['w'], '640');

      final hero = AppImageOptimizer.forHero(unsplashUrl);
      expect(Uri.parse(hero).queryParameters['w'], '1080');
    });
  });
}
