# RevenueCat — sandbox test checklist

Step-by-step verification for all four store products used by SoberSteps. Product IDs match `lib/constants/app_constants.dart` and must exist in App Store Connect / Google Play Console and in the RevenueCat dashboard.

| Product ID | Type (intended) |
|------------|-----------------|
| `sobersteps_monthly_699` | Auto-renewing subscription |
| `sobersteps_annual_5999` | Auto-renewing subscription |
| `sobersteps_family_999` | Auto-renewing subscription |
| `sobersteps_lifetime_8999` | Non-consumable |

---

## 0. Prerequisite (current codebase)

`PurchaseService` is still a **stub**: `init` / `checkPremium` / `purchase` / `restore` do not call RevenueCat yet (`purchases_flutter`). Use this checklist when those calls are wired to RevenueCat with an entitlement such as `premium` (or whatever you map in the dashboard).

Until then:

- `purchase(...)` always returns `false` → `PurchaseProvider.isPremium` stays `false` after a tap.
- You can still validate **store account** setup, **product availability**, and **RevenueCat** configuration outside the app (dashboard + sandbox transactions).

---

## 1. Sandbox tester accounts

### iOS (App Store Connect)

1. App Store Connect → **Users and Access** → **Sandbox** → **Testers**.
2. Add an email not used as a real Apple ID (or use Apple’s sandbox-only flow).
3. On device: **Settings → App Store → Sandbox Account** → sign in with the sandbox Apple ID (iOS 14+ path varies slightly).
4. Build/run a **development** or **TestFlight** build; purchases use sandbox automatically.

### Android (Google Play)

1. Play Console → **Setup** → **License testing** → add Gmail accounts under **License testers**.
2. Upload build to **Internal testing** (or closed track) and join the tester group.
3. Install from Play Store via the testing link; purchases use **test** billing.

---

## 2. RevenueCat project

1. Create offerings / packages that reference the four product IDs above (iOS + Android where applicable).
2. Map purchased products to a single **entitlement** (e.g. `premium`) used when you uncomment / implement:

   `info.entitlements.all['premium']?.isActive`

3. Use the **same** public SDK key as in `AppConstants` (test vs production).

---

## 3. Trigger each product in the app

1. Cold-start the app after `PurchaseProvider.init()` runs (see `main.dart`).
2. Open the paywall: **Profile** → Recovery+ / PRO tile, or any gated feature (e.g. **Lessons** locked lesson, **Accountability Partner**, **Mirror Moment** save, **Craving Surf** soundscape, **Trigger analysis**), or route `/paywall`.
3. On **PaywallScreen**, select a plan row:
   - **Monthly** → `sobersteps_monthly_699`
   - **Annual** → `sobersteps_annual_5999` (default selection in code)
   - **Family** → `sobersteps_family_999`
   - **Lifetime** → `sobersteps_lifetime_8999` (only if `daysSinceInstall >= 90` in current UI)
4. Tap the primary CTA (wired to `PurchaseProvider.purchase(selectedProductId)`).

Repeat once per product (use a fresh sandbox user or consume/cancel per store rules where needed).

---

## 4. Expected behavior after a successful sandbox purchase

- **Paywall**: `Navigator.pop` when `purchase.isPremium` is true (see `PaywallScreen` build).
- **PurchaseProvider**: `isPremium == true`, `active_product_id` in SharedPreferences matches the purchased id, `notifyListeners()` runs so widgets using `context.watch<PurchaseProvider>()` rebuild.
- **Gated UI** (examples that already read `PurchaseProvider.isPremium`):
  - `LessonsScreen` — non-free lessons locked without PRO.
  - `AccountabilityScreen` — full gate + paywall path.
  - `MirrorMomentScreen` — reflection field / save limited without PRO.
  - `CravingSurfScreen` — extra soundscapes locked.
  - `TriggerTrackerScreen` — locked rows.
  - `MilestonesScreen` — voice / paywall nudge paths.
  - `ProfileScreen` — PRO badge / Recovery+ tile behavior.

---

## 5. Restore purchases

1. From paywall: **Restore** / `Przywróć zakupy` → `PurchaseProvider.restore()`.
2. From profile / subscription UI: any control that calls the same restore path.
3. **Expected**: after a valid sandbox receipt / customer info with active entitlement, `isPremium` becomes `true`, paywall can pop if that screen is open and listens to premium, `active_product_id` restored from prefs when applicable.

Negative test: user with no purchases → `restore` leaves `isPremium` false.

---

## 6. Naomi & Return to Self vs PRO

**Current code:** `NaomiProvider` and `ReturnToSelfProvider` do **not** reference `PurchaseProvider` or `isPremium`. Both flows are available to logged-in users regardless of tier.

**What to verify manually:**

- **Naomi** (`NaomiScreen`): confirm journal/rate-limit behavior works the same for free and PRO (no accidental paywall in this module unless you add one later).
- **Return to Self** (`ReturnToSelfScreen`): gated only by **login** (`AuthProvider`), not PRO — confirm progress loads for free users.

For **premium gating**, rely on the screens listed in §4 and on subscription labels via `PurchaseProvider.planDisplayLabel(context)`.

---

## 7. Short pass/fail matrix

| Step | Pass criteria |
|------|----------------|
| Monthly sandbox buy | Entitlement active, PRO UI unlocks, prefs store `sobersteps_monthly_699` |
| Annual sandbox buy | Same with `sobersteps_annual_5999` |
| Family sandbox buy | Same with `sobersteps_family_999` |
| Lifetime sandbox buy | Same with `sobersteps_lifetime_8999`, non-consumable persists |
| Restore | Entitlement restored for existing sandbox purchaser |
| Logout / reinstall (optional) | After RC identity linking, restore still recovers entitlement |

---

## 8. References

- Product list: `docs/REVENUECAT_PRODUCTS.md`
- IDs: `lib/constants/app_constants.dart`
- State: `lib/providers/purchase_provider.dart`
- Store stub (replace with RevenueCat): `lib/services/purchase_service.dart`
