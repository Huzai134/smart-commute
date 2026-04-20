import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/places_service.dart';
import 'active_carpools_screen.dart';
import 'profile_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _startLocation = "";
  String _endLocation = "";
  bool _isLoading = false;
  
  // Store the selected engine size (Default 1000cc)
  int _selectedCC = 1000;

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2), borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
    );
  }

  Widget _buildSmartField(String label, IconData icon, Function(String) onSelected) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return await PlacesService.getSuggestions(textEditingValue.text);
      },
      onSelected: (String selection) => onSelected(selection),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: _buildInputDecoration(label, icon),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: const Color(0xFF1E1E1E),
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    title: Text(option, style: const TextStyle(color: Colors.white)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Commute'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFFFFD700), size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.directions_car, size: 80, color: Color(0xFFFFD700)),
              const SizedBox(height: 30),
              
              _buildSmartField("Where are you starting?", Icons.my_location, (val) => setState(() => _startLocation = val)),
              const SizedBox(height: 20),
              
              _buildSmartField("Where are you going?", Icons.location_on, (val) => setState(() => _endLocation = val)),
              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                initialValue: _selectedCC,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _buildInputDecoration("Vehicle Engine Capacity", Icons.settings_applications),
                items: const [
                  DropdownMenuItem(value: 800, child: Text("800cc (e.g., Mehran, Alto)")),
                  DropdownMenuItem(value: 1000, child: Text("1000cc (e.g., Cultus, Vitz)")),
                  DropdownMenuItem(value: 1300, child: Text("1300cc (e.g., City, Yaris)")),
                  DropdownMenuItem(value: 1800, child: Text("1800cc+ (e.g., Civic, Corolla)")),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedCC = newValue);
                  }
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_startLocation.isEmpty || _endLocation.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select valid locations"), backgroundColor: Colors.orange));
                      return;
                    }

                    setState(() => _isLoading = true);
                    
                    // FIXED: Removed the hardcoded 15.0 distance argument
                    bool success = await ApiService.activateRoute("test_user_001", _startLocation, _endLocation, _selectedCC);
                    
                    setState(() => _isLoading = false);

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Route Activated with AI Pricing!"), backgroundColor: Colors.green));
                    }
                  },
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text('ACTIVATE DAILY ROUTE', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveCarpoolsScreen())),
                child: const Text('VIEW ACTIVE CARPOOLS', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}