import '../../data/models/customer_model.dart';

abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers();
  Future<CustomerModel?> getCustomerById(int id);
  Future<int> addCustomer(CustomerModel customer);
  Future<int> updateCustomer(CustomerModel customer);
  Future<int> deleteCustomer(int id);
  Future<int> updateBalance(int id, double amount);
}
