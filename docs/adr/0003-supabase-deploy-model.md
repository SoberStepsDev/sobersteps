# ADR 0003: Supabase Deployment Model

## Status
Accepted

## Context
Schema and function changes must be reproducible, auditable, and reversible with minimal operational risk.

## Decision
Use GitHub Actions as the deployment control plane:
- migrations/functions changes on `main` trigger `.github/workflows/supabase-deploy.yml`
- deploy pipeline includes preflight (`db lint`) and post-checks (`migration list`, `functions list`)
- rollback of functions is supported by `.github/workflows/supabase-function-rollback.yml`

Schema rollback remains forward-fix via compensating migrations.

## Consequences
- Deploys are traceable to commits.
- Functions rollback becomes fast and repeatable.
- Schema rollback still requires deliberate SQL compensating migration design.
