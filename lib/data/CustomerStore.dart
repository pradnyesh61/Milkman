import '../models/customer.dart';

class CustomerStore {
  static final List<Customer> _customers = [];

  static List<Customer> getCustomers() {
    return List.unmodifiable(_customers);
  }

  static void addCustomer(Customer customer) {
    _customers.add(customer);
  }

  static void reorderCustomers(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _customers.removeAt(oldIndex);
    _customers.insert(newIndex, item);
  }

  static void clear() {
    _customers.clear();
  }
}
