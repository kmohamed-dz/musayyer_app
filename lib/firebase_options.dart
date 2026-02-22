import 'package:firebase_core/firebase_core.dart';

/// Placeholder file for local development before running FlutterFire CLI.
///
/// Replace this file by running:
/// `flutterfire configure --project=<your-firebase-project-id>`
///
/// The generated file provides real [FirebaseOptions] for each platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'DefaultFirebaseOptions is not configured. '
      'Run `flutterfire configure` to generate lib/firebase_options.dart.',
    );
  }
}

bool get isFirebaseOptionsPlaceholder {
  try {
    // Ignore result; this only checks whether options are generated.
    DefaultFirebaseOptions.currentPlatform;
    return false;
  } on UnsupportedError {
    return true;
  }
}
