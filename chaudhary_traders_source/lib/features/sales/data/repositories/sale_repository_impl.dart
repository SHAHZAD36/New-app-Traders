import '../../../../core/utils/database_helper.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final DatabaseHelper dbHelper;

  SaleRepositoryImpl(this.dbHelper);

  @override
  Future<List<SaleModel>> getSales() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sales', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => SaleModel.fromMap(maps[i]));
  }

  @override
  Future<int> createSale(SaleModel sale, List<SaleItemModel> items) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      // 1. Insert Sale
      final saleId = await txn.insert('sales', sale.toMap());

      // 2. Insert Sale Items and Update Stock
      for (var item in items) {
        final itemMap = item.toMap();
        itemMap['sale_id'] = saleId;
        await txn.insert('sale_items', itemMap);

        // Update Stock
        await txn.execute(
          'UPDATE products SET current_stock = current_stock - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }

      // 3. Update Customer Balance if Credit Sale
      if (sale.paymentType == 'Credit') {
        await txn.execute(
          'UPDATE customers SET current_balance = current_balance + ? WHERE id = ?',
          [sale.netAmount, sale.customerId],
        );
      }

      return saleId;
    });
  }

  @override
  Future<List<SaleItemModel>> getSaleItems(int saleId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return List.generate(maps.length, (i) => SaleItemModel.fromMap(maps[i]));
  }
}
