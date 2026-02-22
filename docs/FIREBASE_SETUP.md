# Firebase Setup (Firestore + Optional Auth)

This app now stores **products** and **invoices** in Cloud Firestore.

## 1) Create Firebase project

1. Go to Firebase Console: https://console.firebase.google.com/
2. Create a new project (or use an existing one).
3. Add Android app with package: `com.musayyer.app`.
4. Add iOS app with bundle id: `com.musayyer.app` (or your real bundle id).

## 2) Enable Firestore

1. In Firebase Console, open **Firestore Database**.
2. Click **Create database**.
3. Start in test mode for development, then apply secure rules below.
4. Choose a region close to your users.

## 3) Optional: Enable Firebase Auth (recommended)

Auth is optional in this codebase.

- If signed-in user exists, data is stored under that user UID.
- If no Firebase user is signed in, app uses fallback shop id: `default_shop`.

To enable Email/Password auth:

1. Firebase Console -> **Authentication** -> **Sign-in method**.
2. Enable **Email/Password**.

## 4) Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

If needed, add Dart pub cache bin to PATH.

## 5) Configure Flutter app with Firebase

Run in repo root:

```bash
flutterfire configure --project=<YOUR_FIREBASE_PROJECT_ID>
```

Expected outputs:

- `lib/firebase_options.dart` is generated/updated with real `FirebaseOptions`.
- Firebase app IDs and platform config are wired.

## 6) Add platform config files

After `flutterfire configure`, ensure these files exist:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

If missing, download them from Firebase Console -> Project settings -> Your apps.

## 7) Firestore document layout used by app

- Products: `users/{uid}/products/{productId}`
- Invoices: `users/{uid}/invoices/{invoiceId}`

Invoice docs include embedded `items` array and stock is decremented in a Firestore transaction when invoice is created.

## 8) Recommended Firestore security rules (Auth enabled)

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 9) MVP fallback rules for `default_shop` mode (weaker, temporary)

Use only for quick local demos when Firebase Auth is not enabled.

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/default_shop/{document=**} {
      allow read, write: if true;
    }
  }
}
```

This is insecure for production. Move to authenticated user rules before release.

## 10) Offline behavior

- Firestore offline cache is enabled in app startup.
- Mobile SDK already supports local persistence.
- Writes queue locally and sync when network returns.

## 11) Run checks

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

If startup fails with Firebase initialization errors, rerun `flutterfire configure` and verify platform config files are in place.
