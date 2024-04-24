import 'package:dating/auth/loginDesktop/login.dart';
import 'package:dating/auth/loginMobile/login.dart';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // For smaller screen sizes (e.g., mobile)
                return LoginMobile();
              } else {
                // For larger screen sizes (e.g., tablet or desktop)
                return LoginDesktop();
              }
            },
          ),
        ),
      ),
    );
  }
}
