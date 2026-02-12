import 'package:flutter/material.dart';

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

  List<Map<String, dynamic>> customerReport = [];
  double totalMilk = 0;
  double totalAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Month & Year',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

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
                icon: const Icon(Icons.analytics),
                label: const Text('Generate Report'),
                onPressed: _generateDummyReport,
              ),
            ),

            const SizedBox(height: 16),

            if (reportGenerated)
              Text(
                'Business Report – ${months[selectedMonth - 1]} $selectedYear',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 12),

            if (reportGenerated) _reportTable(),
          ],
        ),
      ),
    );
  }

  // ================= TABLE =================

  Widget _reportTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),

          SizedBox(
            height: 260,
            child: ListView.builder(
              itemCount: customerReport.length,
              itemBuilder: (context, index) {
                final c = customerReport[index];
                return _tableRow(
                  c['name'],
                  c['given'],
                  c['missed'],
                  c['liters'],
                  c['amount'],
                );
              },
            ),
          ),

          const Divider(height: 1),
          _totalRow(),
        ],
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _tableHeader() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: const Row(
        children: [
          _HeaderCell(lines: ['Customer', 'Name'], flex: 3, align: TextAlign.left),
          _HeaderCell(lines: ['Delivery', 'Days'], flex: 2),
          _HeaderCell(lines: ['Missed', 'Days'], flex: 2),
          _HeaderCell(lines: ['Milk', '(Liters)'], flex: 2),
          _HeaderCell(lines: ['Total', 'Amount'], flex: 2, align: TextAlign.right),
        ],
      ),
    );
  }

  // ---------- ROW ----------
  Widget _tableRow(
      String name,
      int given,
      int missed,
      double liters,
      int amount,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          _NameCell(fullName: name, flex: 3),
          _flexCell(given.toString(), flex: 2),
          _flexCell(missed.toString(), flex: 2),
          _flexCell(liters.toStringAsFixed(0), flex: 2),
          _flexCell('₹$amount', flex: 2, align: TextAlign.right),
        ],
      ),
    );
  }

  // ---------- TOTAL ----------
  Widget _totalRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.blueGrey.shade50,
      child: Row(
        children: [
          _flexCell('TOTAL', flex: 3, align: TextAlign.left, bold: true),
          _flexCell('', flex: 2),
          _flexCell('', flex: 2),
          _flexCell(totalMilk.toStringAsFixed(0), flex: 2, bold: true),
          _flexCell(
            '₹${totalAmount.toStringAsFixed(0)}',
            flex: 2,
            align: TextAlign.right,
            bold: true,
          ),
        ],
      ),
    );
  }

  // ================= DROPDOWNS =================

  Widget _monthDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedMonth,
      decoration: const InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(),
      ),
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
      decoration: const InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(),
      ),
      items: List.generate(
        5,
            (i) {
          final year = currentYear - i;
          return DropdownMenuItem(value: year, child: Text(year.toString()));
        },
      ),
      onChanged: (v) => setState(() => selectedYear = v!),
    );
  }

  // ================= DATA =================

  void _generateDummyReport() {
    customerReport = [
      {
        'name': 'Ramesh Patil',
        'given': 24,
        'missed': 7,
        'liters': 410.0,
        'amount': 20500,
      },
      {
        'name': 'Suresh Kale',
        'given': 22,
        'missed': 9,
        'liters': 360.0,
        'amount': 18000,
      },
      {
        'name': 'Amit Joshi',
        'given': 26,
        'missed': 5,
        'liters': 510.0,
        'amount': 25700,
      },
    ];

    totalMilk = customerReport.fold(0, (s, e) => s + e['liters']);
    totalAmount = customerReport.fold(0, (s, e) => s + e['amount']);

    setState(() => reportGenerated = true);
  }
}

// ================= REUSABLE =================

class _HeaderCell extends StatelessWidget {
  final List<String> lines;
  final int flex;
  final TextAlign align;

  const _HeaderCell({
    required this.lines,
    required this.flex,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment:
        align == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: lines
            .map((l) => Text(
          l,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: align,
        ))
            .toList(),
      ),
    );
  }
}

class _NameCell extends StatelessWidget {
  final String fullName;
  final int flex;

  const _NameCell({
    required this.fullName,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    final parts = fullName.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (lastName.isNotEmpty)
            Text(
              lastName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500, // ✅ SAME STYLE
              ),
            ),
        ],
      ),
    );
  }
}

Widget _flexCell(
    String text, {
      required int flex,
      TextAlign align = TextAlign.center,
      bool bold = false,
    }) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: align,
      style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    ),
  );
}
