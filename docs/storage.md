# PuneExplorer — Supabase Storage Architecture & File Management Guide

## 1. Bucket Architecture & Hierarchy

PuneExplorer organizes binary assets across 7 specialized buckets in **Supabase Storage**. This compartmentalization isolates sensitive financial receipts from publicly accessible travel media.

| Bucket Identifier | Visibility | Max File Size | Allowed MIME Types | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| destinations | **Public** | 5 MB | image/jpeg, image/png, image/webp | Destination hero and gallery images |
| 	ours | **Public** | 5 MB | image/jpeg, image/png, image/webp | Pune Darshan and tour package banners |
| heritage-walks | **Public** | 5 MB | image/jpeg, image/png, image/webp | Walk route maps and stop photographs |
| eceipts | **Private** | 10 MB | image/jpeg, image/png, image/webp, pplication/pdf | Traveler UPI transaction screenshots & receipts |
| vatars | **Public** | 2 MB | image/jpeg, image/png, image/webp | Traveler and staff profile pictures |
| media-library | **Public** | 10 MB | image/*, ideo/mp4 | Admin CMS reusable media asset storage |
| randing | **Public** | 5 MB | image/jpeg, image/png, image/svg+xml, image/webp | App logos, watermarks, and promotional assets |

---

## 2. Storage Security & Row Level Security (RLS)

Storage policies are applied at the storage.objects table level in PostgreSQL to strictly regulate uploads, reads, and deletions.

### 2.1 Public Read Policies
For public buckets (destinations, 	ours, heritage-walks, vatars, media-library, randing), anyone (including unauthenticated travelers) can view images via the Supabase CDN:

`sql
CREATE POLICY Public Assets Viewable by Everyone
ON storage.objects FOR SELECT
USING (
  bucket_id IN ('destinations', 'tours', 'heritage-walks', 'avatars', 'media-library', 'branding')
);
`

### 2.2 Private Receipt Access Policy
Payment proofs in the eceipts bucket are strictly private. Only the uploader (the traveler who made the booking) and authorized administrative staff (super_admin, ooking_admin) may view or download them:

`sql
CREATE POLICY Users and Staff Can View Receipts
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'receipts'
  AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid()
      AND ur.role IN ('super_admin', 'booking_admin', 'support')
    )
  )
);
`

### 2.3 Upload Policies
- **Travelers**: May upload their own avatar into vatars/{user_id}/* and their payment screenshots into eceipts/{user_id}/*.
- **Content Staff**: May upload into destinations/*, 	ours/*, heritage-walks/*, media-library/*, and randing/*.

---

## 3. Flutter Integration: SupabaseMediaRepository

Binary upload and URL resolution are encapsulated inside lib/data/repositories/supabase/supabase_media_repository.dart.

### 3.1 Uploading an Image with CDN Cache-Control

`dart
Future<String> uploadDestinationImage({
  required Uint8List bytes,
  required String fileName,
}) async {
  final path = 'destinations/_';

  await client.storage.from(SupabaseConfig.bucketDestinations).uploadBinary(
    path,
    bytes,
    fileOptions: const FileOptions(
      cacheControl: '3600',
      contentType: 'image/webp',
      upsert: false,
    ),
  );

  return client.storage
      .from(SupabaseConfig.bucketDestinations)
      .getPublicUrl(path);
}
`

### 3.2 Generating Signed URLs for Private Proofs

Private receipts cannot be read via getPublicUrl. Instead, the app requests a short-lived signed URL (e.g. valid for 15 minutes) for admin verification:

`dart
Future<String> getPaymentProofUrl(String receiptPath) async {
  final signedUrl = await client.storage
      .from(SupabaseConfig.bucketReceipts)
      .createSignedUrl(receiptPath, 900); // 15 minutes validity
  return signedUrl;
}
`

---

## 4. Performance & Caching Recommendations

1. **WebP Compression**: Convert high-resolution DSLR photos to modern WebP format before uploading (average 65% byte reduction).
2. **Transformations**: Utilize Supabase Storage image transformation API (width, height, quality) to serve responsive thumbnail sizes for mobile cards:
   `
   https://<project-ref>.supabase.co/storage/v1/render/image/public/destinations/shaniwar-wada.webp?width=400&height=300&quality=80
   `
3. **Cache Headers**: Always provide cacheControl: '3600' on uploads so the global Cloudflare CDN caches static assets efficiently.
