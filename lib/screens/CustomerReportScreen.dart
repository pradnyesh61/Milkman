import 'package:flutter/material.dart';
import '../data/CustomerStore.dart';
import '../models/customer.dart';
import 'CustomerDailyReportScreen.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  Customer? selectedCustomer;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = const [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final customers = CustomerStore.getCustomers();

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Customer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<Customer>(
              value: selectedCustomer,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose customer',
              ),
              items: customers.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text('${c.firstName} ${c.lastName}'),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedCustomer = v),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _monthDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _yearDropdown()),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text('Generate Report'),
                onPressed: selectedCustomer == null
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerDailyReportScreen(
                        customerName:
                        '${selectedCustomer!.firstName} ${selectedCustomer!.lastName}',
                        month: selectedMonth,
                        year: selectedYear,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            _previewCard(),
          ],
        ),
      ),
    );
  }

  Widget _monthDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedMonth,
      decoration: const InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(),
      ),
      items: List.generate(
        months.length,
            (i) => DropdownMenuItem(
          value: i + 1,
          child: Text(months[i]),
        ),
      ),
      onChanged: (v) => setState(() => selectedMonth = v!),
    );
  }

  Widget _yearDropdown() {
    final currentYear = DateTime.now().year;
    return DropdownButtonFormField<int>(
      value: selectedYear,
      decoration: const InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(),
      ),
      items: List.generate(
        5,
            (i) {
          final year = currentYear - i;
          return DropdownMenuItem(
            value: year,
            child: Text(year.toString()),
          );
        },
      ),
      onChanged: (v) => setState(() => selectedYear = v!),
    );
  }



  Widget _previewCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            _PreviewRow('Milk Given Days', '--'),
            _PreviewRow('Milk Not Given Days', '--'),
            _PreviewRow('Total Milk (L)', '--'),
            _PreviewRow('Total Amount (₹)', '--'),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String title;
  final String value;

  const _PreviewRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
