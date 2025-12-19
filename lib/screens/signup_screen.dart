import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _createAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();

      // Load existing users
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);
      final List<Map<String, String>> users = usersList
          .map((e) => Map<String, String>.from(e))
          .toList();

      // Check if email already exists
      final email = _emailController.text;
      final existingUser = users.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );

      if (existingUser.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email already registered')),
          );
        }
        return;
      }

      // Add new user
      final newUser = {
        'email': email,
        'password': _passwordController.text,
        'fullName': _fullNameController.text,
        'age': _ageController.text,
      };
      users.add(newUser);

      // Save updated users list
      final updatedUsersJson = jsonEncode(users);
      await prefs.setString('users', updatedUsersJson);

      // TODO: Implement signup logic
      final fullName = _fullNameController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final age = _ageController.text;
      print(
        'Full Name: $fullName, Email: $email, Password: $password, Confirm: $confirmPassword, Age: $age',
      );
      // Navigate to login
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null) {
                      return 'Please enter a valid number';
                    }
                    if (age < 13) {
                      return 'You must be at least 13 years old';
                    }
                    if (age > 120) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Create Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _createAccount,
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
