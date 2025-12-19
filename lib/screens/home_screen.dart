import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _fullName = '';
  String _currentUserEmail = '';
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _messages = [];
  Map<String, DateTime> _lastReadTimes = {};
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMessages();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('currentUserEmail');
      if (currentUserEmail != null) {
        _currentUserEmail = currentUserEmail;
        final usersJson = prefs.getString('users') ?? '[]';
        final List<dynamic> usersList = jsonDecode(usersJson);
        setState(() {
          _users = usersList.map((e) => Map<String, dynamic>.from(e)).toList();
        });
        final user = usersList.firstWhere(
          (u) => u['email'] == currentUserEmail,
          orElse: () => null,
        );
        if (user != null) {
          setState(() {
            _fullName = user['fullName'] ?? 'User';
          });
        } else {
          setState(() {
            _fullName = 'User';
          });
        }
      } else {
        setState(() {
          _fullName = 'User';
        });
      }
    } catch (e) {
      setState(() {
        _fullName = 'User';
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('messages') ?? '[]';
      final List<dynamic> messagesList = jsonDecode(messagesJson);
      final messages = messagesList
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Load last read times
      final lastReadTimes = <String, DateTime>{};
      for (final user in _users) {
        final email = user['email'];
        final lastReadStr = prefs.getString('lastRead_$email');
        if (lastReadStr != null) {
          lastReadTimes[email] = DateTime.parse(lastReadStr);
        }
      }

      setState(() {
        _messages = messages;
        _lastReadTimes = lastReadTimes;
      });
    } catch (e) {
      setState(() {
        _messages = [];
        _lastReadTimes = {};
      });
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUserEmail');
    // Navigate back to login
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  String _getLastMessage(String email) {
    final userMessages =
        _messages.where((m) {
          return (m['sender'] == email && m['receiver'] == _currentUserEmail) ||
              (m['sender'] == _currentUserEmail && m['receiver'] == email);
        }).toList()..sort(
          (a, b) => DateTime.parse(
            a['timestamp'] ?? '',
          ).compareTo(DateTime.parse(b['timestamp'] ?? '')),
        );
    if (userMessages.isEmpty) return 'No messages yet';
    final lastMessage = userMessages.last;
    final messageText = lastMessage['message'] ?? 'No messages yet';
    final prefix = lastMessage['sender'] == _currentUserEmail
        ? 'You: $messageText'
        : messageText;
    return prefix;
  }

  String _getLastMessageTimeStr(String email) {
    final userMessages =
        _messages.where((m) {
          return (m['sender'] == email && m['receiver'] == _currentUserEmail) ||
              (m['sender'] == _currentUserEmail && m['receiver'] == email);
        }).toList()..sort(
          (a, b) => DateTime.parse(
            a['timestamp'] ?? '',
          ).compareTo(DateTime.parse(b['timestamp'] ?? '')),
        );
    if (userMessages.isEmpty) return '';
    final lastMessage = userMessages.last;
    final timestamp = DateTime.parse(lastMessage['timestamp'] ?? '');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );
    String timeStr;
    if (messageDate == today) {
      timeStr = 'Today ${DateFormat('HH:mm').format(timestamp)}';
    } else if (messageDate == yesterday) {
      timeStr = 'Yesterday';
    } else {
      timeStr = DateFormat('dd/MM').format(timestamp);
    }
    return timeStr;
  }

  int _getUnreadCount(String email) {
    final userMessages =
        _messages.where((m) {
          return (m['sender'] == email && m['receiver'] == _currentUserEmail);
        }).toList()..sort(
          (a, b) => DateTime.parse(
            a['timestamp'] ?? '',
          ).compareTo(DateTime.parse(b['timestamp'] ?? '')),
        );

    if (userMessages.isEmpty) return 0;

    final lastReadTime = _lastReadTimes[email];
    if (lastReadTime == null) return userMessages.length;

    // Count messages after last read
    return userMessages
        .where(
          (m) => DateTime.parse(m['timestamp'] ?? '').isAfter(lastReadTime),
        )
        .length;
  }

  DateTime? _getLastMessageTime(String email) {
    final userMessages =
        _messages.where((m) {
          return (m['sender'] == email && m['receiver'] == _currentUserEmail) ||
              (m['sender'] == _currentUserEmail && m['receiver'] == email);
        }).toList()..sort(
          (a, b) => DateTime.parse(
            a['timestamp'] ?? '',
          ).compareTo(DateTime.parse(b['timestamp'] ?? '')),
        );

    if (userMessages.isEmpty) return null;
    return DateTime.parse(userMessages.last['timestamp'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $_fullName'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          // Sort users by last message time, most recent first
          final sortedUsers = _users.toList()
            ..sort((a, b) {
              final timeA = _getLastMessageTime(a['email']);
              final timeB = _getLastMessageTime(b['email']);
              if (timeA == null && timeB == null) return 0;
              if (timeA == null) return 1;
              if (timeB == null) return -1;
              return timeB.compareTo(timeA); // Descending
            });
          final user = sortedUsers[index];
          final lastMessage = _getLastMessage(user['email']);
          final timeStr = _getLastMessageTimeStr(user['email']);
          final unreadCount = _getUnreadCount(user['email']);
          return ListTile(
            leading: CircleAvatar(
              child: Text((user['fullName'] ?? 'U')[0].toUpperCase()),
            ),
            title: Text(user['fullName'] ?? 'Unknown'),
            subtitle: Row(
              children: [
                Expanded(child: Text(lastMessage)),
                if (timeStr.isNotEmpty)
                  Text(
                    timeStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            trailing: unreadCount > 0
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () async {
              await Navigator.pushNamed(context, '/chat', arguments: user);
              _loadMessages();
            },
          );
        },
      ),
    );
  }
}
