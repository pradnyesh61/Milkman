import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/CustomerStore.dart';
import 'distribute_screen.dart';
import 'customers_screen.dart';
import 'ReportsHomeScreen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../data/dummyDataService.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout(BuildContext context) async {
    // 🔥 SIGN OUT FROM FIREBASE
    await FirebaseAuth.instance.signOut();

    // 🔥 REMOVE ALL PREVIOUS SCREENS
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Milkman')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.fromLTRB(
                18,
                MediaQuery.of(context).padding.top + 16,
                16,
                20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 34,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pradnyesh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Milk Provider',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _drawerItem(
              context,
              Icons.local_drink,
              'Distribute Milk',
              DistributeScreen(),
            ),
            _drawerItem(context, Icons.people, 'Customers', CustomersScreen()),
            _drawerItem(context, Icons.bar_chart, 'Reports', ReportsHomeScreen()),
            _drawerItem(context, Icons.settings, 'Settings', SettingsScreen()),

            Divider(),

            // ✅ FIXED LOGOUT
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () async {
                // 🔥 CLEAR CUSTOMER CACHE
                CustomerStore.clear();

                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),

              Text(
                'Good Morning 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),

              SizedBox(height: 6),

              Text(
                'Pradnyesh',
                style: TextStyle(fontSize: 20, color: Colors.blueGrey),
              ),

              SizedBox(height: 20),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping, size: 36, color: Colors.blue),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Ready for today’s milk delivery?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.menu, color: Colors.green),
                  title: Text('Use the menu to get started'),
                  subtitle: Text('Distribute milk, manage customers & reports'),
                ),
              ),

              // SizedBox(height: 20),
              //
              // ElevatedButton(
              //   onPressed: () async {
              //     await dummyDataService.insertMassDummyData();
              //
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text("Dummy data inserted successfully"),
              //       ),
              //     );
              //   },
              //   child: const Text("Insert Dummy Data"),
              // ),


              Spacer(),

              Center(
                child: Text(
                  'Have a great day 🌞',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
