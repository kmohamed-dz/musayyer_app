import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/storage/storage_keys.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musayyer Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(localStorageProvider).remove(StorageKeys.authToken);
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Operator',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('You are ready to start building your Musayyer modules.'),
            SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: Icon(Icons.inventory_2),
                title: Text('Inventory'),
                subtitle: Text('Track products and stock levels.'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('Invoices'),
                subtitle: Text('Review daily and monthly sales.'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.people_alt),
                title: Text('Debts'),
                subtitle: Text('Monitor customer balances and payments.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
