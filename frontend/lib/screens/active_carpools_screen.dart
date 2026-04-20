import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'map_screen.dart'; // NEW: Import the Map Screen

class ActiveCarpoolsScreen extends StatefulWidget {
  const ActiveCarpoolsScreen({super.key});

  @override
  State<ActiveCarpoolsScreen> createState() => _ActiveCarpoolsScreenState();
}

class _ActiveCarpoolsScreenState extends State<ActiveCarpoolsScreen> {
  List _activeRoutes = [];
  bool _isLoading = true;
  bool _isAILoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/routes/active/'));
      if (response.statusCode == 200) {
        setState(() {
          _activeRoutes = json.decode(response.body)['active_carpools'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _askGemini() async {
    setState(() => _isAILoading = true);
    String? aiResponse = await ApiService.getAIMatch("test_user_001");
    setState(() => _isAILoading = false);

    if (mounted && aiResponse != null) {
      _showAIDialog(aiResponse);
    }
  }

  void _showAIDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0xFFFFD700), width: 1)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFFD700)),
            SizedBox(width: 10),
            Text("AI Dispatcher", style: TextStyle(color: Color(0xFFFFD700))),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("GOT IT", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Commute Radar')),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAILoading ? null : _askGemini,
        backgroundColor: const Color(0xFFFFD700),
        icon: _isAILoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Icon(Icons.auto_awesome, color: Colors.black),
        label: Text(
          _isAILoading ? "AI IS THINKING..." : "ASK AI MATCHMAKER", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
      ),

      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _activeRoutes.isEmpty 
              ? const Center(child: Text("No active carpools nearby.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                  itemCount: _activeRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _activeRoutes[index];
                    
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Color(0xFFFFD700), width: 0.5)
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          // --- NEW: Open the Map Screen when tapped ---
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MapScreen(routeData: route)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor: Color(0xFFFFD700),
                                child: Icon(Icons.directions_car, color: Colors.black),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(route['start_location'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text("to ${route['end_location']}", style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    
                                    // --- NEW: Dynamic Price Tag ---
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green, width: 1)
                                      ),
                                      child: Text(
                                        "Rs. ${route['suggested_price'] ?? 'TBD'} (Est.)", 
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chat, color: Color(0xFFFFD700)),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(peerId: route['user_id'])));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}