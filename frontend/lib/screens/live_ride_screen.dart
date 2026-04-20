import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class LiveRideScreen extends StatefulWidget {
  final int engineCC;

  const LiveRideScreen({super.key, required this.engineCC});

  @override
  State<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends State<LiveRideScreen> {
  bool _isRideActive = false;
  bool _isLoading = false;
  
  Position? _startPosition;
  Map<String, dynamic>? _finalReceipt;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return false;
      }
    }
    return true;
  }

  Future<void> _startRide() async {
    setState(() => _isLoading = true);
    final hasPermission = await _handleLocationPermission();
    
    if (!hasPermission) {
      setState(() => _isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    setState(() {
      _startPosition = position;
      _isRideActive = true;
      _isLoading = false;
    });
  }

  Future<void> _endRide() async {
    setState(() => _isLoading = true);
    
    Position endPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    double distanceInMeters = Geolocator.distanceBetween(
      _startPosition!.latitude, _startPosition!.longitude,
      endPosition.latitude, endPosition.longitude,
    );

    double actualDistanceKm = (distanceInMeters / 1000) * 1.3;

    final receipt = await ApiService.getMeteredPrice(widget.engineCC, actualDistanceKm);

    setState(() {
      _isRideActive = false;
      _isLoading = false;
      _finalReceipt = receipt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Meter'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_finalReceipt != null) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text("Ride Completed", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFFFD700))),
                  child: Column(
                    children: [
                      Text("Total Distance: ${_finalReceipt!['final_distance']} km", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      const Divider(color: Colors.grey, height: 30),
                      const Text("Your Share to Pay", style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 10),
                      Text("Rs. ${_finalReceipt!['final_price']}", style: const TextStyle(color: Color(0xFFFFD700), fontSize: 40, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ] else ...[
                Icon(_isRideActive ? Icons.route : Icons.location_on, color: _isRideActive ? Colors.green : const Color(0xFFFFD700), size: 100),
                const SizedBox(height: 30),
                Text(
                  _isRideActive ? "Ride in Progress..." : "Ready to Start",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _isRideActive ? "We are tracking your exact distance." : "Tap below when you sit in the car.",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 50),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRideActive ? Colors.red : const Color(0xFFFFD700),
                    ),
                    onPressed: _isLoading ? null : (_isRideActive ? _endRide : _startRide),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            _isRideActive ? "END RIDE & PAY" : "START RIDE",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}