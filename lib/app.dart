import 'package:flutter/material.dart';
import 'package:login/screens/login_screen.dart';
import 'package:login/screens/signup_screen.dart';
import 'package:login/screens/home_screen.dart';
import 'package:login/screens/chat_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => ChatScreen(
          selectedUser:
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
        ),
      },
    );
  }
}
