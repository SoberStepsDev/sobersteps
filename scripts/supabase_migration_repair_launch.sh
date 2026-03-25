#!/usr/bin/env bash
# Launch checklist: align remote migration history with DB (owner machine only).
# Plik 20260323_return_to_self_sync.sql → wersja w historii to 20260323 (14 znaków), nie 20260323000000.
# Requires: supabase CLI, SUPABASE_ACCESS_TOKEN, DB password (lub insert SQL przez MCP jak przy odrzuconym haśle).
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  echo "Set SUPABASE_ACCESS_TOKEN (Supabase Dashboard → Account → Access Tokens)." >&2
  exit 1
fi

PROJECT_REF="${SUPABASE_PROJECT_REF:-kznhbcwozpjflewlzxnu}"
supabase link --project-ref "$PROJECT_REF" --yes

repair() { supabase migration repair --status applied "$1"; }

repair 20260311000001
repair 20260313000001
repair 20260318000001
repair 20260319000001
repair 20260320000001
repair 20260320000002
repair 20260321000001
repair 20260323
repair 20260323000001
repair 20260323000002
repair 20260324000001

echo "--- supabase migration list ---"
supabase migration list
