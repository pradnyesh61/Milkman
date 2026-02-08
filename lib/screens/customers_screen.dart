import 'package:flutter/material.dart';
import '../data/CustomerStore.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
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
                setState(() {
                  CustomerStore.addCustomer(newCustomer);
                });
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
        onReorder: (oldIndex, newIndex) {
          setState(() {
            CustomerStore.reorderCustomers(oldIndex, newIndex);
          });
        },
        itemBuilder: (context, index) {
          final customer = customers[index];

          return Card(
            key: ValueKey(customer.contactNumber),
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.drag_handle),
              title: Text(
                '${customer.firstName} ${customer.lastName}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              subtitle: Text(customer.contactNumber),
            ),
          );
        },
      ),
    );
  }
}
