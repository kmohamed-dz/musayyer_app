import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../data/models/customer_model.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<CustomerModel>(HiveBoxes.customers);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search customer',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (_, Box<CustomerModel> value, __) {
                  final customers = value.values
                      .where((customer) =>
                          _query.isEmpty || customer.name.toLowerCase().contains(_query))
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));

                  if (customers.isEmpty) {
                    return const Center(child: Text('No customers'));
                  }

                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (_, index) {
                      final customer = customers[index];
                      return ListTile(
                        onTap: () => context.push('/customers/${customer.id}'),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone ?? '-'),
                        trailing: _DebtBadge(amount: customer.totalDebt),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DebtBadge extends StatelessWidget {
  const _DebtBadge({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final hasDebt = amount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasDebt ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${amount.toStringAsFixed(2)} DZD',
        style: TextStyle(
          color: hasDebt ? Colors.red.shade900 : Colors.green.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
