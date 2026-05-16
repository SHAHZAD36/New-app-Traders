import 'package:flutter/material.dart';
import '../../../../features/products/presentation/screens/product_list_screen.dart';
import '../../../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../../../features/sales/presentation/screens/new_sale_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ڈیش بورڈ (Dashboard)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryGrid(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'حالیہ فروخت (Recent Sales)'),
            const SizedBox(height: 8),
            _buildRecentSalesList(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'کم اسٹاک الرٹس (Low Stock Alerts)'),
            const SizedBox(height: 8),
            _buildLowStockList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NewSaleScreen()));
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('نئی فروخت (New Sale)'),
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          context,
          'آج کی فروخت',
          'Rs. 0',
          Icons.trending_up,
          Colors.blue,
        ),
        _buildSummaryCard(
          context,
          'آج کی وصولی',
          'Rs. 0',
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildSummaryCard(
          context,
          'کل واجب الادا',
          'Rs. 0',
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildSummaryCard(
          context,
          'اسٹاک کی مالیت',
          'Rs. 0',
          Icons.inventory_2,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildRecentSalesList(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('حالیہ کوئی فروخت نہیں')),
      ),
    );
  }

  Widget _buildLowStockList(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('کم اسٹاک کی کوئی الرٹ نہیں')),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'چوہدری ٹریڈرز',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'شاہ جیونہ، جھنگ',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.dashboard, 'ڈیش بورڈ', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, Icons.inventory, 'پروڈکٹس (Products)', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen()));
          }),
          _buildDrawerItem(context, Icons.people, 'کسٹمرز (Customers)', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerListScreen()));
          }),
          _buildDrawerItem(context, Icons.shopping_cart, 'فروخت (Sales)', () {
             Navigator.pop(context);
             Navigator.push(context, MaterialPageRoute(builder: (context) => const NewSaleScreen()));
          }),
          _buildDrawerItem(context, Icons.payments, 'وصولی (Collections)', () {}),
          _buildDrawerItem(context, Icons.add_business, 'خریداری (Purchases)', () {}),
          _buildDrawerItem(context, Icons.money_off, 'اخراجات (Expenses)', () {}),
          _buildDrawerItem(context, Icons.book, 'کیش بک (Cash Book)', () {}),
          _buildDrawerItem(context, Icons.bar_chart, 'رپورٹس (Reports)', () {}),
          const Divider(),
          _buildDrawerItem(context, Icons.settings, 'سیٹنگز (Settings)', () {}),
          _buildDrawerItem(context, Icons.backup, 'بیک اپ (Backup)', () {}),
          _buildDrawerItem(context, Icons.logout, 'لاگ آؤٹ', () {
            Navigator.of(context).pushReplacementNamed('/');
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
