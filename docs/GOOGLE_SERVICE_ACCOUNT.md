# Service Account JSON — RevenueCat / Google Play

## Opcja A: Google Cloud Console (ręcznie)

1. Otwórz https://console.cloud.google.com/
2. Wybierz projekt (lub utwórz: **Select a project** → **New Project** → np. "SoberSteps")
3. **IAM & Admin** → **Service Accounts** → **+ Create Service Account**
4. Name: `sobersteps-revenuecat` → **Create and Continue** → **Done**
5. Kliknij utworzone konto → **Keys** → **Add Key** → **Create new key** → **JSON** → **Create**
6. Zapisz plik jako `google-service-account.json` (nie commituj do repo)

## Opcja B: gcloud CLI

```bash
# Zainstaluj: https://cloud.google.com/sdk/docs/install
# brew install google-cloud-sdk
# gcloud auth login

export PROJECT_ID="sobersteps"  # lub ID twojego projektu
gcloud config set project $PROJECT_ID
gcloud iam service-accounts create sobersteps-revenuecat --display-name="SoberSteps RevenueCat"
gcloud iam service-accounts keys create google-service-account.json \
  --iam-account=sobersteps-revenuecat@${PROJECT_ID}.iam.gserviceaccount.com
```

## Google Play Console

1. Play Console → **Setup** → **API access** → **Link** (jeśli nie połączone)
2. Wybierz projekt Google Cloud
3. **Create new service account** → otwiera Cloud Console
4. Po utworzeniu: Play Console → **Grant access** → wybierz konto → **View financial data** → **Invite**

## RevenueCat

W RevenueCat → Apps → Android → **Service Account Credentials**: wklej zawartość pliku JSON.
