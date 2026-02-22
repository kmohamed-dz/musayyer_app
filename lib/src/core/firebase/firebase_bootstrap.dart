import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';

class FirebaseBootstrap {
  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await _initializeFirebaseApp();
    }

    if (Firebase.apps.isNotEmpty) {
      _configureFirestore();
    }
  }

  static Future<void> _initializeFirebaseApp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return;
    } on UnsupportedError catch (error) {
      debugPrint('Firebase options are not generated yet: $error');
    } catch (error, stackTrace) {
      debugPrint(
          'Firebase initialization with generated options failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    // Fallback for native platforms that have google-services files configured
    // but are missing flutterfire-generated options.
    try {
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint(
        'Firebase failed to initialize. Run `flutterfire configure` and add '
        'platform config files before using Firestore. Error: $error',
      );
    }
  }

  static void _configureFirestore() {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (error) {
      debugPrint('Failed to configure Firestore settings: $error');
    }
  }
}
