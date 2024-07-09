import 'package:dating/auth/loginDesktop/login.dart';
import 'package:dating/auth/loginMobile/login.dart';
import 'package:dating/pages/state_loader.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    try {
      bool isUserLoggedIn = await context
          .read<AuthenticationProvider>()
          .checkLoginStatus(context);
      setState(() {
        _isUserLoggedIn = isUserLoggedIn;
      });
      print(_isUserLoggedIn);
    } catch (e) {
      print("Error checking login status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserLoggedIn) {
      return const StateLoaderPage();
    }
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
