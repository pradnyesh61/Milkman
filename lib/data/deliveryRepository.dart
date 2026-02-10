import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer.dart';

class DeliveryRepository {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> saveDelivery({
    required Customer customer,
    required bool milkGiven,
    String? milkType,
    double? liters,
    double? pricePerLiter,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final now = DateTime.now();

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('customers')
        .doc(customer.id)
        .collection('deliveries')
        .doc('${now.year}-${now.month}-${now.day}');

    final Map<String, dynamic> data = {
      'milkGiven': milkGiven,
      'date': Timestamp.fromDate(now),
      'day': now.day,
      'month': now.month,
      'year': now.year,
    };

    if (milkGiven) {
      final totalPrice = liters! * pricePerLiter!;
      data.addAll({
        'milkType': milkType,
        'liters': liters,
        'pricePerLiter': pricePerLiter,
        'totalPrice': totalPrice,
      });
    }

    await docRef.set(data);
  }
}
