import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Musayyer Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.name ?? 'Operator'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('You are ready to start building your Musayyer modules.'),
            const SizedBox(height: 24),
            const Card(
              child: ListTile(
                leading: Icon(Icons.inventory_2),
                title: Text('Inventory'),
                subtitle: Text('Track products and stock levels.'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('Invoices'),
                subtitle: Text('Review daily and monthly sales.'),
              ),
            ),
            const Card(
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
