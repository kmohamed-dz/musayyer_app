import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../debt/data/models/debt_model.dart';
import '../../../inventory/presentation/providers/product_providers.dart';
import '../../../invoice/data/models/invoice_item_model.dart';
import '../../../invoice/data/models/invoice_model.dart';

class TopProductStat {
  TopProductStat({required this.name, required this.units});

  final String name;
  final int units;
}

class DailyRevenue {
  DailyRevenue({required this.date, required this.revenue});

  final DateTime date;
  final double revenue;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

final todayRevenueProvider = Provider<double>((ref) {
  final invoices = Hive.box<InvoiceModel>(HiveBoxes.invoices).values;
  final today = DateTime.now();

  return invoices
      .where((invoice) => _isSameDay(invoice.createdAt, today))
      .fold<double>(0, (sum, invoice) => sum + invoice.paidAmount);
});

final todaySalesCountProvider = Provider<int>((ref) {
  final invoices = Hive.box<InvoiceModel>(HiveBoxes.invoices).values;
  final today = DateTime.now();
  return invoices.where((invoice) => _isSameDay(invoice.createdAt, today)).length;
});

final totalUnpaidDebtsProvider = Provider<double>((ref) {
  final debts = Hive.box<DebtModel>(HiveBoxes.debts).values;
  return debts.fold<double>(0, (sum, debt) => sum + debt.remainingAmount);
});

final topProductsWeekProvider = Provider<List<TopProductStat>>((ref) {
  final invoiceBox = Hive.box<InvoiceModel>(HiveBoxes.invoices);
  final itemBox = Hive.box<InvoiceItemModel>(HiveBoxes.invoiceItems);
  final now = DateTime.now();
  final weekStart = now.subtract(const Duration(days: 7));

  final Map<String, int> unitsByProduct = {};

  for (final invoice in invoiceBox.values) {
    if (invoice.createdAt.isBefore(weekStart)) {
      continue;
    }

    for (final itemId in invoice.itemIds) {
      final item = itemBox.get(itemId);
      if (item == null) {
        continue;
      }

      unitsByProduct.update(
        item.productName,
        (units) => units + item.quantity,
        ifAbsent: () => item.quantity,
      );
    }
  }

  final stats = unitsByProduct.entries
      .map((entry) => TopProductStat(name: entry.key, units: entry.value))
      .toList()
    ..sort((a, b) => b.units.compareTo(a.units));

  return stats.take(3).toList();
});

final weeklyRevenueProvider = Provider<List<DailyRevenue>>((ref) {
  final invoices = Hive.box<InvoiceModel>(HiveBoxes.invoices).values;
  final now = DateTime.now();

  return List.generate(7, (index) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
    final revenue = invoices
        .where((invoice) => _isSameDay(invoice.createdAt, date))
        .fold<double>(0, (sum, invoice) => sum + invoice.paidAmount);

    return DailyRevenue(date: date, revenue: revenue);
  });
});

final lowStockDashboardProvider = Provider((ref) {
  return ref.watch(lowStockProductsProvider);
});
