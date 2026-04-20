import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // NEW: Controllers to grab the text from the input fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _idController.dispose();
    super.dispose();
  }

  // NEW: Validation Logic
  void _handleLogin() {
    if (_phoneController.text.trim().isEmpty || _idController.text.trim().isEmpty) {
      // Block the user and show an error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Access Denied: Please enter your Phone Number and ID."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop the function here
    }

    // If everything is filled out, let them in!
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const DashboardScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome to", style: TextStyle(color: Colors.grey, fontSize: 18)),
            const Text("Smart Commute", style: TextStyle(color: Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            TextField(
              controller: _phoneController, // Connected controller
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFFFFD700)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFD700)), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _idController, // Connected controller
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Student / Employee ID",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.badge, color: Color(0xFFFFD700)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFD700)), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleLogin, // Connected to our new security check
                child: const Text("SECURE LOGIN", style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}