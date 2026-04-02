# RevenueCat — produkty do utworzenia

## Public API Key
Test key ustawiony w `app_constants.dart`. Produkcyjny: RevenueCat → API keys → skopiuj po dodaniu iOS/Android app.

## Produkty (Product catalog)

| Product ID | Typ | Opis |
|------------|-----|------|
| sobersteps_monthly_699 | Subscription | Miesięczny PRO |
| sobersteps_annual_5999 | Subscription | Roczny PRO |
| sobersteps_family_999 | Subscription | Rodzinny PRO |
| sobersteps_lifetime_8999 | Non-consumable | Dożywotni dostęp |

## iOS
1. Xcode → Runner → Signing & Capabilities → + Capability → **In-App Purchase**
2. App Store Connect → utwórz produkty in-app z tymi ID
3. RevenueCat → dodaj iOS app (bundle: com.sobersteps.sobersteps) → połącz z App Store Connect
