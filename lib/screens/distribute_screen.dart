import 'package:flutter/material.dart';
import '../data/CustomerStore.dart';

class DistributeScreen extends StatefulWidget {
  @override
  State<DistributeScreen> createState() => _DistributeScreenState();
}

class _DistributeScreenState extends State<DistributeScreen> {
  int currentIndex = 0;
  int deliveredCount = 0;

  String selectedMilkType = 'cow'; // cow | buffalo
  double selectedLiters = 0;

  final double cowPrice = 50;
  final double buffaloPrice = 60;

  final TextEditingController customLiterController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    final customers = CustomerStore.getCustomers();

    if (customers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Distribute Milk')),
        body: Center(child: Text('No customers available')),
      );
    }

    final customer = customers[currentIndex];

    final double pricePerLiter =
    selectedMilkType == 'cow' ? cowPrice : buffaloPrice;
    final double totalPrice = selectedLiters * pricePerLiter;

    return Scaffold(
      appBar: AppBar(title: Text('Distribute Milk')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// CUSTOMER CARD
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    '${customer.firstName} ${customer.lastName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(customer.contactNumber),
                ),
              ),

              SizedBox(height: 24),

              /// MILK TYPE BUTTONS
              Row(
                children: [
                  Expanded(child: _milkTypeButton('Cow Milk ₹50/L', 'cow')),
                  SizedBox(width: 12),
                  Expanded(child: _milkTypeButton('Buffalo Milk ₹60/L', 'buffalo')),
                ],
              ),

              SizedBox(height: 20),

              /// QUICK LITER BUTTONS
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [0.5, 1, 1.5, 2, 2.5, 3, 4, 5]
                    .map((l) => _literButton(l.toDouble()))
                    .toList(),
              ),

              SizedBox(height: 16),

              /// CUSTOM LITER (>5)
              TextField(
                controller: customLiterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Custom liters (more than 5)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() {
                    selectedLiters = double.tryParse(v) ?? 0;
                  });
                },
              ),

              SizedBox(height: 20),

              /// SUMMARY
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _summaryRow('Total Milk', '${selectedLiters} L'),
                      SizedBox(height: 8),
                      _summaryRow('Total Price', '₹ ${totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30), // Gap before buttons

              /// ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skipCustomer,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text('Skip'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAndNext,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Save & Next'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  /// MILK TYPE BUTTON
  Widget _milkTypeButton(String label, String type) {
    final bool isSelected = selectedMilkType == type;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        setState(() {
          selectedMilkType = type;
        });
      },
      child: Text(label),
    );
  }

  /// LITER BUTTON
  Widget _literButton(double liter) {
    final bool isSelected = selectedLiters == liter;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        setState(() {
          selectedLiters = liter;
          customLiterController.clear();
        });
      },
      child: Text('$liter L'),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }

  /// SAVE
  void _saveAndNext() {
    if (selectedLiters > 0) {
      deliveredCount++;
    }
    _goNext();
  }

  /// SKIP
  void _skipCustomer() {
    _goNext();
  }

  /// NAVIGATION
  void _goNext() {
    selectedLiters = 0;
    customLiterController.clear();

    if (currentIndex < CustomerStore.getCustomers().length - 1) {
      setState(() => currentIndex++);
    } else {
      _onDistributionComplete();
    }
  }

  /// FINAL POPUP
  void _onDistributionComplete() {
    final bool anyDelivered = deliveredCount > 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              anyDelivered ? Icons.check_circle : Icons.info,
              color: anyDelivered ? Colors.green : Colors.orange,
              size: 60,
            ),
            SizedBox(height: 12),
            Text(
              anyDelivered ? 'All Done!' : 'No Delivery Today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              anyDelivered
                  ? 'Milk distribution completed successfully 🥛'
                  : 'No milk was delivered to any customer today.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }
}
