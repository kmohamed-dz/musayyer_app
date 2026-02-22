import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/db/hive_boxes.dart';
import 'src/core/di/providers.dart';
import 'src/features/customers/data/models/customer_model.dart';
import 'src/features/debt/data/models/debt_model.dart';
import 'src/features/debt/data/models/payment_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive (still used for customers, debts, and payments)
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(DebtModelAdapter());
  Hive.registerAdapter(PaymentModelAdapter());

  // Open boxes
  await Hive.openBox<CustomerModel>(HiveBoxes.customers);
  await Hive.openBox<DebtModel>(HiveBoxes.debts);
  await Hive.openBox<PaymentModel>(HiveBoxes.payments);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MusayyerApp(),
    ),
  );
}
