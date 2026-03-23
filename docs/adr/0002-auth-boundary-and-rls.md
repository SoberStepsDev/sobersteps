# ADR 0002: Auth Boundary and Data Access

## Status
Accepted

## Context
SoberSteps handles sensitive recovery data. Client-side restrictions alone are insufficient.

## Decision
Enforce authorization at database level via RLS on every user table with owner scope:
- `auth.uid() = user_id` (or `id` for profile table)

Client/app layer remains a UX boundary only; security boundary is Supabase Auth + RLS.

## Consequences
- Stronger data isolation by default.
- Any new table requires explicit RLS policy before production use.
- Service-role operations must be limited to trusted Edge Functions/workflows.
