import 'package:dating/auth/signupDesktop/signup.dart';
import 'package:dating/auth/signupMobile/signup.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  // Define a constant for the breakpoint
  static const double mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine which widget to render based on screen width
              return constraints.maxWidth < mobileBreakpoint
                  ? const SignUpMobile() // Render mobile layout
                  : const SignUpDesktop(); // Render desktop layout
            },
          ),
        ),
      ),
    );
  }
}
