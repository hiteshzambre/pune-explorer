# PuneExplorer — Complete Database Schema & Data Dictionary

This document details the complete relational database schema for **PuneExplorer**, deployed on PostgreSQL 15+ via Supabase.

---

## 1. Schema Diagram & Relationships

```
 auth.users (Supabase GoTrue)
      │
      ▼
   profiles ───────────────┐
      │                    │
      ▼                    ▼
  user_roles            bookings ───────────► booking_travelers
      │                    │
      ▼                    ▼
    roles               payments
      │                    │
      ▼                    ▼
 role_permissions       refund_requests
      │
      ▼
  permissions
```

---

## 2. Core Tables Dictionary

### 2.1 `profiles`
Extends `auth.users` with application-specific traveler profile attributes.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | PK, FK -> `auth.users(id)` ON DELETE CASCADE | Unique user identifier |
| `email` | `TEXT` | NOT NULL | User contact email |
| `full_name` | `TEXT` | NOT NULL DEFAULT `''` | Full display name |
| `phone` | `TEXT` | DEFAULT `''` | Mobile telephone number |
| `avatar_url` | `TEXT` | DEFAULT `''` | Storage URL to profile photo |
| `bio` | `TEXT` | DEFAULT `''` | Traveler biography |
| `role` | `TEXT` | NOT NULL DEFAULT `'customer'` | Base system role (`super_admin`, `admin`, `editor`, `support`, `customer`) |
| `created_at` | `TIMESTAMPTZ` | NOT NULL DEFAULT `NOW()` | Registration timestamp |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL DEFAULT `NOW()` | Last modification timestamp |

---

### 2.2 `roles` & `permissions` (RBAC)

#### `roles`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Role slug (`super_admin`, `admin`, `editor`, `support`, `customer`) |
| `name` | `TEXT` | NOT NULL | Human-readable role title |
| `description`| `TEXT` | DEFAULT `''` | Description of role duties |

#### `permissions`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Permission identifier (`manage_destinations`, `verify_payments`, etc.) |
| `name` | `TEXT` | NOT NULL | Display label |
| `category` | `TEXT` | DEFAULT `'general'` | Grouping category (`content`, `finance`, `security`) |

---

### 2.3 `destinations`
Stores all Pune destinations, monuments, temples, viewpoints, and trekking starting points.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Destination slug identifier (e.g. `shaniwar-wada`) |
| `slug` | `TEXT` | UNIQUE, NOT NULL | SEO URL slug |
| `name` | `TEXT` | NOT NULL | English name |
| `marathi_name` | `TEXT` | NOT NULL DEFAULT `''` | Devanagari Marathi script name |
| `category_id` | `TEXT` | FK -> `categories(id)` | Parent category (`historical`, `religious`, `nature`, `food`) |
| `tag` | `TEXT` | DEFAULT `'heritage'` | High-level badge |
| `short_description`| `TEXT` | NOT NULL | Summary teaser for catalog cards |
| `full_description` | `TEXT` | NOT NULL | Detailed historical/architectural content |
| `hero_image` | `TEXT` | NOT NULL | Primary high-res photography URL |
| `rating` | `NUMERIC(3,2)` | DEFAULT `4.5` | Aggregated user rating |
| `review_count` | `INT` | DEFAULT `0` | Total verified reviews |
| `entry_fee` | `NUMERIC(10,2)`| DEFAULT `0` | Indian citizen entry fee in INR |
| `best_time_to_visit`| `TEXT` | DEFAULT `'October to March'` | Recommended travel season |
| `timings` | `TEXT` | DEFAULT `'9:00 AM - 6:00 PM'` | Operating hours |
| `ideal_duration` | `TEXT` | DEFAULT `'2-3 hours'` | Recommended visit length |
| `latitude` | `NUMERIC(10,6)`| DEFAULT `18.5204` | GPS coordinate |
| `longitude` | `NUMERIC(10,6)`| DEFAULT `73.8567` | GPS coordinate |
| `address` | `TEXT` | DEFAULT `''` | Street address in Pune |
| `how_to_reach` | `TEXT` | DEFAULT `''` | Transit instructions |
| `is_featured` | `BOOLEAN` | DEFAULT `false` | Featured on homepage |
| `is_trending` | `BOOLEAN` | DEFAULT `false` | Highlighted in trending tray |
| `is_active` | `BOOLEAN` | DEFAULT `true` | Public visibility toggle |

---

### 2.4 `tours` & `darshan_circuits`
Manages guided tours, Sahyadri mountain treks, and electric AC bus circuits.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Tour package identifier (e.g. `pune-darshan-full-day`) |
| `title` | `TEXT` | NOT NULL | Tour headline |
| `tour_type` | `TEXT` | DEFAULT `'trek'` | `'darshan'`, `'trek'`, `'heritage_walk'`, `'weekend_getaway'` |
| `duration_days` | `INT` | DEFAULT `1` | Tour duration in days |
| `duration_hours` | `INT` | DEFAULT `8` | Tour duration in hours |
| `price_per_person` | `NUMERIC(10,2)` | NOT NULL | Standard retail ticket price (INR) |
| `discounted_price` | `NUMERIC(10,2)` | NULLABLE | Promotional sale price |
| `max_group_size` | `INT` | DEFAULT `20` | Maximum capacity limit |
| `inclusions` | `JSONB` | DEFAULT `'[]'` | List of included amenities |
| `exclusions` | `JSONB` | DEFAULT `'[]'` | List of exclusions |

