import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/services/chat_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const ChatScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<dynamic> _messages = [];
  bool _isLoading = true;
  late IO.Socket socket;
  late String _userId;
  late String _receiverId;

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<AuthProvider>(context, listen: false).user.id;
    
    // Find receiver ID from members array
    final members = widget.conversation['members'] as List<dynamic>? ?? [];
    _receiverId = members.firstWhere((m) => m.toString() != _userId, orElse: () => '');

    _connectSocket();
    _fetchMessages();
  }

  void _connectSocket() {
    // Assuming the socket runs on the base domain of the API endpoint
    // Fallback to localhost if not set properly in prod
    const String socketUrl = 'https://marketplace.mecity.in'; 

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Connected to socket server');
      socket.emit('addUser', _userId);
    });

    socket.on('getMessage', (data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': data['senderId'],
            'text': data['text'],
            'createdAt': DateTime.now().toIso8601String(),
          });
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _fetchMessages() async {
    final msgs = await _chatService.getMessages(widget.conversation['_id']);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    // Emit via socket
    socket.emit('sendMessage', {
      'senderId': _userId,
      'receiverId': _receiverId,
      'text': text,
    });

    // Save to DB
    final msgData = {
      'sender': _userId,
      'text': text,
      'conversationId': widget.conversation['_id'],
    };

    final newMsg = await _chatService.createMessage(msgData);
    if (newMsg != null && mounted) {
      setState(() {
        _messages.add(newMsg);
      });
      _scrollToBottom();
      
      // Update last message
      socket.emit('updateLastMessage', {
        'lastMessage': text,
        'lastMessageId': _userId,
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF0F172A),
              radius: 18,
              child: Icon(Icons.store, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seller Chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  'Active Now',
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent[400]),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['sender'] == _userId;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                            bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['createdAt'] != null 
                                ? timeago.format(DateTime.tryParse(msg['createdAt']) ?? DateTime.now())
                                : 'just now',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
