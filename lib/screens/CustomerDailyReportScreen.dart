import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerDailyReportScreen extends StatelessWidget {
  final String customerId;
  final String customerName;
  final int month;
  final int year;

  const CustomerDailyReportScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final deliveriesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('customers')
        .doc(customerId)
        .collection('deliveries')
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .orderBy('day')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('$customerName – Report'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: deliveriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No data available for this month"),
            );
          }

          final docs = snapshot.data!.docs;

          int givenDays = 0;
          double totalLiters = 0;
          double totalAmount = 0;

          for (var d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final milkGiven = data['milkGiven'] == true;

            if (milkGiven) {
              givenDays++;
              totalLiters +=
                  (data['liters'] as num?)?.toDouble() ?? 0.0;
              totalAmount +=
                  (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
            }
          }

          return Column(
            children: [
              _header(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                    docs[index].data() as Map<String, dynamic>;

                    final milkGiven =
                        data['milkGiven'] == true;

                    final day = data['day'] as int;
                    final date =
                    DateTime(year, month, day);

                    final weekday =
                    _weekdayName(date.weekday);

                    final liters =
                        (data['liters'] as num?)
                            ?.toDouble() ??
                            0.0;

                    final price =
                        (data['totalPrice'] as num?)
                            ?.toDouble() ??
                            0.0;

                    return _dailyCard(
                      day: day,
                      weekday: weekday,
                      milkGiven: milkGiven,
                      milkType: data['milkType'] ?? '',
                      liters: liters,
                      price: price,
                    );
                  },
                ),
              ),
              _summaryCard(
                givenDays: givenDays,
                totalLiters: totalLiters,
                totalAmount: totalAmount,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_monthName(month)} $year',
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

  Widget _dailyCard({
    required int day,
    required String weekday,
    required bool milkGiven,
    required String milkType,
    required double liters,
    required double price,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [

            // LEFT DATE COLUMN
            Column(
              children: [
                Text(
                  day.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weekday,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // CENTER DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    milkGiven
                        ? '$milkType • ${liters.toStringAsFixed(1)} L'
                        : 'Milk not taken',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milkGiven
                        ? 'Delivered'
                        : 'Skipped',
                    style: TextStyle(
                      color: milkGiven
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT AMOUNT
            Text(
              milkGiven
                  ? '₹${price.toStringAsFixed(0)}'
                  : '₹0',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required int givenDays,
    required double totalLiters,
    required double totalAmount,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
                'Milk Given Days', givenDays.toString()),
            _SummaryRow(
                'Total Liters',
                '${totalLiters.toStringAsFixed(1)} L'),
            const Divider(),
            _SummaryRow(
              'Total Amount',
              '₹${totalAmount.toStringAsFixed(0)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  String _weekdayName(int weekday) {
    const days = [
      '',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    return days[weekday];
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
      padding:
      const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight:
              bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
