# HindiFlow

**English-to-Hindi translation for Flutter apps.**

HindiFlow is a Flutter package that makes it easy to translate English text into Hindi using a hosted AI translation API. It provides a simple translation method, optional caching, recursive JSON translation, and a convenient `HindiText` widget.

## Features

- 🇬🇧 Translate English text into Hindi.
- ⚡ Simple API with no required initialization for the default endpoint.
- 🔗 Configure a custom API endpoint when needed.
- 💾 Cache translations in memory and with `SharedPreferences`.
- 🧩 Translate strings inside nested JSON-like maps and lists.
- 🎨 Display translations using the `HindiText` widget.
- ⏱️ Configure request timeouts.
- 🛡️ Clear error reporting through `HindiFlowException`.

## Installation

Add HindiFlow to your Flutter project:

```bash
flutter pub add hindi_flow
```

Or add it to your `pubspec.yaml`:

```yaml
dependencies:
  hindi_flow: ^0.1.0
```

Then run:

```bash
flutter pub get
```

> **Note:** Use the latest version available on [pub.dev](https://pub.dev/packages/hindi_flow). If a newer version has been published, use that version instead of `0.1.0`.

## Quick start

Import the package:

```dart
import 'package:hindi_flow/hindi_flow.dart';
```

Translate your first sentence:

```dart
final hindi = await HindiFlow.translate(
  'How are you my friend?',
);

print(hindi);
// आप कैसे हैं मेरे दोस्त?
```

The default API endpoint is built into the package. You do not need to call `HindiFlow.initialize()` before translating with the default configuration.

## Configure a custom API

If you operate your own compatible translation API, configure it before making translation requests:

```dart
await HindiFlow.initialize(
  baseUrl: 'https://your-api.example.com',
);
```

You can also configure a request timeout:

```dart
await HindiFlow.initialize(
  baseUrl: 'https://your-api.example.com',
  timeout: const Duration(seconds: 60),
);
```

The API base URL should not include the `/translate` path. HindiFlow appends that path automatically.

Calling `initialize()` is optional when using the built-in default endpoint.

## Translate multiple strings

Translate different pieces of text with the same simple method:

```dart
final greeting = await HindiFlow.translate('Good morning');
final welcome = await HindiFlow.translate('Welcome to our app');
final thanks = await HindiFlow.translate('Thank you');

print(greeting);
print(welcome);
print(thanks);
```

## Translate JSON data

Use `translateJson()` to recursively translate string values in maps and lists.

```dart
final data = {
  'title': 'Welcome',
  'description': 'How are you?',
  'items': [
    'Good morning',
    'Thank you',
  ],
  'count': 3,
};

final translatedData = await HindiFlow.translateJson(data);

print(translatedData);
```

String values are translated recursively. Map keys and non-string values remain unchanged.

**Important:** Each string may require a separate translation request unless the result is already cached. Large JSON structures can therefore take longer to process.

## Use the HindiText widget

HindiFlow also provides a `HindiText` widget for displaying translated text in your Flutter UI.

```dart
HindiText(
  'Welcome to HindiFlow!',
  placeholder: 'Translating...',
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
)
```

The widget translates the supplied text asynchronously and displays the translated result.

For the best experience, use it inside a widget tree where its available layout space is properly constrained.

## Translation caching

HindiFlow caches translations to reduce repeated API requests.

By default, caching is enabled:

```dart
final result = await HindiFlow.translate(
  'Good morning',
);
```

To bypass the cache for a request:

```dart
final result = await HindiFlow.translate(
  'Good morning',
  useCache: false,
);
```

Clear saved translation entries when needed:

```dart
await HindiFlow.clearCache();
```

This clears HindiFlow's in-memory cache and its persisted cache entries.

## Error handling

Translation requests can fail because of network problems, timeouts, invalid API responses, or server errors.

Handle errors in your application:

```dart
try {
  final result = await HindiFlow.translate(
    'How are you?',
  );

  print(result);
} on HindiFlowException catch (e) {
  print('HindiFlow error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

Always provide appropriate loading and error states in production applications.

## API requirements

HindiFlow expects a compatible translation API that accepts a JSON request at `POST /translate`.

Example request:

```json
{
  "text": "How are you my friend?",
  "source_language": "eng_Latn",
  "target_language": "hin_Deva"
}
```

The API should return JSON containing a non-empty `translated_text` field.

Example response:

```json
{
  "original_text": "How are you my friend?",
  "translated_text": "आप कैसे हैं मेरे दोस्त?",
  "source_language": "en",
  "target_language": "hi"
}
```

The default hosted API is configured in the package. Custom APIs must implement a compatible request and response format.

## Dependencies

HindiFlow uses:

- `http` for HTTP requests.
- `shared_preferences` for persistent translation caching.

These dependencies are managed by Flutter's package system.

## Requirements

- Flutter
- Dart SDK compatible with the package's `pubspec.yaml`
- Internet access to reach the configured translation API

## Important notes

- The default API is a hosted service and may have usage limits, availability constraints, or operating costs.
- Translation results depend on the underlying AI model and may not always be perfect.
- Do not send sensitive or confidential text unless your API and data-handling arrangements are appropriate for that information.
- For public or commercial deployments, use appropriate server-side rate limiting, monitoring, and access controls.
- The package's default endpoint is public-facing; embedding its URL in a Flutter app does not provide authentication or protect the endpoint from abuse.

## Example application

Explore the `example/` directory in this repository to see HindiFlow working in a Flutter application, including text input, sample phrases, translation output, and copy-to-clipboard functionality.

## Contributing

Contributions, bug reports, and suggestions are welcome. Please include reproducible steps when reporting a bug.

## License

See the `LICENSE` file in this repository for the applicable license terms.
  