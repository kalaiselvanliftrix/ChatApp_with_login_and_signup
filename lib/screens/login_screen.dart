import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final currentUserEmail = prefs.getString('currentUserEmail');
      if (isLoggedIn && currentUserEmail != null && mounted) {
        // Verify user still exists
        final usersJson = prefs.getString('users') ?? '[]';
        final List<dynamic> usersList = jsonDecode(usersJson);
        final userExists = usersList.any(
          (user) => user['email'] == currentUserEmail,
        );
        if (userExists) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Ignore errors, stay on login
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();

      // Load users
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);
      final List<Map<String, String>> users = usersList
          .map((e) => Map<String, String>.from(e))
          .toList();

      final email = _emailController.text;
      final password = _passwordController.text;

      // Find matching user
      final user = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUserEmail', email);
        // Navigate to home
        if (mounted) {
          Navigator.pushNamed(context, '/home');
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
        }
      }
    }
  }

  void _goToSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _goToSignup,
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
