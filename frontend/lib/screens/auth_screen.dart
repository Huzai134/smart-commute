import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // NEW: State to toggle between Login and Sign Up
  bool _isLoginMode = true; 
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _submitForm() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) return;
    if (!_isLoginMode && _nameController.text.isEmpty) return; // Name is required for signup
    
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_isLoginMode) {
      // HANDLE LOGIN
      bool success = await authProvider.login(_phoneController.text, _passwordController.text);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Phone or Password."), backgroundColor: Colors.red));
        }
      }
    } else {
      // HANDLE SIGN UP
      String result = await authProvider.register(_nameController.text, _phoneController.text, _passwordController.text);
      if (mounted) {
        setState(() => _isLoading = false);
        if (result == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created!"), backgroundColor: Colors.green));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 100, color: Color(0xFFFFD700)),
              const SizedBox(height: 20),
              const Text("Smart Commute", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Text(_isLoginMode ? "Welcome Back." : "Create Your Secure Account.", style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 40),

              // ONLY SHOW 'FULL NAME' IF WE ARE SIGNING UP
              if (!_isLoginMode) ...[
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Full Name (Matches ID Card)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFFFD700)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFD700)), borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Phone Number (e.g. 0300...)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFFFFD700)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFD700)), borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFFFD700)),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFD700)), borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          _isLoginMode ? "SECURE LOGIN" : "CREATE ACCOUNT", 
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // THE TOGGLE BUTTON
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                    // Clear fields when switching modes
                    _nameController.clear();
                    _phoneController.clear();
                    _passwordController.clear();
                  });
                },
                child: Text(
                  _isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login",
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}