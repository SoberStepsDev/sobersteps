# Git Commit Steps — SoberSteps Q2 2026 Implementation

## Status Check
```bash
cd /sessions/kind-eloquent-cray/mnt/SoberSteps
git status
```

## Expected Changed Files
```
Modified:
 M lib/main.dart
 M lib/constants/app_constants.dart
 M lib/services/supabase_auth_service.dart
 M lib/services/crash_log_ai_service.dart
 M assets/config.dev.env
 M .env.example
 M pubspec.yaml

Untracked (New Files):
 ?? assets/data/quotes_pl.json
 ?? test/services/supabase_auth_service_test.dart
 ?? integration_test/auth_flow_test.dart
 ?? IMPLEMENTATION_REPORT.md
 ?? CI_DEPLOYMENT_GUIDE.md
 ?? WDROŻENIE_STRESZCZENIE.md
 ?? COMMIT_MESSAGE.txt
```

---

## Commit Steps

### Step 1: Stage All Changes
```bash
git add lib/main.dart \
        lib/constants/app_constants.dart \
        lib/services/supabase_auth_service.dart \
        lib/services/crash_log_ai_service.dart \
        assets/config.dev.env \
        assets/data/quotes_pl.json \
        .env.example \
        pubspec.yaml \
        test/services/supabase_auth_service_test.dart \
        integration_test/auth_flow_test.dart \
        IMPLEMENTATION_REPORT.md \
        CI_DEPLOYMENT_GUIDE.md \
        WDROŻENIE_STRESZCZENIE.md \
        COMMIT_MESSAGE.txt
```

### Step 2: Verify Staged Changes
```bash
git diff --cached --stat
```

Should show:
- Code changes (~400 lines total)
- New test files
- New documentation files
- Polish quote translations

### Step 3: Commit
```bash
git commit -F COMMIT_MESSAGE.txt
```

**Note:** COMMIT_MESSAGE.txt already includes `Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>`

Alternative (manual message):
```bash
git commit -m "feat: Implement auth hardening, Claude AI integration, and quote i18n

- PKCE flow for OAuth security
- FlutterSecureStorageAdapter for secure token persistence
- Enhanced error handling in SupabaseAuthService
- Claude AI integration (Anthropic API v1)
- Polish quote translations (30 items)
- Unit & integration tests for auth flow
- CI/CD deployment guide (GitHub Secrets + Actions)

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
```

### Step 4: Verify Commit
```bash
git log -1 --stat
git show --stat HEAD
```

### Step 5: Push to Remote
```bash
# To develop branch (for code review)
git push origin develop

# Or to main (if CI/CD configured)
git push origin main
```

---

## Post-Commit Verification

After push, verify on GitHub:

1. **Check PR (if using develop → main):**
   ```bash
   gh pr create --base main --head develop \
     --title "feat: Implement auth hardening, Claude AI integration, and quote i18n"
   ```

2. **Run CI/CD Tests:**
   - GitHub Actions should trigger
   - Verify all checks pass:
     - ✅ flutter analyze
     - ✅ flutter test
     - ✅ build apk (dev)

3. **Merge to Main (after review):**
   ```bash
   # Via GitHub UI or:
   gh pr merge <pr-number> --squash
   ```

---

## Alternative: Single Branch Commit (main)

If working directly on main:

```bash
git add .  # or specific files listed above
git commit -F COMMIT_MESSAGE.txt
git push origin main
```

⚠️ **Warning:** This skips code review. Recommended: use develop branch + PR.

---

## Rollback (if needed)

```bash
# If commit is not yet pushed
git reset --soft HEAD~1        # Unstage commit, keep changes
git reset --mixed HEAD~1       # Unstage changes
git reset --hard HEAD~1        # Discard commit entirely

# If already pushed
git revert HEAD                # Create reverse commit
git push origin main           # Push revert
```

---

## Files Reference

- **Code:** lib/ assets/ test/ integration_test/
- **Config:** assets/config.dev.env, .env.example, pubspec.yaml
- **Docs:** IMPLEMENTATION_REPORT.md, CI_DEPLOYMENT_GUIDE.md, WDROŻENIE_STRESZCZENIE.md
- **Message:** COMMIT_MESSAGE.txt

**Ready to merge! 🚀**
