import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _fullName;
  String? _trustLevel;

  String? get userId => _userId;
  String? get fullName => _fullName;
  String? get trustLevel => _trustLevel;
  bool get isAuthenticated => _userId != null;

  final String _baseUrl = 'http://127.0.0.1:8000';

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    _fullName = prefs.getString('full_name');
    _trustLevel = prefs.getString('trust_level');
    notifyListeners();
  }

  // --- EXISTING LOGIN ROUTE ---
  Future<bool> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userId = data['user_id'];
        _fullName = data['full_name'];
        _trustLevel = data['trust_level'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _userId!);
        await prefs.setString('full_name', _fullName!);
        await prefs.setString('trust_level', _trustLevel!);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Login Error: $e");
      return false;
    }
  }

  // --- NEW: REGISTRATION ROUTE ---
  Future<String> register(String fullName, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'phone_number': phone, 
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Auto-login the user after successful registration
        _userId = data['user_id'];
        _fullName = data['full_name'];
        _trustLevel = "Unverified"; // New users start unverified!

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _userId!);
        await prefs.setString('full_name', _fullName!);
        await prefs.setString('trust_level', _trustLevel!);

        notifyListeners();
        return "success";
      } else if (response.statusCode == 400) {
        return "Phone number already exists.";
      }
      return "Server error.";
    } catch (e) {
      debugPrint("Register Error: $e");
      return "Connection failed.";
    }
  }

  Future<void> logout() async {
    _userId = null;
    _fullName = null;
    _trustLevel = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}