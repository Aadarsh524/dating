// import 'package:dating/auth/signupMobile/signup.dart';

import 'package:dating/auth/signupScreen.dart';
import 'package:dating/helpers/device_token.dart';
import 'package:dating/helpers/notification_services.dart';
import 'package:dating/pages/state_loader.dart';
import 'package:dating/providers/authentication_provider.dart';

import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  User? user = FirebaseAuth.instance.currentUser;
  UserProfileProvider userProfileProvider = UserProfileProvider();
  bool _isChecked = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to save login state
  void _saveLoginState(bool isSavedToLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSavedToLoggedIn', isSavedToLoggedIn);
  }

  Future<void> _login(BuildContext context) async {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      String? result = await authenticationProvider.signInWithEmailAndPassword(
          email, password, context);

      if (result != null) {
        // If result is not null, it's a valid UID

        NotificationServices notificationServices = NotificationServices();
        String? deviceToken = await notificationServices.getDeviceToken();

        postDeviceToken(result, deviceToken!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StateLoaderPage()),
        );
      } else {
        // If result is null, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: User not found'),
          ),
        );
      }
    } catch (e) {
      // Catch any errors thrown by signInWithEmailAndPassword
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return ListView(
      children: [
        // space above
        const SizedBox(
          height: 20,
        ),
        Image.asset(
          AppImages.login,
          height: 200,
        ),

        // login text
        const SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Find your match',
                style: AppTextStyles().authMainStyle,
              ),
            ],
          ),
        ),
        // space betn find your match and text field
        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              Text(
                'Email Address',
                style: AppTextStyles().authLabelStyle,
              )
            ],
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppTextField(
            inputcontroller: _emailController,
            hintText: 'Enter Email',
            keyboardType: TextInputType.emailAddress,
          ),
        ),

        // password

        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              Text(
                'Password',
                style: AppTextStyles().authLabelStyle,
              )
            ],
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppTextField(
            inputcontroller: _passwordController,
            hintText: 'Enter Your Password',
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
          ),
        ),

        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Forgot Password ?',
                style: AppTextStyles().secondaryStyle.copyWith(
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),

        // spacer
        const SizedBox(height: 35),

        // checkbox
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 35,
                child: NeumorphicSwitch(
                  height: 20,
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value;
                      // Do something when the switch is toggled
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              // space
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Keep me logged in',
                            style: AppTextStyles().authLabelStyle.copyWith(
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        "Don't check this box if you're at a public or shared computer",
                        style: AppTextStyles().authLabelStyle.copyWith(
                              fontSize: 14,
                              color: AppColors.secondaryColor,
                            ),
                      ),
                    ]),
              )
            ],
          ),
        ),

        // button
        const SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 55,
            child: Consumer<AuthenticationProvider>(
              builder: (context, authenticationProvider, _) {
                return GestureDetector(
                  onTap: authenticationProvider.isAuthLoading
                      ? null
                      : () {
                          _saveLoginState(_isChecked);
                          _login(context);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Background color
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade500,
                          offset: const Offset(4, 4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: authenticationProvider.isAuthLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Login',
                              style: AppTextStyles()
                                  .primaryStyle
                                  .copyWith(fontSize: 14, color: Colors.black),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Or',
              style: AppTextStyles()
                  .authLabelStyle
                  .copyWith(color: AppColors.secondaryColor),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),

        // sign in with

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 55,
            child: Button(
              onPressed: () {
                _saveLoginState(_isChecked);

                authenticationProvider.signInWithGoogle(context).then((user) {
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StateLoaderPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign-In canceled or failed.'),
                      ),
                    );
                  }
                });
              },
              text: 'Login With',
              imagePath: 'assets/images/google.png',
            ),
          ),
        ),

        // dont have an account
        const SizedBox(
          height: 25,
        ),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Don't have an account?",
            style: AppTextStyles().secondaryStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignUpScreen()));
            },
            child: Text(
              'Register',
              style: AppTextStyles().primaryStyle.copyWith(fontSize: 14),
            ),
          ),
        ])
      ],
    );
  }
}
