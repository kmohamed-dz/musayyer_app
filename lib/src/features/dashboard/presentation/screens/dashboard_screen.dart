import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/hive_boxes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../debt/data/models/debt_model.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final Box debtBox;
  late final Box invoiceBox;
  late final Box productBox;

  @override
  void initState() {
    super.initState();
    debtBox = Hive.box<DebtModel>(HiveBoxes.debts);
    invoiceBox = Hive.box(HiveBoxes.invoices);
    productBox = Hive.box(HiveBoxes.products);

    debtBox.listenable().addListener(_triggerRefresh);
    invoiceBox.listenable().addListener(_triggerRefresh);
    productBox.listenable().addListener(_triggerRefresh);
  }

  @override
  void dispose() {
    debtBox.listenable().removeListener(_triggerRefresh);
    invoiceBox.listenable().removeListener(_triggerRefresh);
    productBox.listenable().removeListener(_triggerRefresh);
    super.dispose();
  }

  void _triggerRefresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storage = ref.read(localStorageProvider);
    final shopName = storage.getString(StorageKeys.shopName) ?? l10n.appName;
    final todayRevenue = ref.watch(todayRevenueProvider);
    final todaySalesCount = ref.watch(todaySalesCountProvider);
    final totalUnpaidDebts = ref.watch(totalUnpaidDebtsProvider);
    final topProducts = ref.watch(topProductsWeekProvider);
    final weeklyRevenue = ref.watch(weeklyRevenueProvider);
    final lowStockProducts = ref.watch(lowStockDashboardProvider);

    final debts = Hive.box<DebtModel>(HiveBoxes.debts).values;
    final debtCustomersCount = debts.where((debt) => debt.remainingAmount > 0).map((d) => d.customerId).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${l10n.goodMorning}, $shopName',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('${l10n.today}: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: l10n.todayRevenue,
                  value: '${todayRevenue.toStringAsFixed(2)} ${l10n.dzd}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                  title: l10n.todaySales,
                  value: l10n.salesCount(todaySalesCount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _KpiCard(
            title: l10n.totalDebts,
            value: '${totalUnpaidDebts.toStringAsFixed(2)} ${l10n.dzd} (${l10n.customersCount(debtCustomersCount)})',
          ),
          const SizedBox(height: 16),
          Text(l10n.topProductsWeek, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: topProducts.isEmpty
                  ? Text(l10n.noSalesThisWeek)
                  : Column(
                      children: [
                        for (var i = 0; i < topProducts.length; i++)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${i + 1}. ${topProducts[i].name}'),
                            trailing: Text('${topProducts[i].units} ${l10n.units}'),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.weeklyRevenueChart, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 180,
                child: _WeeklyRevenueChart(data: weeklyRevenue),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.lowStockAlerts, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (lowStockProducts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.noLowStockProducts),
              ),
            ),
          for (final product in lowStockProducts)
            Card(
              child: ListTile(
                title: Text(product.nameAr.isNotEmpty ? product.nameAr : product.name),
                subtitle: Text(l10n.leftCount(product.stock)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/inventory/edit/${product.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyRevenueChart extends StatelessWidget {
  const _WeeklyRevenueChart({required this.data});

  final List<DailyRevenue> data;

  @override
  Widget build(BuildContext context) {
    final maxRevenue = data.fold<double>(0, (maxValue, item) => item.revenue > maxValue ? item.revenue : maxValue);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final item in data)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 16,
                        height: maxRevenue == 0 ? 4 : (item.revenue / maxRevenue) * 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(DateFormat('E').format(item.date)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
