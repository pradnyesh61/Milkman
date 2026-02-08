import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != rePasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final phone = contactController.text.trim();
      final email = "$phone@milkmanapp.com";

      // 1️⃣ CREATE FIREBASE AUTH USER
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );

      final uid = userCredential.user!.uid;

      // 2️⃣ STORE USER PROFILE (NO PASSWORD)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'surname': surnameController.text.trim(),
        'contact': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile created successfully")),
      );

      Navigator.pop(context); // back to login
    } on FirebaseAuthException catch (e) {
      String msg = "Registration failed";

      if (e.code == 'email-already-in-use') {
        msg = "User already exists with this contact number";
      } else if (e.code == 'weak-password') {
        msg = "Password is too weak";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "First Name"),
                  validator: (v) => v!.isEmpty ? "Enter first name" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: surnameController,
                  decoration: const InputDecoration(labelText: "Surname"),
                  validator: (v) => v!.isEmpty ? "Enter surname" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: contactController,
                  decoration:
                  const InputDecoration(labelText: "Contact Number"),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                  v!.length < 10 ? "Enter valid contact number" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: rePasswordController,
                  decoration:
                  const InputDecoration(labelText: "Re-enter Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
