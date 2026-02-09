# Musayyer (مسير)

Musayyer is a production-ready Flutter mobile app scaffold built with clean architecture. It includes onboarding, authentication, and an extensible API layer so you can move quickly from MVP to production.

## ✨ Features

- Clean architecture (data/domain/presentation)
- Onboarding flow with persistence
- Authentication flow with secure token storage
- API layer with `Dio` and environment configuration
- Riverpod + GoRouter wiring for state + routing

## 📦 Tech Stack

- Flutter (Material 3)
- Riverpod
- GoRouter
- Dio
- Shared Preferences + Flutter Secure Storage

## 🧱 Project Structure

```
lib/
  main.dart
  src/
    app.dart
    core/
      api/
      config/
      routing/
      storage/
      theme/
      utils/
    features/
      auth/
      home/
      onboarding/
```

## 🚀 Getting Started

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Fetch dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## ✅ Recommended Next Steps

- Replace the mock login endpoint with your backend.
- Add localization, analytics, and crash reporting.
- Extend the home screen with domain-specific features.

## 🧪 Testing

```bash
flutter test
```

## 🔐 Notes on Authentication

- Tokens are stored in `FlutterSecureStorage`.
- Onboarding completion is stored in `SharedPreferences`.

## 📄 License

MIT
