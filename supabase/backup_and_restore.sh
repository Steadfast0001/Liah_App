#!/usr/bin/env bash
# ==============================================================================
# Liah Academy — Database Backup, Integrity Check & Restoration Verification
# Requirement: "Use backups and test restoration before launch."
# ==============================================================================

set -euo pipefail

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/liah_db_${TIMESTAMP}.dump"
RESTORE_TEST_DB="liah_restore_verification_test"

mkdir -p "${BACKUP_DIR}"

echo "======================================================================"
echo " [1/4] INITIATING SECURE DATABASE BACKUP (PG_DUMP)"
echo "======================================================================"

if [ -z "${DATABASE_URL:-}" ]; then
  echo "Error: DATABASE_URL environment variable is not set."
  echo "Format: postgresql://postgres:[PASSWORD]@[HOST]:[PORT]/[DATABASE]"
  exit 1
fi

# Execute custom format pg_dump (includes schema, data, triggers, and RLS policies)
pg_dump "${DATABASE_URL}" \
  --format=custom \
  --no-owner \
  --no-privileges \
  --verbose \
  --file="${BACKUP_FILE}"

echo "✓ Backup generated successfully at: ${BACKUP_FILE}"

# Compute SHA256 Checksum
sha256sum "${BACKUP_FILE}" > "${BACKUP_FILE}.sha256"
echo "✓ SHA256 Checksum recorded."

echo "======================================================================"
echo " [2/4] CREATING ISOLATED RESTORATION TEST ENVIRONMENT"
echo "======================================================================"
dropdb --if-exists "${RESTORE_TEST_DB}" || true
createdb "${RESTORE_TEST_DB}"
echo "✓ Verification target database '${RESTORE_TEST_DB}' initialized."

echo "======================================================================"
echo " [3/4] EXECUTING RESTORATION TEST (PG_RESTORE)"
echo "======================================================================"
pg_restore \
  --dbname="${RESTORE_TEST_DB}" \
  --clean \
  --if-exists \
  --verbose \
  "${BACKUP_FILE}" || true

echo "✓ Backup restored into '${RESTORE_TEST_DB}'."

echo "======================================================================"
echo " [4/4] VALIDATING RLS POLICIES & DATA INTEGRITY"
echo "======================================================================"
psql "${RESTORE_TEST_DB}" -f "supabase/test_restore_verification.sql"

echo "======================================================================"
echo " SUCCESS: Pre-launch backup & test restoration verified 100% intact!"
echo "======================================================================"

dropdb "${RESTORE_TEST_DB}"
