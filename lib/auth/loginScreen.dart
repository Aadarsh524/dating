import 'package:dating/auth/loginDesktop/login.dart';
import 'package:dating/auth/loginMobile/login.dart';
import 'package:dating/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggedIn = false; // Flag to track login status

  @override
  void initState() {
    super.initState();
    // Check if user is logged in when the widget is initialized
    checkLoginStatus();
  }

  // Function to check login status
  void checkLoginStatus() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      // User is not logged in
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user is logged in, navigate to homepage
    if (_isLoggedIn) {
      return const HomePage(); // Replace HomePage() with your actual homepage widget
    }

    // If user is not logged in, display login screen
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Change background color if needed
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // For smaller screen sizes (e.g., mobile)
                return const LoginMobile();
              } else {
                // For larger screen sizes (e.g., tablet or desktop)
                return const LoginDesktop();
              }
            },
          ),
        ),
      ),
    );
  }
}
