# 🎯 Quick Checklist — Ready to Deploy

## Pre-Commit (Verify Locally)

- [ ] Install dependencies:
  ```bash
  flutter pub get
  ```

- [ ] Run tests:
  ```bash
  flutter test test/services/
  flutter test integration_test/
  ```

- [ ] Check for errors:
  ```bash
  flutter analyze lib/main.dart lib/services/
  ```

  ⚠️ **Note:** 4 Supabase API issues fixed (see BUG_FIXES_APPLIED.md)

- [ ] Verify API key in config.dev.env:
  ```bash
  grep ANTHROPIC_API_KEY assets/config.dev.env | wc -c
  # Should be >50 chars (not empty)
  ```

## Git Commit

- [ ] Stage files (see GIT_COMMIT_STEPS.md):
  ```bash
  git add lib/ assets/ test/ integration_test/ *.md
  ```

- [ ] Commit with message:
  ```bash
  git commit -F COMMIT_MESSAGE.txt
  ```

- [ ] Verify:
  ```bash
  git log -1 --stat
  ```

## Push & Deploy

- [ ] Push to remote:
  ```bash
  git push origin develop  # For review
  git push origin main     # Direct to production
  ```

- [ ] Wait for CI/CD:
  - GitHub Actions: `flutter analyze` + `flutter test`
  - Build APK (dev/prod)
  - Check workflow status

- [ ] Merge PR (if on develop):
  ```bash
  gh pr merge <number>
  ```

## Post-Deploy Verification

- [ ] **Firebase/Supabase:**
  - [ ] Check auth logs (no errors)
  - [ ] Verify session tokens in secure storage

- [ ] **Claude AI:**
  - [ ] Test crash log → "Send and receive reflection"
  - [ ] Verify Polish prompt in response

- [ ] **Quote Translations:**
  - [ ] Set device locale to Polish
  - [ ] Check if quotes load in Polish

- [ ] **Sentry:**
  - [ ] Verify no new crashes reported
  - [ ] Check error tracking

## Files to Review

| File | Purpose | Review |
|------|---------|--------|
| `IMPLEMENTATION_REPORT.md` | Technical details | ✓ Read first |
| `CI_DEPLOYMENT_GUIDE.md` | GitHub Secrets setup | ✓ For DevOps |
| `GIT_COMMIT_STEPS.md` | Commit walkthrough | ✓ Before push |
| `COMMIT_MESSAGE.txt` | Git message | ✓ Ready to use |
| `WDROŻENIE_STRESZCZENIE.md` | Polish summary | ✓ Optional |

---

## GitHub Secrets (Already Set?)

Verify in GitHub → Settings → Secrets and variables → Actions:

- [x] SUPABASE_URL
- [x] SUPABASE_ANON_KEY
- [x] ANTHROPIC_API_KEY
- [x] SENTRY_DSN (optional, for prod)

---

## Rollback Plan (if needed)

```bash
# Undo last commit (before push)
git reset --soft HEAD~1

# If pushed, revert
git revert HEAD
git push origin main
```

---

## Timeline

- **Commit:** 2 min
- **Push:** 1 min
- **CI/CD:** 5-10 min
- **Deploy to Play Store:** 1-2 hours (manual review)

**Total time to production: ~30 min**

---

## Next Steps

1. ✅ Run local tests
2. ✅ Review diffs
3. ✅ Commit
4. ✅ Push
5. ✅ Wait for CI/CD
6. ✅ Merge PR
7. ✅ Monitor Sentry for errors
8. ✅ Release notes on GitHub

**LET'S SHIP IT! 🚀**
