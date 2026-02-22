import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestorePaths {
  static const defaultShopId = 'default_shop';

  static String resolveShopId() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      }
    } catch (_) {
      // Firebase Auth can be unavailable when not configured.
    }
    return defaultShopId;
  }

  static CollectionReference<Map<String, dynamic>> products(
    FirebaseFirestore firestore, {
    String? shopId,
  }) {
    return firestore
        .collection('users')
        .doc(shopId ?? resolveShopId())
        .collection('products');
  }

  static CollectionReference<Map<String, dynamic>> invoices(
    FirebaseFirestore firestore, {
    String? shopId,
  }) {
    return firestore
        .collection('users')
        .doc(shopId ?? resolveShopId())
        .collection('invoices');
  }
}
