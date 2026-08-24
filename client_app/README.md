# Pocket Khoroch

## Run the app

The Gemini API key must not be committed. Create `tool/secrets.secrets.json` locally:

```json
{
  "GEMINI_API_KEY": "your-gemini-api-key"
}
```

Then run Flutter with:

```powershell
flutter run -d chrome --dart-define-from-file=tool/secrets.secrets.json
```

For GitHub Actions or release builds, store `GEMINI_API_KEY` as a repository secret and pass it with `--dart-define=GEMINI_API_KEY=...`.

Note: `dart-define` values are compiled into the client application and are not truly secret. For production, call Gemini through a backend service and keep the API key there.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
