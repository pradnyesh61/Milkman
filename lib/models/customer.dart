class Customer {
  final String id; // Firestore doc id
  final String firstName;
  final String lastName;
  final String contactNumber;
  final int order;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.contactNumber,
    required this.order,
  });

  factory Customer.fromFirestore(String id, Map<String, dynamic> json) {
    return Customer(
      id: id,
      firstName: json['firstName'],
      lastName: json['lastName'],
      contactNumber: json['contactNumber'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'contactNumber': contactNumber,
      'order': order,
    };
  }
}
