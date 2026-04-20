import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'chat_screen.dart';
import 'live_ride_screen.dart'; 

class MapScreen extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const MapScreen({super.key, required this.routeData});

  @override
  Widget build(BuildContext context) {
    final LatLng startLocation = const LatLng(33.5973, 73.0481); 
    final LatLng endLocation = const LatLng(33.6425, 73.0298);   

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Overview'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(33.6200, 73.0400), 
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smart_commute',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: startLocation,
                    width: 50,
                    height: 50,
                    child: const Column(
                      children: [Icon(Icons.location_on, color: Colors.green, size: 40)],
                    ),
                  ),
                  Marker(
                    point: endLocation,
                    width: 50,
                    height: 50,
                    child: const Column(
                      children: [Icon(Icons.flag, color: Colors.red, size: 40)],
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [startLocation, endLocation],
                    strokeWidth: 4.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
                border: Border.all(color: const Color(0xFFFFD700), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Estimated Fuel Share", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        // FIXED: Replaced withOpacity with withAlpha to clear the deprecation warning
                        decoration: BoxDecoration(color: const Color(0xFFFFD700).withAlpha(51), borderRadius: BorderRadius.circular(20)),
                        child: Text("Rs. ${routeData['suggested_price'] ?? 'TBD'}", style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 20),
                  Row(
                    children: [
                      const Icon(Icons.directions_car, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text("Vehicle: ${routeData['engine_cc'] ?? '1000'}cc", style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => LiveRideScreen(engineCC: routeData['engine_cc'] ?? 1000))
                        );
                      },
                      icon: const Icon(Icons.route, color: Colors.black),
                      label: const Text("START LIVE RIDE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(peerId: routeData['user_id'])));
                      },
                      icon: const Icon(Icons.chat, color: Color(0xFFFFD700)),
                      label: const Text("MESSAGE DRIVER", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFFD700))),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}