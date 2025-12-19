import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> selectedUser;

  const ChatScreen({super.key, required this.selectedUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _currentUserEmail = '';
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _allMessages = [];
  List<Map<String, dynamic>> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser().then((_) {
      _markAsRead();
      _loadMessages();
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('currentUserEmail');
      if (currentUserEmail != null) {
        setState(() {
          _currentUserEmail = currentUserEmail;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'lastRead_${widget.selectedUser['email']}',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('messages') ?? '[]';
      final List<dynamic> messagesList = jsonDecode(messagesJson);
      setState(() {
        _allMessages = messagesList
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _filterChatMessages();
      });
    } catch (e) {
      setState(() {
        _allMessages = [];
        _chatMessages = [];
      });
    }
  }

  void _filterChatMessages() {
    setState(() {
      _chatMessages = _allMessages.where((message) {
        final sender = message['sender'];
        final receiver = message['receiver'];
        return (sender == _currentUserEmail &&
                receiver == widget.selectedUser['email']) ||
            (sender == widget.selectedUser['email'] &&
                receiver == _currentUserEmail);
      }).toList();
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      'sender': _currentUserEmail,
      'receiver': widget.selectedUser['email'],
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      _allMessages.add(newMessage);
      _filterChatMessages();
    });

    _messageController.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(_allMessages);
      await prefs.setString('messages', messagesJson);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.selectedUser['fullName'] ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isMe = message['sender'] == _currentUserEmail;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'HH:mm',
                          ).format(DateTime.parse(message['timestamp'] ?? '')),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
