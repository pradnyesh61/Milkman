import 'package:flutter/material.dart';

class CustomerDailyReportScreen extends StatelessWidget {
  final String customerName;
  final int month;
  final int year;

  const CustomerDailyReportScreen({
    super.key,
    required this.customerName,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$customerName – Report'),
      ),
      body: Column(
        children: [
          _header(),
          Expanded(child: _dailyList()),
          _summaryCard(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'February $year',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _dailyList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 10, // dummy days
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final milkGiven = index % 3 != 0;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
            milkGiven ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              milkGiven ? Icons.check : Icons.close,
              color: milkGiven ? Colors.green : Colors.red,
            ),
          ),
          title: Text('Day ${index + 1}'),
          subtitle: Text(
            milkGiven ? 'Cow • 2.0 L' : 'Milk not taken',
          ),
          trailing: Text(
            milkGiven ? '₹100' : '₹0',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _summaryCard() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _SummaryRow('Milk Given Days', '20'),
            _SummaryRow('Total Liters', '40.0 L'),
            Divider(),
            _SummaryRow(
              'Total Amount',
              '₹2000',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow(
      this.label,
      this.value, {
        this.bold = false,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
