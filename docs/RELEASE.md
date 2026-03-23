# Release Management

## Versioning policy

Use Semantic Versioning in `pubspec.yaml`:
- `MAJOR`: breaking behavior or incompatible API/schema expectations
- `MINOR`: backward-compatible features
- `PATCH`: backward-compatible fixes

For mobile builds:
- Keep `version: x.y.z+buildNumber`
- Increase `buildNumber` for every store upload

## Release flow

1. Update `CHANGELOG.md` under a new version heading.
2. Bump `pubspec.yaml` version (`x.y.z+N`).
3. Verify CI green (`flutter-ci.yml`).
4. Create release commit and tag (`vX.Y.Z`).
5. Build Android+iOS artifacts via `.github/workflows/release-build.yml` (manual dispatch).
6. Submit binaries to stores (Play Console / App Store Connect).

## Pre-release checklist (common)

- [ ] `flutter pub get`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter test integration_test/smoke_test.dart` (target device)
- [ ] `SUPABASE_URL` / `SUPABASE_ANON_KEY` confirmed for release env
- [ ] OneSignal/RevenueCat keys validated
- [ ] `CHANGELOG.md` updated
- [ ] Version bumped in `pubspec.yaml`

## Android checklist

- [ ] Keystore/signing config valid
- [ ] `flutter build appbundle --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- [ ] Install test on physical device
- [ ] Validate deep links, push notifications, paywall
- [ ] Upload AAB to Play Console (internal track first)
- [ ] Verify Play pre-launch report

## iOS checklist

- [ ] Signing/provisioning profiles valid in Xcode
- [ ] `flutter build ipa --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- [ ] TestFlight smoke test on device
- [ ] Validate deep links, push notifications, paywall
- [ ] Upload to App Store Connect

## Rollback

- App rollback: pause rollout / revert store release to previous approved build.
- Backend rollback: follow `docs/ARCHITECTURE.md` rollback section (compensating migration + redeploy known good function).
- Fast function rollback is available via `.github/workflows/supabase-function-rollback.yml`.
