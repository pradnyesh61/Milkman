import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CustomerDailyReportScreen.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  String? selectedCustomerId;
  String? selectedCustomerName;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = const [
    'January','February','March','April',
    'May','June','July','August',
    'September','October','November','December',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 FIRESTORE CUSTOMER DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('customers')
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedCustomerId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Choose customer',
                  ),
                  items: docs.map((doc) {
                    final first = doc['firstName'];
                    final last = doc['lastName'];

                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text('$first $last'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final doc = docs.firstWhere((d) => d.id == value);
                    setState(() {
                      selectedCustomerId = value;
                      selectedCustomerName =
                      "${doc['firstName']} ${doc['lastName']}";
                    });
                  },
                );
              },
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
                onPressed: selectedCustomerId == null
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerDailyReportScreen(
                        customerId: selectedCustomerId!,
                        customerName: selectedCustomerName!,
                        month: selectedMonth,
                        year: selectedYear,
                      ),
                    ),
                  );
                },
              ),
            ),
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
}
