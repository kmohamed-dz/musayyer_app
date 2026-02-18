import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/core/db/hive_boxes.dart';
import 'src/core/di/providers.dart';
import 'src/core/utils/seed_data.dart';
import 'src/features/customers/data/models/customer_model.dart';
import 'src/features/debt/data/models/debt_model.dart';
import 'src/features/debt/data/models/payment_model.dart';
import 'src/features/inventory/data/models/product_model.dart';
import 'src/features/invoice/data/models/invoice_item_model.dart';
import 'src/features/invoice/data/models/invoice_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(InvoiceModelAdapter());
  Hive.registerAdapter(InvoiceItemModelAdapter());
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(DebtModelAdapter());
  Hive.registerAdapter(PaymentModelAdapter());

  // Open boxes
  await Hive.openBox<ProductModel>(HiveBoxes.products);
  await Hive.openBox<InvoiceModel>(HiveBoxes.invoices);
  await Hive.openBox<InvoiceItemModel>(HiveBoxes.invoiceItems);
  await Hive.openBox<CustomerModel>(HiveBoxes.customers);
  await Hive.openBox<DebtModel>(HiveBoxes.debts);
  await Hive.openBox<PaymentModel>(HiveBoxes.payments);

  // Seed demo data
  await SeedData.seedDemoProducts();

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
