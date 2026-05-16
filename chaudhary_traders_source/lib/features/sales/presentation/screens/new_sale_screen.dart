import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sale_provider.dart';
import '../models/sale_model.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../products/data/models/product_model.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  CustomerModel? selectedCustomer;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0;
  double discount = 0;
  String paymentType = 'Cash';

  void _calculateTotal() {
    totalAmount = cartItems.fold(0, (sum, item) => sum + (item['total'] as double));
    setState(() {});
  }

  void _addItem(ProductModel product, double quantity) {
    final existingIndex = cartItems.indexWhere((item) => item['product_id'] == product.id);
    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity'] += quantity;
      cartItems[existingIndex]['total'] = cartItems[existingIndex]['quantity'] * product.salePrice;
    } else {
      cartItems.add({
        'product_id': product.id,
        'name': product.name,
        'quantity': quantity,
        'rate': product.salePrice,
        'total': quantity * product.salePrice,
      });
    }
    _calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('نئی فروخت (New Sale)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Customer Selection
            DropdownButtonFormField<CustomerModel>(
              decoration: const InputDecoration(labelText: 'کسٹمر منتخب کریں'),
              value: selectedCustomer,
              items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.shopName))).toList(),
              onChanged: (val) => setState(() => selectedCustomer = val),
            ),
            const SizedBox(height: 16),
            // Product Selection
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<ProductModel>(
                    decoration: const InputDecoration(labelText: 'پروڈکٹ'),
                    items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                    onChanged: (p) {
                      if (p != null) _addItem(p, 1);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('${item['quantity']} x ${item['rate']}'),
                    trailing: Text('Rs. ${item['total']}'),
                    onLongPress: () {
                      setState(() => cartItems.removeAt(index));
                      _calculateTotal();
                    },
                  );
                },
              ),
            ),
            const Divider(),
            _buildSummary(),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: selectedCustomer == null || cartItems.isEmpty ? null : _saveSale,
              child: const Text('فروخت محفوظ کریں (Save Sale)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('کل رقم:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Rs. $totalAmount'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ادائیگی کی قسم:'),
            DropdownButton<String>(
              value: paymentType,
              items: ['Cash', 'Credit'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => paymentType = val!),
            ),
          ],
        ),
      ],
    );
  }

  void _saveSale() {
    final sale = SaleModel(
      customerId: selectedCustomer!.id!,
      date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      totalAmount: totalAmount,
      discount: discount,
      netAmount: totalAmount - discount,
      paymentType: paymentType,
    );

    final items = cartItems.map((item) => SaleItemModel(
      saleId: 0, // Will be set in repository
      productId: item['product_id'],
      quantity: item['quantity'],
      rate: item['rate'],
      total: item['total'],
    )).toList();

    ref.read(salesProvider.notifier).createSale(sale, items);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فروخت محفوظ کر لی گئی ہے')));
  }
}
