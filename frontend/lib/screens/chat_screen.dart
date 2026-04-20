import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String peerId;

  const ChatScreen({super.key, required this.peerId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  
  late WebSocketChannel _channel;
  final String _myUserId = "test_user_001"; 
  bool _isConnected = false; // NEW: Track connection status

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      // Connect to the server (Use localhost for Web, 10.0.2.2 for Android emulators)
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8000/ws/chat/$_myUserId'),
      );

      // Listen to the live stream
      _channel.stream.listen(
        (data) {
          if (!mounted) return;
          setState(() {
            _isConnected = true;
            _messages.insert(0, {
              "text": jsonDecode(data)["message"],
              "isMe": false, 
            });
          });
        },
        onError: (error) {
          debugPrint("WebSocket Error: $error");
          if (mounted) setState(() => _isConnected = false);
        },
        onDone: () {
          debugPrint("WebSocket Closed by Server");
          if (mounted) setState(() => _isConnected = false);
        },
      );

      setState(() => _isConnected = true);
      _messages.add({"text": "Securely connected to ${widget.peerId}.", "isMe": false, "isSystem": true});

    } catch (e) {
      debugPrint("Failed to connect: $e");
      setState(() => _isConnected = false);
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    _controller.clear();

    // 1. ALWAYS show our message on the screen instantly
    setState(() {
      _messages.insert(0, {"text": text, "isMe": true});
    });

    // 2. Try to send it to Python
    try {
      final payload = jsonEncode({
        "receiver_id": widget.peerId,
        "message": text
      });
      _channel.sink.add(payload);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message. Server offline."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _channel.sink.close(); 
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chat: ${widget.peerId}'),
            const SizedBox(width: 10),
            // NEW: Visual indicator if the chat is live!
            Icon(Icons.circle, color: _isConnected ? Colors.green : Colors.red, size: 12),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, 
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                
                if (msg["isSystem"] == true) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(msg["text"], style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                    )
                  );
                }

                final isMe = msg["isMe"];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFFD700) : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 20),
                      ),
                      border: isMe ? null : Border.all(color: Colors.grey.shade800),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E1E),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFFD700),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black, size: 20),
                      onPressed: _sendMessage,
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