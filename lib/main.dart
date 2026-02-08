import 'package:flutter/material.dart';
import 'app_theme/AppColors.dart';
import 'screens/login_screen.dart';
import 'app_theme/AppColors.dart';
import 'screens/login_screen.dart';
// Add these imports for Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <- This must be generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MilkmanApp());
}

class MilkmanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Milkman',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBg,

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blue.shade900,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
          iconTheme: IconThemeData(
            color: Colors.blue.shade900,
          ),
        ),

        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),

        cardTheme: CardThemeData(
          color: AppColors.cardBg,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,   // button color
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
