# Contributing

## Scope

Contributions are welcome for app code, tests, docs, and Supabase backend changes.

## Branch and PR process

1. Create a feature branch from `main`.
2. Keep PRs focused and small.
3. Include tests/docs for behavioral changes.
4. Open PR with clear summary and test plan.

## Quality gates

Before opening PR:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

For backend changes:

- Include migration files in `supabase/migrations/`
- Keep RLS rules aligned with user ownership
- Validate function behavior locally or via staging

## Commit style

Use concise, intent-first commit messages. Preferred prefixes:
- `fix:`
- `feat:`
- `docs:`
- `test:`
- `chore:`

## Security

Do not commit secrets or tokens. Follow `SECURITY.md` and `.github/SECRETS.md`.
