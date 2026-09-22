# PuneExplorer — Data Migration Guide (Local Dart Seeds to PostgreSQL)

## 1. Overview & Data Mapping Strategy

Prior to cloud migration, PuneExplorer utilized hardcoded Dart structures in lib/data/seed/pune_seed_data.dart and lib/data/seed/pune_heritage_walks_seed.dart. This guide outlines how that relational catalog was extracted, normalized, and migrated into PostgreSQL 15+.

`
┌─────────────────────────────────────────────────────────────┐
│                 Legacy Dart In-Memory Seeds                 │
│   • PuneSeedData.destinations   • PuneDarshan tours         │
│   • PuneHeritageWalksSeed.walks • Mock Coupons & FAQs       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Normalization & SQL Extraction
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     supabase/seed.sql                       │
│    Normalized INSERT statements with ON CONFLICT safety     │
└──────────────────────────────┬──────────────────────────────┘
                               │ Supabase CLI / psql
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   PostgreSQL Cloud Database                 │
│   • destinations            • destination_highlights        │
│   • tours                   • tour_itinerary_items          │
│   • heritage_walks          • heritage_walk_stops           │
│   • coupons                 • faqs / announcements          │
└─────────────────────────────────────────────────────────────┘
`

---

## 2. Relational Mapping Matrix

| Source Dart Model | Target PostgreSQL Table | Relationship & Normalization Notes |
| :--- | :--- | :--- |
| Destination | public.destinations | Primary destination metadata (slug, name, coordinates, entry fee) |
| Destination.images | public.destination_images | 1:N normalized table with is_hero and display_order |
| Destination.highlights | public.destination_highlights| 1:N array normalization with bullet display sorting |
| Destination.foodSpots | public.destination_food_spots| 1:N nearby iconic culinary spots |
| TourPackage | public.tours | Main tour catalog (Pune Darshan morning/evening circuits) |
| TourPackage.itinerary | public.tour_itinerary_items | 1:N sequential stops with arrival/departure time windows |
| TourPackage.boarding | public.tour_boarding_points | Pick-up locations across Pune with scheduled pick-up times |
| HeritageWalk | public.heritage_walks | Self-guided and guided walking itineraries |
| HeritageWalk.stops | public.heritage_walk_stops | 1:N waypoint coordinates, narrative audio, and photos |
| HeritageWalk.guide | public.heritage_walk_guides | Historical guide credentials and bios |
| Coupon | public.coupons | Promotional codes, min spend, discount rules, caps |
| FaqItem | public.faqs | Frequently asked questions grouped by categories |

---

## 3. Seed Execution & Deployment Steps

### 3.1 Applying Seed via Supabase CLI
For local development or CI/CD pipelines:
`ash
# Reset database and run all migrations + seed.sql
supabase db reset

# Or apply seed directly to a remote project
supabase db push
`

### 3.2 Applying Seed via Supabase Dashboard SQL Editor
1. Open your Supabase Dashboard at https://supabase.com/dashboard/project/<project-ref>.
2. Navigate to **SQL Editor**.
3. Paste the contents of supabase/seed.sql.
4. Click **Run** to seed destinations, tours, circuits, coupons, and system settings.

---

## 4. Idempotency Guarantees

All seed statements in supabase/seed.sql use ON CONFLICT (id) DO NOTHING or ON CONFLICT (slug) DO UPDATE. This allows re-running seed scripts safely in staging and production environments without generating duplicate keys or corrupting existing traveler records.

`sql
INSERT INTO public.destinations (
  id, slug, name, category_id, short_description, latitude, longitude, entry_fee, is_featured
) VALUES (
  'dest_shaniwar_wada', 'shaniwar-wada', 'Shaniwar Wada', 'historical',
  'Historic 18th-century fortification seat of the Peshwa rulers of the Maratha Empire.',
  18.5196, 73.8553, 25.00, true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  short_description = EXCLUDED.short_description,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude;
`

---

## 5. Verification & Data Health Queries

Run these SQL queries to verify row counts after migration:

`sql
-- Check entity counts
SELECT 'destinations' AS table_name, count(*) FROM public.destinations
UNION ALL
SELECT 'tours', count(*) FROM public.tours
UNION ALL
SELECT 'heritage_walks', count(*) FROM public.heritage_walks
UNION ALL
SELECT 'coupons', count(*) FROM public.coupons
UNION ALL
SELECT 'faqs', count(*) FROM public.faqs;
`
