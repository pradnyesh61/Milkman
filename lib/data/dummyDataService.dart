import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class dummyDataService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> insertMassDummyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final uid = user.uid;
    final db = FirebaseFirestore.instance;

    final customersRef =
    db.collection('users').doc(uid).collection('customers');

    final random = Random();

    // 🔹 20 Realistic Indian Names
    final List<Map<String, String>> names = [
      {'first': 'Ramesh', 'last': 'Patil'},
      {'first': 'Suresh', 'last': 'Kale'},
      {'first': 'Amit', 'last': 'Joshi'},
      {'first': 'Sunil', 'last': 'Shinde'},
      {'first': 'Vikas', 'last': 'Deshmukh'},
      {'first': 'Mahesh', 'last': 'Jadhav'},
      {'first': 'Anil', 'last': 'Pawar'},
      {'first': 'Rajesh', 'last': 'Kulkarni'},
      {'first': 'Santosh', 'last': 'Chavan'},
      {'first': 'Ganesh', 'last': 'More'},
      {'first': 'Prakash', 'last': 'Naik'},
      {'first': 'Deepak', 'last': 'Raut'},
      {'first': 'Manoj', 'last': 'Sawant'},
      {'first': 'Ajay', 'last': 'Bhosale'},
      {'first': 'Nitin', 'last': 'Shelar'},
      {'first': 'Rahul', 'last': 'Kadam'},
      {'first': 'Sachin', 'last': 'Gavande'},
      {'first': 'Vijay', 'last': 'Thorat'},
      {'first': 'Kiran', 'last': 'Lokhande'},
      {'first': 'Amol', 'last': 'Dighe'},
    ];

    // ⚠ Optional: Prevent duplicate dummy insert
    final existing = await customersRef.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print("⚠ Dummy data already exists for this user.");
      return;
    }

    List<String> customerIds = [];

    // 🔥 CREATE 20 CUSTOMERS
    for (int i = 0; i < names.length; i++) {
      final doc = await customersRef.add({
        'firstName': names[i]['first'],
        'lastName': names[i]['last'],
        'contactNumber': '98${random.nextInt(90000000) + 10000000}',
        'order': i,
        'createdAt': FieldValue.serverTimestamp(),
      });

      customerIds.add(doc.id);
    }

    final now = DateTime.now();

    // 🔥 LAST 3 MONTHS (Dynamic & Year Safe)
    final List<DateTime> months = [
      DateTime(now.year, now.month - 2),
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
    ];

    for (final monthDate in months) {
      final bool isCurrentMonth =
          monthDate.year == now.year && monthDate.month == now.month;

      final int daysInMonth = isCurrentMonth
          ? now.day
          : DateUtils.getDaysInMonth(monthDate.year, monthDate.month);

      for (final customerId in customerIds) {
        final milkType = random.nextBool() ? 'cow' : 'buffalo';
        final pricePerLiter = milkType == 'cow' ? 50 : 65;
        final baseLiters = random.nextInt(3) + 1;

        for (int day = 1; day <= daysInMonth; day++) {
          final date =
          DateTime(monthDate.year, monthDate.month, day);

          final milkGiven = random.nextInt(10) > 1; // 80% delivered

          final deliveryRef = customersRef
              .doc(customerId)
              .collection('deliveries')
              .doc('${date.year}-${date.month}-${date.day}');

          Map<String, dynamic> data = {
            'milkGiven': milkGiven,
            'date': Timestamp.fromDate(date),
            'day': date.day,
            'month': date.month,
            'year': date.year,
          };

          if (milkGiven) {
            final liters =
                baseLiters + (random.nextDouble() * 0.5);

            final totalPrice = liters * pricePerLiter;

            data.addAll({
              'milkType': milkType,
              'liters': double.parse(liters.toStringAsFixed(1)),
              'pricePerLiter': pricePerLiter,
              'totalPrice':
              double.parse(totalPrice.toStringAsFixed(1)),
            });
          }

          await deliveryRef.set(data);
        }
      }
    }

    print("🔥 20 customers with last 3 months realistic data inserted");
  }


}
