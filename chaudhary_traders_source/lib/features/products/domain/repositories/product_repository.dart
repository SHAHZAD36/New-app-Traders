import '../../data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(int id);
  Future<int> addProduct(ProductModel product);
  Future<int> updateProduct(ProductModel product);
  Future<int> deleteProduct(int id);
  Future<int> updateStock(int id, double quantity);
}
