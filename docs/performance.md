# ⚡ PuneExplorer — Production Performance Architecture & Guidelines

## 1. Executive Overview

PuneExplorer is engineered for fast loading and 60fps rendering on Flutter Web across mobile browsers, tablets, and high-resolution desktop displays.

### Performance Design Pillars
1. **Zero Eager Asset Bloat**: Network images are not loaded as massive uncompressed blobs; all dynamic media paths pass through `AppImageOptimizer`.
2. **Sub-second Search Response with Debouncing**: All search text controllers implement a 150ms debouncing mechanism (`Timer? _debounce`) to cancel stale filtering operations and avoid unnecessary rebuilds.
3. **Lazy Provider Instantiation**: Riverpod providers are evaluated on-demand. Heavy admin controllers and repositories are not loaded during initial consumer app bootstrap.
4. **Optimized Layout Tree**: Extensive use of `const` constructors, custom lightweight paint delegates, and responsive layout caching.

---

## 2. Image Optimization Engine (`AppImageOptimizer`)

Dynamic images sourced from Unsplash and CDN storage are routed through `lib/core/utils/image_optimizer.dart`:

| Method | Target Resolution | Quality | Use Case |
| :--- | :--- | :--- | :--- |
| `forThumbnail(url)` | 320px width | 75% | List items, map callouts, user avatars |
| `forCard(url)` | 640px width | 75% | Grid cards, tour packages, heritage walks |
| `forHero(url)` | 1080px width | 80% | Detail headers, full-width banners |

### Automatic Optimization
- Strips oversized query parameters.
- Converts to modern WebP / auto-format depending on client browser headers.
- Implements aspect-ratio preservation to eliminate Cumulative Layout Shift (CLS).

---

## 3. Web Delivery & Font Performance

1. **Font Subsetting**:
   - Google Fonts (Outfit & Plus Jakarta Sans) are downloaded and cached.
   - Only required font weights (400 Regular, 600 SemiBold, 700 Bold, 900 Black) are bundled.
2. **Web Release Compilation**:
   - Built with `--release` using Flutter CanvasKit / Skwasm renderer for maximum GPU acceleration.
   - Tree shaking strips unused Material icons and icons packages.

---

## 4. Query Performance & Data Pagination

- **PostgreSQL Indexes**: B-Tree indexes on `slug`, `category`, `status`, `user_id`, and `created_at` ensure sub-10ms query times on all Supabase tables.
- **Selective Projections**: Supabase queries select only the required fields instead of raw `SELECT *` where large metadata is present.
- **Client Cache Integration**: Repositories cache fetched results in memory during active user sessions to avoid duplicate network roundtrips.