---

### 2.5 `bookings` & `booking_travelers`
Tracks customer reservations and passenger manifests.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Unique booking reference (e.g. `PUNE-2026-8941`) |
| `booking_code` | `TEXT` | UNIQUE, NOT NULL | Customer-facing ticket code |
| `user_id` | `UUID` | FK -> `profiles(id)` | Booked traveler |
| `tour_id` | `TEXT` | NOT NULL | Linked tour or circuit |
| `travel_date` | `DATE` | NOT NULL | Departure date |
| `boarding_point` | `TEXT` | DEFAULT `'Swargate'` | Selected pickup landmark |
| `total_travelers` | `INT` | DEFAULT `1` | Number of seats booked |
| `total_amount` | `NUMERIC(10,2)` | NOT NULL | Subtotal before discounts |
| `discount_amount`| `NUMERIC(10,2)` | DEFAULT `0` | Coupon discount applied |
| `final_amount` | `NUMERIC(10,2)` | NOT NULL | Final invoice total |
| `status` | `TEXT` | DEFAULT `'pending'` | `'pending'`, `'confirmed'`, `'cancelled'`, `'completed'` |
| `payment_status` | `TEXT` | DEFAULT `'unpaid'` | `'unpaid'`, `'under_verification'`, `'paid'`, `'refunded'` |

---

### 2.6 `payments`
Tracks manual UPI QR payments, customer claimed UTR numbers, and receipt attachments.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Internal UUID |
| `order_id` | `TEXT` | UNIQUE, NOT NULL | Order reference (e.g. `PE-2026-000184`) |
| `booking_id` | `TEXT` | FK -> `bookings(id)` | Linked booking |
| `user_id` | `UUID` | FK -> `profiles(id)` | Payer account |
| `amount` | `NUMERIC(10,2)` | NOT NULL | Payment amount in INR |
| `status` | `TEXT` | DEFAULT `'created'` | `'created'`, `'under_verification'`, `'verified'`, `'rejected'`, `'refunded'` |
| `upi_transaction_id`| `TEXT` | NULLABLE | Customer submitted 12-digit UTR reference |
| `receipt_url` | `TEXT` | NULLABLE | Storage bucket URL to payment screenshot |
| `verified_by` | `TEXT` | NULLABLE | Administrator email who approved payment |
| `verified_at` | `TIMESTAMPTZ` | NULLABLE | Verification timestamp |
| `rejection_reason` | `TEXT` | NULLABLE | Rejection explanation if invalid |

---

### 2.7 `coupons`
Manages promotional discounts and seasonal campaign vouchers.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Unique coupon ID |
| `code` | `TEXT` | UNIQUE, NOT NULL | Uppercase promotional code (e.g. `DARSHAN50`) |
| `discount_type` | `TEXT` | DEFAULT `'percentage'` | `'percentage'` or `'flat'` |
| `discount_value` | `NUMERIC(10,2)` | NOT NULL | Value (% or flat INR amount) |
| `min_booking_amount`| `NUMERIC(10,2)`| DEFAULT `0` | Minimum spend threshold |
| `max_discount_amount`| `NUMERIC(10,2)`| DEFAULT `1000` | Discount ceiling |
| `valid_from` | `TIMESTAMPTZ` | NOT NULL | Activation date |
| `valid_until` | `TIMESTAMPTZ` | NOT NULL | Expiry date |
| `usage_limit` | `INT` | DEFAULT `1000` | Total redemptions allowed |
| `times_used` | `INT` | DEFAULT `0` | Current redemption tally |
| `is_active` | `BOOLEAN` | DEFAULT `true` | Manual activation toggle |

---

### 2.8 `audit_logs`
Immutable compliance and security trail recording all administrative mutations.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | Unique log ID (`audit_<timestamp>_<hash>`) |
| `user_id` | `TEXT` | NOT NULL | Admin identifier |
| `user_email` | `TEXT` | NOT NULL | Admin email address |
| `action` | `TEXT` | NOT NULL | Action verb (`PAYMENT_VERIFIED`, `TOUR_UPDATED`, etc.) |
| `entity_type` | `TEXT` | NOT NULL | Entity (`payment`, `booking`, `destination`) |
| `entity_id` | `TEXT` | NOT NULL | Targeted entity ID |
| `old_values` | `JSONB` | NULLABLE | Pre-mutation state |
| `new_values` | `JSONB` | NULLABLE | Post-mutation state |
| `created_at` | `TIMESTAMPTZ` | NOT NULL DEFAULT `NOW()` | Timestamp |
