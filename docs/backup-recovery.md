# PuneExplorer — Database Backup, Disaster Recovery & Business Continuity Guide

## 1. Backup Strategy Overview

To protect PuneExplorer from accidental deletion, ransomware, data corruption, or regional cloud outages, a multi-tiered backup architecture is implemented:

```
┌─────────────────────────────────────────────────────────────┐
│                 PostgreSQL Primary (Production)             │
└──────────────┬──────────────────────────────┬───────────────┘
               │ Continuous WAL Streaming     │ Daily Scheduled
               ▼                              ▼
┌──────────────────────────────┐ ┌────────────────────────────┐
│   Point-In-Time Recovery     │ │  Daily Physical Snapshots  │
│   (PITR) — 7 to 30 Days      │ │  Automated by Supabase     │
└──────────────────────────────┘ └────────────────────────────┘
               │
               │ Weekly Off-Site Backup
               ▼
┌─────────────────────────────────────────────────────────────┐
│              Encrypted S3 / Cloudflare R2 Archive           │
│        (Logical pg_dump with GPG encryption & checksums)    │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Backup Tiers & Recovery Metrics

| Mechanism | Frequency | Retention | RPO (Data Loss Window) | RTO (Recovery Time) |
| :--- | :--- | :--- | :--- | :--- |
| **Supabase Automated Daily** | Every 24 hours | 7 - 30 days | < 24 hours | < 15 minutes |
| **Point-in-Time Recovery (PITR)** | Continuous WAL | Up to 30 days | **< 2 minutes** | < 20 minutes |
| **Manual / Scripted `pg_dump`** | Daily / Weekly | 90 days offsite | Scheduled interval | < 30 minutes |
| **Storage Asset Mirroring** | Weekly sync | Indefinite | 7 days | < 1 hour |

---

## 3. Manual Logical Backup with `pg_dump`

For independent, cloud-agnostic data backups, use `pg_dump` over an encrypted SSL connection:

```bash
# Export full database schema and data
pg_dump -h db.<your-project-ref>.supabase.co \
        -U postgres \
        -d postgres \
        -F c \
        -b \
        -v \
        -f "puneexplorer_backup_$(date +%Y%m%d_%H%M%S).dump"
```

### Automated Backup Script (Cron / GitHub Action):
```bash
#!/bin/bash
set -e
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup_puneexplorer_${TIMESTAMP}.sql.gz"

# Dump and compress database
pg_dump "$DATABASE_URL" | gzip > "$BACKUP_FILE"

# Upload to off-site AWS S3 / Cloudflare R2 bucket
aws s3 cp "$BACKUP_FILE" "s3://puneexplorer-backups-archive/$BACKUP_FILE"

# Clean up local file
rm "$BACKUP_FILE"
echo "Backup $BACKUP_FILE completed and archived."
```

---

## 4. Disaster Recovery (DR) Restoration Procedures

### 4.1 Restoring via Point-in-Time Recovery (Dashboard)
1. Go to **Supabase Dashboard > Settings > Backups**.
2. Select **Point in Time**.
3. Choose the exact minute before the data loss incident occurred.
4. Click **Restore to point in time**. Supabase provisions a cloned database state.

### 4.2 Restoring from Logical `pg_dump` Archive
To restore data into a clean staging or recovery project:

```bash
# Restore entire database to target instance
pg_restore -h db.<target-project-ref>.supabase.co \
           -U postgres \
           -d postgres \
           -v \
           --clean \
           --no-owner \
           --no-privileges \
           "puneexplorer_backup_20260916.dump"
```

---

## 5. Storage Buckets Backup & Replication

While PostgreSQL stores metadata, user-uploaded payment proofs and CMS images reside in Supabase Storage. Use `rclone` or the AWS CLI (via Supabase S3-compatible endpoints) to synchronize files to external storage:

```bash
# Sync all media buckets to backup archive
rclone sync supabase:destinations r2:puneexplorer-storage-backup/destinations
rclone sync supabase:receipts r2:puneexplorer-storage-backup/receipts
```

---

## 6. Recovery Drill Testing Schedule

To guarantee disaster readiness, run this quarterly validation checklist:
- [ ] **Quarterly Restoration Test**: Restore the latest `.dump` file to a local test container (`supabase start`).
- [ ] **Data Integrity Check**: Verify destination count, booking history, and user profiles.
- [ ] **RLS Verification**: Verify that restored tables still have RLS enabled and policies intact.
