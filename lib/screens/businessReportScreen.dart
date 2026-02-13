import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class businessReportScreen extends StatefulWidget {
  const businessReportScreen({super.key});

  @override
  State<businessReportScreen> createState() => _businessReportScreenState();
}

class _businessReportScreenState extends State<businessReportScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = const [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  bool reportGenerated = false;
  bool isLoading = false;

  List<Map<String, dynamic>> customerReport = [];
  double totalMilk = 0;
  double totalAmount = 0;
  int totalCustomers = 0;
  int milkGivenDays = 0;
  int milkMissedDays = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Business Report'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Card
            _buildFilterCard(),

            const SizedBox(height: 20),

            // Summary Cards
            if (reportGenerated) ...[
              _buildSummaryCards(),
              const SizedBox(height: 20),

              // Customer List
              _buildCustomerList(),
            ],
          ],
        ),
      ),
    );
  }

  // ================= FILTER CARD =================
  Widget _buildFilterCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Month & Year",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _monthDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _yearDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: isLoading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.analytics_outlined),
                label: Text(isLoading ? 'Generating...' : 'Generate Report'),
                onPressed: isLoading ? null : _generateReport,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARDS =================
  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Report – ${months[selectedMonth - 1]} $selectedYear",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _summaryCard("Total Customers", totalCustomers.toString(), Icons.people, Colors.purple),
            _summaryCard("Milk Given Days", milkGivenDays.toString(), Icons.water_drop, Colors.blue),
            _summaryCard("Milk Missed Days", milkMissedDays.toString(), Icons.cancel, Colors.red),
            _summaryCard("Total Milk", "${totalMilk.toStringAsFixed(0)} L", Icons.local_drink, Colors.teal),
            _summaryCard("Total Revenue", "₹${totalAmount.toStringAsFixed(0)}", Icons.currency_rupee, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 60) / 2, // two cards per row
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CUSTOMER LIST =================
  Widget _buildCustomerList() {
    if (customerReport.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text("No data available.")),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Customer Breakdown", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: customerReport.length,
          itemBuilder: (context, index) {
            final c = customerReport[index];
            return _customerCard(c);
          },
        ),
      ],
    );
  }

  Widget _customerCard(Map<String, dynamic> c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip("Given", c['given'].toString(), Colors.green),
                _infoChip("Missed", c['missed'].toString(), Colors.red),
                _infoChip("Liters", (c['liters'] as num).toDouble().toStringAsFixed(0), Colors.blue),
                _infoChip("Amount", "₹${(c['amount'] as num).toDouble().toStringAsFixed(0)}", Colors.orange),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // ================= DROPDOWNS =================
  Widget _monthDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedMonth,
      decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
      items: List.generate(
        months.length,
            (i) => DropdownMenuItem(value: i + 1, child: Text(months[i])),
      ),
      onChanged: (v) => setState(() => selectedMonth = v!),
    );
  }

  Widget _yearDropdown() {
    final currentYear = DateTime.now().year;
    return DropdownButtonFormField<int>(
      value: selectedYear,
      decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
      items: List.generate(5, (i) => DropdownMenuItem(value: currentYear - i, child: Text("${currentYear - i}"))),
      onChanged: (v) => setState(() => selectedYear = v!),
    );
  }

  // ================= FIREBASE LOGIC =================
  Future<void> _generateReport() async {
    setState(() {
      isLoading = true;
      reportGenerated = false;
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final customersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('customers')
          .get();

      List<Map<String, dynamic>> tempReport = [];
      double milkSum = 0;
      double amountSum = 0;
      int totalGivenDays = 0;
      int totalMissedDays = 0;

      final futures = customersSnapshot.docs.map((customer) async {
        final deliveriesSnapshot = await customer.reference
            .collection('deliveries')
            .where('month', isEqualTo: selectedMonth)
            .where('year', isEqualTo: selectedYear)
            .get();

        if (deliveriesSnapshot.docs.isEmpty) return null;

        int given = 0;
        int missed = 0;
        double liters = 0;
        double amount = 0;

        for (var delivery in deliveriesSnapshot.docs) {
          final data = delivery.data();
          if (data['milkGiven'] == true) {
            given++;
            liters += (data['liters'] as num?)?.toDouble() ?? 0.0;
            amount += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
          } else {
            missed++;
          }
        }

        totalGivenDays += given;
        totalMissedDays += missed;

        return {
          'name': "${customer['firstName']} ${customer['lastName']}",
          'given': given,
          'missed': missed,
          'liters': liters,
          'amount': amount,
        };
      }).toList();

      final results = await Future.wait(futures);

      for (var r in results) {
        if (r == null) continue;
        milkSum += (r['liters'] as double);
        amountSum += (r['amount'] as double);
        tempReport.add(r);
      }

      setState(() {
        customerReport = tempReport;
        totalMilk = milkSum;
        totalAmount = amountSum;
        totalCustomers = tempReport.length;
        milkGivenDays = totalGivenDays;
        milkMissedDays = totalMissedDays;
        reportGenerated = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

//
// If you want to level it up even more later, we can add:
//
// 📊 Export to PDF
//
// 📤 Share report (WhatsApp)
//
// 📁 Download monthly CSV
//
// 📅 Yearly summary report
//
// ⚡ Firestore index optimization
//
// 💰 Profit calculation (if you add buy price vs sell price)
