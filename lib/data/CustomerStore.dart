import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer.dart';

class CustomerStore {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static List<Customer> _customers = [];

  /// 🔐 Current user's customers collection
  static CollectionReference<Map<String, dynamic>> _collection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return _db
        .collection('users')
        .doc(uid)
        .collection('customers');
  }

  /// ✅ LOAD customers (CLEAR FIRST — fixes ghost data bug)
  static Future<void> loadCustomers() async {
    _customers.clear(); // 🔥 VERY IMPORTANT

    final snapshot = await _collection()
        .orderBy('order')
        .get();

    _customers = snapshot.docs
        .map((d) => Customer.fromFirestore(d.id, d.data()))
        .toList();
  }

  static List<Customer> getCustomers() {
    return List.unmodifiable(_customers);
  }

  /// ➕ ADD customer
  static Future<void> addCustomer(Customer customer) async {
    final newOrder = _customers.length;

    final doc = await _collection().add({
      'firstName': customer.firstName,
      'lastName': customer.lastName,
      'contactNumber': customer.contactNumber,
      'order': newOrder,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _customers.add(
      Customer(
        id: doc.id,
        firstName: customer.firstName,
        lastName: customer.lastName,
        contactNumber: customer.contactNumber,
        order: newOrder,
      ),
    );
  }

  /// 🔁 REORDER customers
  static Future<void> reorderCustomers(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final moved = _customers.removeAt(oldIndex);
    _customers.insert(newIndex, moved);

    final batch = _db.batch();

    for (int i = 0; i < _customers.length; i++) {
      final c = _customers[i];

      batch.update(
        _collection().doc(c.id),
        {'order': i},
      );

      // ✅ recreate object (NO copyWith needed)
      _customers[i] = Customer(
        id: c.id,
        firstName: c.firstName,
        lastName: c.lastName,
        contactNumber: c.contactNumber,
        order: i,
      );
    }

    await batch.commit();
  }

  /// 🚪 CLEAR local cache (CALL ON LOGOUT)
  static void clear() {
    _customers.clear();
  }
}
