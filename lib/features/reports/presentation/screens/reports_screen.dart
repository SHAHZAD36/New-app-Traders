import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/database_helper.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  Map<String, double> _stats = {};
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final db = await DatabaseHelper.instance.database;
    final s1 = await db.rawQuery("SELECT COALESCE(SUM(net_amount),0) as t FROM sales");
    final s2 = await db.rawQuery("SELECT COALESCE(SUM(amount),0) as t FROM collections");
    final s3 = await db.rawQuery("SELECT COALESCE(SUM(amount),0) as t FROM expenses");
    final s4 = await db.rawQuery("SELECT COALESCE(SUM(total_cost),0) as t FROM purchases");
    final s5 = await db.rawQuery("SELECT COALESCE(SUM(current_balance),0) as t FROM customers WHERE current_balance > 0");
    final s6 = await db.rawQuery("SELECT COUNT(*) as t FROM customers");
    final s7 = await db.rawQuery("SELECT COUNT(*) as t FROM products");
    setState(() {
      _stats = {
        'totalSales': (s1.first['t'] as num).toDouble(),
        'totalCollections': (s2.first['t'] as num).toDouble(),
        'totalExpenses': (s3.first['t'] as num).toDouble(),
        'totalPurchases': (s4.first['t'] as num).toDouble(),
        'totalReceivable': (s5.first['t'] as num).toDouble(),
        'customers': (s6.first['t'] as num).toDouble(),
        'products': (s7.first['t'] as num).toDouble(),
      };
      _loading = false;
    });
  }

  @override Widget build(BuildContext context) {
    final f = NumberFormat('#,##0');
    return Scaffold(
      appBar: AppBar(title: const Text('رپورٹس (Reports)'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _reportCard('کل فروخت', 'Rs. ${f.format(_stats['totalSales'])}', Icons.trending_up, Colors.blue),
              _reportCard('کل وصولی', 'Rs. ${f.format(_stats['totalCollections'])}', Icons.account_balance_wallet, Colors.green),
              _reportCard('واجب الادا', 'Rs. ${f.format(_stats['totalReceivable'])}', Icons.pending_actions, Colors.orange),
              _reportCard('کل خریداری', 'Rs. ${f.format(_stats['totalPurchases'])}', Icons.shopping_cart, Colors.purple),
              _reportCard('کل اخراجات', 'Rs. ${f.format(_stats['totalExpenses'])}', Icons.money_off, Colors.red),
              _reportCard('منافع (تخمینی)', 'Rs. ${f.format((_stats['totalSales']??0) - (_stats['totalPurchases']??0) - (_stats['totalExpenses']??0))}', Icons.bar_chart, Colors.teal),
              const Divider(height: 32),
              _reportCard('کل کسٹمرز', '${_stats['customers']?.toInt()}', Icons.people, Colors.indigo),
              _reportCard('کل پروڈکٹس', '${_stats['products']?.toInt()}', Icons.inventory_2, Colors.brown),
            ])),
    );
  }

  Widget _reportCard(String title, String value, IconData icon, Color color) {
    return Card(margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title), trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ));
  }
}
