// import 'package:dating/auth/signupMobile/signup.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:dating/auth/signupScreen.dart';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_model.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/backend/firebase_auth/firebase_auth.dart';
import 'package:dating/providers/user_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  User? user = FirebaseAuth.instance.currentUser;
  UserProvider userProvider = UserProvider();
  bool _isChecked = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<bool> _login() async {
    String? result = await _authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (result != null) {
      final response = await http.get(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        Uri.parse(
            '$URI/User/$result'), // Replace with your API endpoint to fetch user data
      );

      if (response.statusCode == 200) {
        // Parse the response and update the currentUser object
        final Map<String, dynamic> userData = jsonDecode(response.body);

        final UserModel newUser = UserModel(
          uid: result,
          name: '',
          email: '',
          gender: '',
        );
        newUser.name = userData['name'];
        newUser.email = userData['email'];
        newUser.gender = userData['gender'];
        log("mobile");
        log(newUser.toString());
        log("userName: ${newUser.name}");
        log("email: ${newUser.email}");
        log("gender: ${newUser.gender}");
       
      } else {
        // Handle error when user data retrieval fails
        print(
            'Failed to retrieve user data from MongoDB. Error: ${response.statusCode}');
      }

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
      print('Login Successful');
      return true;
      // Login successful, navigate to the next screen or perform any other action
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error login: $result'),
        ),
      );
      return false;
      // Login failed, show error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: Button(
              onPressed: () {
                _login();
              },
              text: 'Login',
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
                _authService.signInWithGoogle().then((user) {
                  if (user != null) {
                    // Sign-in successful, navigate to home page
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const HomePage()));
                  } else {
                    // Sign-in canceled or failed, show error message (optional)
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
