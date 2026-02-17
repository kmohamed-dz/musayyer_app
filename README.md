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
similar markets. It helps merchants run their store day-to-day with less chaos by providing a simple system to manage inventory, make sales, generate invoices, and track customer debts, even when there’s no internet. 

Musayyer_Project_Brief_EN

In the MVP, Musayyer includes: product inventory management, product search/filtering, a point-of-sale (POS) interface, invoice generation, debt (credit) tracking with payment recording, a daily sales dashboard, store profile/settings, multi-language readiness, and offline-first functionality. It also supports using the camera for barcode scanning to speed up checkout and reduce manual entry (and optionally for product photos and attaching documents). 

Musayyer_Project_Brief_EN

Musayyer’s long-term vision is bigger than a single shop app: it evolves into a full B2B commerce ecosystem. In Phase 2, it adds cloud backup, multi-device sync, advanced analytics, and data export (PDF/Excel). In Phase 3, it becomes a wholesaler marketplace with supplier catalogs and direct ordering. In Phase 4, it adds a delivery marketplace connecting shops with couriers, delivery requests, and ratings—linking merchants, suppliers, and logistics in one platform. 

Musayyer_Project_Brief_EN

The business model is designed to scale: a freemium entry plan, monthly subscription for premium features, and later commissions on wholesaler and delivery transactions, plus sponsored supplier listings. Marketing focuses on simple positioning (“The simplest way to run your shop”), on-ground acquisition in retail areas, partnerships with wholesalers, social media demos, WhatsApp merchant groups, and referrals, with retention driven by reminders and weekly performance summaries.
