import 'package:dating/auth/loginScreen.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/services/firebase_auth/firebase_auth.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class SignUpMobile extends StatefulWidget {
  const SignUpMobile({super.key});

  @override
  State<SignUpMobile> createState() => _SignUpMobileState();
}

class _SignUpMobileState extends State<SignUpMobile> {
  final bool _isChecked = false;
  String? selectedGender;
  String _selectedAge = '18'; // Initial age
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _register() async {
    String? result = await _auth.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      gender: selectedGender ?? '',
      age: _selectedAge,
    );

    if (result == null) {
      // Registration successful, navigate to home page or perform any other action
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      // Registration failed, show error message
      // You can display the error message to the user
      print('Registration error: $result');
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
                'Your Name',
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
            inputcontroller: _nameController,
            hintText: 'Enter your name',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'I am a',
                          style: AppTextStyles().authLabelStyle,
                        )
                      ],
                    ),
                  ),

                  // gender sletect
                  // spacer
                  const SizedBox(
                    height: 6,
                  ),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGender = 'male';
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedGender == 'male'
                                  ? Colors.blue // Border color when selected
                                  : Colors
                                      .transparent, // Border color when not selected
                              width: 2.0,
                            ),
                          ),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              depth: 10,
                              intensity: 0.5,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.male,
                                color: selectedGender == 'male'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // female
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGender = 'female';
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedGender == 'female'
                                  ? Colors.blue // Border color when selected
                                  : Colors
                                      .transparent, // Border color when not selected
                              width: 2.0,
                            ),
                          ),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              depth: 10,
                              intensity: 0.5,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.female,
                                color: selectedGender == 'female'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // looking for s
              const Spacer(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Looking For',
                          style: AppTextStyles().authLabelStyle,
                        )
                      ],
                    ),
                  ),

                  // gender sletect
                  // spacer
                  const SizedBox(
                    height: 6,
                  ),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGender = 'female';
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedGender == 'female'
                                  ? Colors.blue // Border color when selected
                                  : Colors
                                      .transparent, // Border color when not selected
                              width: 2.0,
                            ),
                          ),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              depth: 10,
                              intensity: 0.5,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.male,
                                color: selectedGender == 'female'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // female
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGender = 'male';
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedGender == 'male'
                                  ? Colors.blue // Border color when selected
                                  : Colors
                                      .transparent, // Border color when not selected
                              width: 2.0,
                            ),
                          ),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              depth: 10,
                              intensity: 0.5,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.female,
                                color: selectedGender == 'male'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // age picker
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Age',
                      style: AppTextStyles().authLabelStyle,
                    )
                  ],
                ),
              ),

              // gender sletect
              // spacer
              const SizedBox(
                height: 6,
              ),

              Neumorphic(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: DropdownButton<String>(
                  underline: Container(),
                  style: AppTextStyles().secondaryStyle,
                  value: _selectedAge,
                  icon: const Icon(Icons.arrow_drop_down), // Dropdown icon
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAge = newValue!;
                    });
                  },
                  items: <String>['18', '19', '20', '21'] // Language options
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: AppTextStyles().secondaryStyle,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // email
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

//

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

// confirm password

        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              Text(
                'Confirm Password',
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
            inputcontroller: _confirmpasswordController,
            hintText: 'Re-enter Your Password',
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

// spacer
        const SizedBox(height: 35),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 55,
            child: Button(
              onPressed: () {
                _register().then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                });
              },
              text: 'Sign Up',
            ),
          ),
        ),

// sign in with
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 55,
            child: Button(
              onPressed: () {
                _auth.signInWithGoogle();
                //signed in with google
                //google
                //this should do
              },
              text: 'Sign Up With',
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
            "Already have an account?",
            style: AppTextStyles().secondaryStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: Text(
              'LogIn',
              style: AppTextStyles().primaryStyle.copyWith(fontSize: 14),
            ),
          ),
        ])
      ],
    );
  }
}
