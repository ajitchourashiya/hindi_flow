# HindiFlow

A reusable Flutter package for English-to-Hindi translation using a configurable HTTP translation backend.

## Important architecture note

The translation model runs on your backend, not inside the Flutter package. The package sends text to `POST /translate` and expects JSON containing `translated_text`. The included demo is preconfigured to use the current HindiFlow Cloudflare Worker: `https://hindiflow-api.contact-internchoice.workers.dev`. This is a public endpoint; model usage may be billed or subject to provider limits, so review Cloudflare Workers AI pricing and usage limits before production use.

## Setup

Add the package from your local path while developing:

```yaml
dependencies:
  hindi_flow:
    path: ../hindi_flow
```

Configure once before using the package:

```dart
await HindiFlow.initialize(
  baseUrl: 'https://YOUR-STABLE-API.example.com',
);
```

## Translate one sentence

```dart
final hindi = await HindiFlow.translate('Welcome to HindiFlow!');
print(hindi);
```

## Translate API JSON

Only string values are translated. Keys, numbers, booleans and null values are preserved.

```dart
final translated = await HindiFlow.translateJson({
  'title': 'Welcome',
  'description': 'Find nearby services',
  'id': 42,
  'active': true,
});
```

Nested maps and lists are handled recursively. For production APIs, prefer translating only user-facing fields, not identifiers, URLs, email addresses, codes or machine-readable values.

## Widget

```dart
HindiText(
  'Welcome to HindiFlow!',
  style: const TextStyle(fontSize: 20),
  placeholder: 'Translating...',
)
```

`HindiText` translates the supplied text asynchronously. Existing Flutter `Text` widgets are not automatically intercepted; use `HindiText` or `HindiFlow.translate()` explicitly.

## Backend contract

Request:

```http
POST /translate
Content-Type: application/json

{"text":"Welcome to HindiFlow!"}
```

Response:

```json
{
  "original_text": "Welcome to HindiFlow!",
  "translated_text": "हिंदीफ्लो में आपका स्वागत है!",
  "source_language": "en",
  "target_language": "hi"
}
```

## Cache

Translations are cached in memory and in SharedPreferences. Call `HindiFlow.clearCache()` when needed. The cache key includes source language, target language and text.

## Run example

From the package root, generate platform scaffolding once, then run:

```bash
cd example
flutter create --platforms=android,web,windows .
flutter pub get
flutter run
```

Start an emulator or connect a device first. The example defaults to `https://hindiflow-api.contact-internchoice.workers.dev`. You can change it from the API settings panel in the demo UI.

## Before publishing to pub.dev

1. Replace `YOUR_USERNAME` links in `pubspec.yaml`.
2. Deploy a stable HTTPS backend and configure its URL.
3. Add backend authentication/rate limiting; never ship Hugging Face or ngrok tokens in the app.
4. Run `flutter analyze` and `flutter test`.
5. Review privacy, caching and translation accuracy for your use case.
6. Run `dart pub publish --dry-run`, then `dart pub publish`.

This is a starter implementation. It does not make a Colab URL permanent and should not be published as production-ready until the backend is secured and deployed.


## Widget initialization order

Call `HindiFlow.initialize(...)` before displaying `HindiText`. The example app displays an instruction until initialization completes, then mounts the widget so translation starts with the configured API URL.
