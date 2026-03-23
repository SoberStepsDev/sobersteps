# Security Policy

## Supported versions

Security fixes are applied to the current `main` branch.

## Reporting a vulnerability

Please report vulnerabilities privately and do not open public issues.

- Preferred channel: email to `sobersteps@pm.me`
- Subject: `SECURITY: <short title>`
- Include:
  - affected component/file
  - impact and attack scenario
  - reproduction steps
  - proof-of-concept (if available)

## Response targets

- Initial acknowledgement: within 72 hours
- Triage status update: within 7 days
- Remediation timeline: shared after triage based on severity

## Disclosure policy

- Do not publish details before a fix is available.
- Coordinated disclosure is supported after patch release.

## Secrets and credentials

- Never commit secrets into the repository.
- Use GitHub Actions secrets for CI/CD.
- Use Supabase Edge Function secrets for function runtime values.
- Secret inventory references are in `.github/SECRETS.md`.

## Security controls in this project

- Row-level security (RLS) on user data tables
- CI checks for migration/RLS review in `.github/workflows/rls-security-review.yml`
- Separate deploy pipeline for Supabase in `.github/workflows/supabase-deploy.yml`
