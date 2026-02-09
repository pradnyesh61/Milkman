import 'package:flutter/material.dart';
import '../data/CustomerStore.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await CustomerStore.loadCustomers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final customers = CustomerStore.getCustomers();

    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newCustomer = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddCustomerScreen()),
              );

              if (newCustomer != null) {
                await CustomerStore.addCustomer(newCustomer);
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: customers.isEmpty
          ? Center(child: Text('No customers added yet'))
          : ReorderableListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: customers.length,
        onReorder: (oldIndex, newIndex) async {
          await CustomerStore.reorderCustomers(oldIndex, newIndex);
          setState(() {});
        },
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            key: ValueKey(customer.id),
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.drag_handle),
              title: Text('${customer.firstName} ${customer.lastName}'),
              subtitle: Text(customer.contactNumber),
            ),
          );
        },
      ),
    );
  }
}
