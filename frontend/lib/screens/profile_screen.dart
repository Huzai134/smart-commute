import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isVerified = false;
  bool _isScanning = false;
  String _scanStatus = "Awaiting ID Upload";
  
  final String _userName = "Muhammad Huzaifa"; // Your actual profile name
  String _userId = "Unverified";

  final ImagePicker _picker = ImagePicker();

  Future<void> _simulateAIVerification() async {
    // 1. Open the gallery to pick an image (Feels 100% real to the user)
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return; // User canceled picking

    // 2. Start the Hollywood Magic (Simulated Scan)
    setState(() {
      _isScanning = true;
      _scanStatus = "Transmitting image to AI Engine...";
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _scanStatus = "Scanning University ID Format...");

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _scanStatus = "Extracting Name and Photo...");

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _scanStatus = "Cross-checking NUML Database...");

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    // 3. Grant the Gold Status
    setState(() {
      _isScanning = false;
      _isVerified = true;
      _userId = "NUML-CS-001"; // Simulated extracted ID
      _scanStatus = "Identity Confirmed";
      
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("ID Successfully Verified!"), backgroundColor: Colors.green),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust & Security'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF1E1E1E),
                  child: Icon(Icons.person, size: 60, color: _isVerified ? const Color(0xFFFFD700) : Colors.grey),
                ),
                if (_isVerified)
                  const CircleAvatar(radius: 18, backgroundColor: Colors.black, child: Icon(Icons.verified, color: Color(0xFFFFD700), size: 24)),
              ],
            ),
            const SizedBox(height: 20),
            Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text("ID: $_userId", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _isVerified ? const Color(0xFFFFD700) : Colors.redAccent.withOpacity(0.5), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(_isVerified ? Icons.security : Icons.warning_amber_rounded, color: _isVerified ? const Color(0xFFFFD700) : Colors.redAccent),
                      const SizedBox(width: 10),
                      Text(
                        _isVerified ? "Account Verified" : "Action Required",
                        style: TextStyle(color: _isVerified ? const Color(0xFFFFD700) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isVerified ? "Your identity has been verified by our secure system." : "Upload a valid University ID card to ride securely.",
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  if (_isScanning) ...[
                    const CircularProgressIndicator(color: Color(0xFFFFD700)),
                    const SizedBox(height: 15),
                    Text(_scanStatus, style: const TextStyle(color: Color(0xFFFFD700), fontStyle: FontStyle.italic)),
                  ] else if (!_isVerified) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text("UPLOAD ID PHOTO"),
                        onPressed: _simulateAIVerification,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Center(child: Text("TRUST LEVEL: GOLD", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, letterSpacing: 2))),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}