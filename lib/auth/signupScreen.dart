// import 'package:dating/auth/loginDesktop/login.dart';
// import 'package:dating/auth/loginMobile/login.dart';
import 'package:dating/auth/signupDesktop/signup.dart';
import 'package:dating/auth/signupMobile/signup.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                return const SignUpMobile();
              } else {
                // For larger screen sizes (e.g., tablet or desktop)
                return const SignUpDesktop();
              }
            },
          ),
        ),
      ),
    );
  }
}
