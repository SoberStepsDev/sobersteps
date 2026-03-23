# SoberSteps Architecture and Operations

## Runtime architecture

- Client: Flutter app in `lib/`
- Backend: Supabase (Auth, Postgres, RLS, Edge Functions)
- Push: OneSignal
- Billing: RevenueCat

## Main data flow

1. User authenticates via Supabase Auth.
2. App reads/writes user-scoped rows (`profiles`, `journal_entries`, `future_letters`, `milestones_achieved`, `three_am_wall`).
3. RLS policies enforce owner access (`auth.uid() = user_id` or `id`).
4. For offline-first flows, app stores pending operations and syncs later.
5. Scheduled notifications run through `supabase/functions/notify_users`.

## Project layout

- App code: `lib/`
- Unit/widget tests: `test/`
- Integration tests: `integration_test/`
- SQL migrations: `supabase/migrations/`
- Edge Functions: `supabase/functions/`
- CI/CD workflows: `.github/workflows/`

## Deploy operations (Supabase)

Automated deploy is defined in `.github/workflows/supabase-deploy.yml`.

### Required secrets

- `SUPABASE_PROJECT_REF`
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_DB_PASSWORD`

### Pipeline behavior

1. `supabase link --project-ref ...`
2. `supabase db push`
3. `supabase functions deploy`

### Manual deploy

```bash
supabase link --project-ref "$SUPABASE_PROJECT_REF"
supabase db push
supabase functions deploy
```

## Rollback operations

Supabase does not provide a one-command rollback for all migrations. Use forward-fix or controlled restore.

### Migrations rollback strategy

1. Identify breaking migration in `supabase/migrations/`.
2. Create a new compensating migration file that reverts the schema change safely.
3. Run `supabase db push` with the compensating migration.
4. Validate RLS and indexes after revert.

### Functions rollback strategy

1. Re-deploy the last known good function source from git:
   - `git checkout <good_commit> -- supabase/functions/<function_name>/index.ts`
   - `supabase functions deploy <function_name>`
2. If needed, restore current branch state afterward.

### Emergency restore

When schema corruption or data-loss risk is detected:

1. Stop deploy pipeline.
2. Restore DB from managed backup (Supabase backup/point-in-time restore).
3. Re-apply only vetted migrations.
4. Re-deploy known good functions.

## Operational checks after deploy

- Run `flutter analyze` and `flutter test`
- Verify Edge Function logs for errors
- Verify notification cron run (`notify-users-cron.yml`)
- Verify RLS workflow output (`rls-security-review.yml`)
