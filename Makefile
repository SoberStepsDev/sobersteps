SUPABASE_URL ?=
SUPABASE_ANON_KEY ?=
ONESIGNAL_APP_ID ?=

.PHONY: help pub-get analyze test test-integration run format clean

help:
	@echo "Available targets:"
	@echo "  make pub-get            - Install dependencies"
	@echo "  make analyze            - Run static analysis"
	@echo "  make test               - Run unit/widget tests"
	@echo "  make test-integration   - Run integration tests (requires target device)"
	@echo "  make run                - Run app with dart-define env vars"
	@echo "  make format             - Format Dart sources"
	@echo "  make clean              - Clean Flutter build outputs"

pub-get:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

test-integration:
	flutter test integration_test

run:
	flutter run \
		--dart-define=SUPABASE_URL=$(SUPABASE_URL) \
		--dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY) \
		--dart-define=ONESIGNAL_APP_ID=$(ONESIGNAL_APP_ID)

format:
	dart format lib test integration_test

clean:
	flutter clean
