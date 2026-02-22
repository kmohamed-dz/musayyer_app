# Musayyer (مسير)

Musayyer is a Flutter app for small-shop operations (inventory, POS, invoices, debts, and dashboard).

## Backend Status

Products and invoices now use **Firebase Firestore** as the backend.

- Product path: `users/{uid}/products/{productId}`
- Invoice path: `users/{uid}/invoices/{invoiceId}`
- Invoice creation decrements stock with a **Firestore transaction**
- Barcode lookup reads from Firestore

Auth behavior:

- If Firebase Auth user exists, `uid` is used for tenant scope.
- If not signed in, app falls back to `default_shop` (MVP mode).

## Tech Stack

- Flutter
- Riverpod + GoRouter
- Firebase Core + Cloud Firestore (+ optional Firebase Auth)
- Hive (still used for customers/debts/payments local data)
- SharedPreferences

## Quick Start

1. Install Flutter SDK.
2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase (required):

```bash
flutterfire configure --project=<YOUR_FIREBASE_PROJECT_ID>
```

4. Run:

```bash
flutter run
```

## Firebase Setup Guide

Detailed steps are in `docs/FIREBASE_SETUP.md`.

That doc includes:

- Firebase Console setup
- Firestore/Auth setup
- `flutterfire configure` commands
- Required platform files (`google-services.json`, `GoogleService-Info.plist`)
- Security rules (auth and fallback MVP mode)

## Placeholder `firebase_options.dart`

This repository includes a placeholder `lib/firebase_options.dart` so code compiles before Firebase is configured.

After running `flutterfire configure`, that file should be replaced by generated values.

## Quality Checks

```bash
flutter analyze
flutter test
```
