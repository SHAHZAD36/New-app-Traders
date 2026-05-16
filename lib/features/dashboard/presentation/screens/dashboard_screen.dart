import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../../../products/presentation/screens/product_list_screen.dart';
import '../../../customers/presentation/screens/customer_list_screen.dart';
import '../../../sales/presentation/screens/new_sale_screen.dart';
import '../../../expenses/presentation/screens/expense_list_screen.dart';
import '../../../purchases/presentation/screens/purchase_list_screen.dart';
import '../../../collections/presentation/screens/collection_list_screen.dart';
import '../../../cash_book/presentation/screens/cash_book_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('چوہدری ٹریڈرز'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(dashboardProvider.notifier).loadStats())],
      ),
      drawer: _buildDrawer(context),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خرابی: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).loadStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _summaryGrid(context, stats),
              const SizedBox(height: 24),
              _sectionTitle(context, 'حالیہ فروخت (Recent Sales)'),
              const SizedBox(height: 8),
              _recentSales(stats),
              const SizedBox(height: 24),
              _sectionTitle(context, 'کم اسٹاک الرٹس (Low Stock Alerts)'),
              const SizedBox(height: 8),
              _lowStock(stats),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewSaleScreen())),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('نئی فروخت'),
      ),
    );
  }

  Widget _summaryGrid(BuildContext context, DashboardStats s) {
    final f = NumberFormat('#,##0');
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
      children: [
        _card(context, 'آج کی فروخت', 'Rs. ${f.format(s.todaySales)}', Icons.trending_up, Colors.blue),
        _card(context, 'آج کی وصولی', 'Rs. ${f.format(s.todayCollections)}', Icons.account_balance_wallet, Colors.green),
        _card(context, 'کل واجب الادا', 'Rs. ${f.format(s.totalReceivable)}', Icons.pending_actions, Colors.orange),
        _card(context, 'اسٹاک ویلیو', 'Rs. ${f.format(s.totalStockValue)}', Icons.inventory_2, Colors.purple),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28), const Spacer(),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
        ],
      )),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) =>
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));

  Widget _recentSales(DashboardStats s) {
    if (s.recentSales.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('کوئی فروخت نہیں ملی'))));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: s.recentSales.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final sale = s.recentSales[i];
          final isCash = sale['payment_type'] == 'Cash';
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isCash ? Colors.green[100] : Colors.orange[100],
              child: Icon(isCash ? Icons.payments : Icons.credit_card, color: isCash ? Colors.green : Colors.orange, size: 20),
            ),
            title: Text(sale['shop_name'] ?? 'نامعلوم', style: const TextStyle(fontSize: 14)),
            subtitle: Text(sale['date'] ?? '', style: const TextStyle(fontSize: 11)),
            trailing: Text('Rs. ${NumberFormat('#,##0').format(sale['net_amount'])}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _lowStock(DashboardStats s) {
    if (s.lowStockProducts.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('تمام پروڈکٹس کا اسٹاک ٹھیک ہے'),
      ])));
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: s.lowStockProducts.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final p = s.lowStockProducts[i];
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.warning_amber, color: Colors.red, size: 20)),
            title: Text(p['name'] ?? '', style: const TextStyle(fontSize: 14)),
            subtitle: Text(p['brand'] ?? ''),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${p['current_stock']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              Text('min: ${p['min_stock_level']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          const Icon(Icons.storefront, color: Colors.white, size: 48), const SizedBox(height: 8),
          Text('چوہدری ٹریڈرز', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          Text('Snack Distribution', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
        ]),
      ),
      _tile(context, Icons.dashboard, 'ڈیش بورڈ', () => Navigator.pop(context)),
      _tile(context, Icons.inventory_2, 'پروڈکٹس', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())); }),
      _tile(context, Icons.people, 'کسٹمرز', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())); }),
      _tile(context, Icons.point_of_sale, 'فروخت', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NewSaleScreen())); }),
      _tile(context, Icons.shopping_cart, 'خریداری', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseListScreen())); }),
      _tile(context, Icons.account_balance_wallet, 'وصولی', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionListScreen())); }),
      _tile(context, Icons.money_off, 'اخراجات', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen())); }),
      _tile(context, Icons.book, 'کیش بک', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CashBookScreen())); }),
      const Divider(),
      _tile(context, Icons.bar_chart, 'رپورٹس', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())); }),
      _tile(context, Icons.settings, 'سیٹنگز', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),
    ]));
  }

  ListTile _tile(BuildContext context, IconData icon, String title, VoidCallback onTap) =>
      ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
}
