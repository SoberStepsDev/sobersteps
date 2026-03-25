# Branch Protection Baseline (GitHub settings)

Apply these settings to `main` in GitHub repository settings:

## Required checks

- `Flutter CI / analyze-and-test`
- `PR Policy Checks / policy`
- `Dependency Review / dependency-review`
- `Secret Scan / gitleaks`
- `CodeQL / analyze (javascript-typescript)`
- `CodeQL / analyze (python)`
- `Integration E2E / macos-smoke`

## Required review policy

- Require pull request before merging
- Require at least 1 approval
- Dismiss stale approvals when new commits are pushed
- Require review from Code Owners

## History and merge safety

- Require linear history
- Block force pushes
- Block deletions of `main`

## Admin hardening

- Apply rules to administrators
- Restrict who can push directly to `main`
